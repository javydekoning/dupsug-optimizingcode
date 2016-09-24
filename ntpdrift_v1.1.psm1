function Check-NTPDrift {
    <#
      .SYNOPSIS
      Checks the current system ntp drift against warning and critical parameters.
      .DESCRIPTION
      Checks the current system ntp drift against warning and critical parameters using WMI.
      .PARAMETER Warning
      The warning value in seconds to compare
      .PARAMETER Critical
      The critical value in seconds to compare
      .PARAMETER Source
      The Source NTP device to test against, this is not mandatory. If no NTP server is specified this will default to the one which is configured (usually PDC emulator)
      .PARAMETER IgnoreStandalone
      Makes the check return OK if the system is not part of a domain AND does not have an NTP source configured.
      .INPUTS
      This check accepts no pipeline input
      .OUTPUTS
      IPmonCheck Status Object
      .EXAMPLE
      check-ntpdrift -warning 1 -critical 20
      .EXAMPLE
      check-ntpdrift -warning 1 -critical 20 -source ntp.source.com
      .EXAMPLE
      check-ntpdrift -warning 10 -critical 30 -source ntp.source.com
      .COMPONENT
      Windows
      .NOTES
      JdeKoning, Last update 2016-09-16
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias("W","Warn")]
        [Double]$Warning, 

        [Parameter(Mandatory)]
        [Alias("C","Crit")]
        [Double]$Critical,
        
        [Parameter(Mandatory=$false)]
        [Switch]$IgnoreStandalone,
        
        [Parameter(Mandatory=$false)]
        [String]$source = (Get-DefaultTimeSource), 

        [Parameter(Mandatory)]
        [String]$Id
    )
    #check if domain member.
    $FreeRunning = $source -match '(Free-running|Local CMOS Clock|The service has not been started)'

    #Return warning if the server is DomainMember but NOT configured to use NTP
    if ( ((Get-DomainRole) -eq 'member') -and ($FreeRunning) ) {
      $StdOut  = 'WARNING: Server is part of domain but NTP source is NOT configured. | ntpdrift = 00.0000000s'
      $wrn     = Get-IPmonObject -StdOut $StdOut -IPmonState 'WARNING' -Id $Id      
      return $wrn
    } 
    
    #Ignore non domain-computers with free running time. 
    if ( (Get-DomainRole) -eq 'standalone') {
      if ($IgnoreStandalone.IsPresent) {
        $StdOut  = 'OK: Server is NOT part of domain. | ntpdrift = 00.0000000s'
        $Obj     = Get-IPmonObject -StdOut $StdOut -IPmonState 'OK' -Id $Id      
      } else {
        $StdOut  = 'WARNING: Server is NOT part of domain, NTP source is NOT configured. | ntpdrift = 00.0000000s'
        $Obj     = Get-IPmonObject -StdOut $StdOut -IPmonState 'WARNING' -Id $Id      
      }
      return $Obj      
    }   

    # Create an object from the result of w32tm. 
    $drift       = Get-Drift -source $source
    $drift_raw   = [regex]::replace($drift[-1],'(.*)(\+|-)(.*)(s)','$3') -as [double]
    
    
    # Return unknown if w32tm returns an error.
    if($drift -match 'error' -or (-not($drift_raw -is [double])) ){
      $StdOut  = 'UNKNOWN: Cannot query NTPDrift from Source "{0}" | ntpdrift = 00.0000000s' -f $source
      $Unknown = Get-IPmonObject -StdOut $StdOut -IPmonState 'UNKNOWN' -Id $Id
      return $Unknown
    }
 
    # Round down to something reasonable
    $drift_raw      = [math]::round($drift_raw,7)

    #evaluate check
    if($drift_raw -ge $Critical ){
      $state = 'CRITICAL'
    }elseif($drift_raw -ge $Warning){
      $state = 'WARNING'
    }else{
      $state = 'OK'
    }

    #compose IPmon message
    $StdOut   = '{0}: NTP Drift from "{1}" {2} is {3} seconds | ntpdrift={3}s' -f $state, $drift[0].split(" ")[1], $drift[0].split(" ")[2], $drift_raw
    $IPmonObj = Get-IPmonObject -StdOut $StdOut -IPmonState $state -Id $Id
    
    return $IPmonObj
}

function Get-DomainRole {
  $wmi = Get-WmiObject -Class win32_computersystem 
  $res = switch ($wmi.DomainRole) {
    0 {'standalone'}
    2 {'standalone'}
    5 {'pdc'}
    default {'member'}
  }
  return $res
}
function Get-Drift($Source) {
  w32tm /stripchart /computer:$Source /dataonly /samples:1
}
function Get-DefaultTimeSource
{
  [string]$res = w32tm /query /source
  
  #Trim leading and trailing whitespace to prevent failures.
  $res = $res.split(",")[0]
  $res = $res.trim()
  
  return $res
}
function Get-IPmonObject
{
  Param
  (
    # Param0 help description
    [Parameter(Mandatory)]
    [string]$StdOut,

    # Param1 help description
    [Parameter(Mandatory=$false)]
    [string]$StdErr = '',  
        
    # Param2 help description
    [Parameter(Mandatory)]
    [string]$IPmonState,
        
    # Param3 help description
    [Parameter(Mandatory)]
    [string]$Id  
  )
    
  $IPmonState = switch ($IPmonState)
  {
    'OK'      {'0'}
    'WARNING' {'1'}
    'CRITICAL'{'2'}
    'UNKNOWN' {'3'}
  }
    
  $IPmonResult = [PSCustomObject]@{ 
    StdOut  = $StdOut; 
    StdErr  = $StdErr; 
    RetCode = $IPmonState; 
    Id      = $Id 
  }
  return $IPmonResult
}

Export-ModuleMember -Function Check-NTPDrift