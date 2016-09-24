#---------------------------------# 
# Param Help tests                # 
#---------------------------------# 

#Default params to ignore 
$ignoredparams =  'Verbose',
                  'Debug',
                  'ErrorAction',
                  'WarningAction',
                  'InformationAction',
                  'ErrorVariable',
                  'WarningVariable',
                  'InformationVariable',
                  'OutVariable',
                  'OutBuffer',
                  'PipelineVariable',
                  'InformationAction',
                  'id',
                  'info'

$RepoRoot = Resolve-Path "$PSScriptRoot\..\" 

#Import modules in RepoRoot for testing
$Modules  = Get-ChildItem $RepoRoot -Filter ‘*.psm1’ | Where-Object {$_.name -NotLike ‘*Tests.psm1’}
$Modules  | ForEach-Object {
  Import-Module $_.fullname -WarningAction 0
}

#Filter to only run on modules to root path. 
$Modules  = Get-Module | Where-Object {
  ($_.path -like "$RepoRoot*") -and ($_.Path -notlike "$RepoRoot\TestModules*")
}

if ($Modules.count -gt 0) {
  Describe "Param help tests." {
    foreach ($module in $modules) {
      #Extract parameters from psm1. 
      #Todo, make function and use get-help OR better multiline regex
      $hashelp = select-string -pattern '\.PARAMETER\s+(\S+)' -LiteralPath $module.path | ForEach-Object{$_.matches.groups[1].value}
    
      foreach ($command in $module.ExportedCommands.keys) {
        Context “'$($module.Path)' - '$command'” {

        #Extract command parameters.
        $params  = (get-command $command).Parameters.keys | Where-Object {$_ -notin $ignoredparams} 
        foreach ($param in $params) {
            It “.PARAMETER help available for $param“ {
              $hashelp -contains $param | should be $true
            }          
          }
        }
      }
    }
  }
  $modules | Remove-Module
}

