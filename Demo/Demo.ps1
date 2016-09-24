#1.0
cls

#region github
start 'https://github.com/javydekoning/dupsug'
#endregion

#modules

#region demo1
Import-Module C:\Users\jdekoning\github\dupsug\TestModules\Get-CommentCoverage.psm1
write-host -ForegroundColor Yellow 'Comment to code ratio ='
Get-CommentCoverage -literalpath C:\Users\jdekoning\github\cChoco\DSCResources\cChocoPackageInstall\cChocoPackageInstall.psm1
#endregion

#region demo2
Import-Module C:\Users\jdekoning\github\dupsug\TestModules\Get-UnitSize.psm1
write-host -ForegroundColor Yellow 'UnitSize ='
Get-UnitSize -literalpath C:\Users\jdekoning\github\cChoco\DSCResources\cChocoPackageInstall\cChocoPackageInstall.psm1
#endregion


#region Tests
cd 'C:\Users\jdekoning\github\dupsug'
#endregion

#region demo3
Invoke-ScriptAnalyzer -Path C:\Users\jdekoning\github\dupsug\ntpdrift_v1.0.psm1
#endregion

#region demo3.1
start 'https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/UseApprovedVerbs.md'
start 'https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/AvoidAlias.md'
#endregion

#region demo4
cls
cd C:\Users\jdekoning\github\dupsug\Tests\
Invoke-Pester
#endregion

#region demo5
cls
mv C:\Users\jdekoning\github\dupsug\ntpdrift_v1.0.psm1 C:\Users\jdekoning\github\dupsug\Demo\
mv C:\Users\jdekoning\github\dupsug\Demo\ntpdrift_v1.1.psm1 C:\Users\jdekoning\github\dupsug\
mv C:\Users\jdekoning\github\dupsug\Demo\ntpdrift_v1.1.Tests.ps1 C:\Users\jdekoning\github\dupsug\
cd C:\Users\jdekoning\github\dupsug\Tests\
Invoke-Pester
#endregion

#region rev5
mv C:\Users\jdekoning\github\dupsug\Demo\ntpdrift_v1.0.psm1 C:\Users\jdekoning\github\dupsug\
mv C:\Users\jdekoning\github\dupsug\ntpdrift_v1.1.psm1 C:\Users\jdekoning\github\dupsug\Demo
mv C:\Users\jdekoning\github\dupsug\ntpdrift_v1.1.Tests.ps1 C:\Users\jdekoning\github\dupsug\Demo
#endregion

#region demo6
start 'C:\Program Files\Sublime Text 3\sublime_text.exe'
#endregion

#AppVeyor ps

#push to git.....

#region demo7
start 'https://ci.appveyor.com/project/javydekoning/dupsug'
#endregion