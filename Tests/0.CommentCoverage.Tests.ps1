#---------------------------------# 
# Comment Coverage tests          # 
#---------------------------------#
 
[double]$coveragepercent = 10

$RepoRoot = Resolve-Path "$PSScriptRoot\..\" 
$Modules  = Get-ChildItem $RepoRoot -Filter ‘*.psm1’ | Where-Object {$_.name -NotMatch ‘Tests.psm1’}

Import-Module "$RepoRoot\TestModules\Get-CommentCoverage.psm1"

if ($Modules.count -gt 0) {
  Describe ‘Comment coverage tests’ {
    foreach ($module in $modules) {
      Context “'$($module.FullName)'” {
        It “Comment coverage is above $coveragepercent%“ {
          Get-CommentCoverage -literalpath $module.FullName | should BeGreaterThan $coveragepercent 
        }          
      }
    }
  }
}

Remove-Module Get-CommentCoverage