Import-Module "$PSScriptRoot\ntpdrift_v1.1.psm1" -WarningAction SilentlyContinue
$guid   = New-Guid

Describe "Check-NTPdrift '$((Get-Module ntpdrift_v1.1).path)'" {
  
  Context "Domain Member - Service not started" {  
    Mock -ModuleName 'ntpdrift_v1.1' Get-DefaultTimeSource { return 'The following error occurred: The service has not been started. (0x80070426)' }
    Mock -ModuleName 'ntpdrift_v1.1' Get-DomainRole { return 'member' }
    $Result    = Check-NTPDrift -W 10 -C 30 -Id $guid
    $IgnResult = Check-NTPDrift -W 10 -C 30 -Id $guid -IgnoreStandalone
    It "Should return warning (1)" {
      $Result.RetCode | should be 1   
    }
    It "StdOut Should match WARNING: (1)" {
      $Result.StdOut | should beLike 'WARNING:*'   
    }
    It "IgnoreStandalone - Should return warning (1)" {
      $IgnResult.RetCode | should be 1   
    }
    It "IgnoreStandalone - Should match WARNING:" {
      $IgnResult.StdOut | should beLike 'WARNING:*'  
    }
    Assert-MockCalled -ModuleName 'ntpdrift_v1.1' Get-DefaultTimeSource 2
    Assert-MockCalled -ModuleName 'ntpdrift_v1.1' Get-DomainRole 2
  }
  
  Context "Standalone" {
    Mock -ModuleName 'ntpdrift_v1.1' Get-DomainRole { return 'standalone' }
    Mock -ModuleName 'ntpdrift_v1.1' Get-DefaultTimeSource { return 'The following error occurred: The service has not been started. (0x80070426)' }
    $Result    = Check-NTPDrift -W 10 -C 30 -Id $guid
    $IgnResult = Check-NTPDrift -W 10 -C 30 -Id $guid -IgnoreStandalone
    It "RetCode Should be 1 (WARNING)" {
      $Result.RetCode | should be 1   
    }
    It "StdOut Should match WARNING: (1)" {
      $Result.StdOut | should beLike 'WARNING*'   
    }
    It "IgnoreStandalone - RetCode Should be 0 (OK)" {
      $IgnResult.RetCode | should be 0   
    }
    It "IgnoreStandalone - StdOut Should match OK: (1)" {
      $IgnResult.StdOut | should beLike 'OK*'   
    }
    Assert-MockCalled -ModuleName 'ntpdrift_v1.1' Get-DefaultTimeSource 2
    Assert-MockCalled -ModuleName 'ntpdrift_v1.1' Get-DomainRole 2
  }
}

Remove-Module ntpdrift_v1.1