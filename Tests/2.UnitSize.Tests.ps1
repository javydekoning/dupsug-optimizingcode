#---------------------------------# 
# UnitSize tests                  # 
#---------------------------------#
$maxunitsize = 100
$RepoRoot    = Resolve-Path "$PSScriptRoot\..\" 
$Modules     = Get-ChildItem $RepoRoot -Filter ‘*.psm1’ | Where-Object {$_.name -NotMatch ‘Tests.psm1’}

Import-Module "$RepoRoot\TestModules\Get-UnitSize.psm1"

if ($Modules.count -gt 0) {
  Describe ‘UnitSize tests’ {
    foreach ($module in $modules) {
      $unitsizes = Get-UnitSize $module.FullName
      Context “'$($module.FullName)'” {
        foreach ($unit in $unitsizes) {
          It “$($unit.name) is max. $maxunitsize lines“ {
            $unit.size | should BeLessThan ($maxunitsize + 1)
          }          
        }      
      }
    }
  }
}

Remove-Module Get-UnitSize