#---------------------------------# 
# Header                          # 
#---------------------------------# 
Write-Host 'Running AppVeyor install script' -ForegroundColor Yellow

#---------------------------------# 
# Install NuGet                   # 
#---------------------------------# 
Write-Host 'Installing NuGet PackageProvider'
$pkg = Install-PackageProvider -Name NuGet -Force
Write-Host "Installed NuGet version '$($pkg.version)'" 

#---------------------------------# 
# Install Modules                 # 
#---------------------------------# 
$RequiredModules = 'PSScriptAnalyzer','Pester'
Install-Module -Name $RequiredModules -Repository PSGallery -Force -ErrorAction Stop

#---------------------------------# 
# Update PSModulePath             # 
#---------------------------------# 
Write-Host 'Updating PSModulePath for resource testing'
$env:PSModulePath = $env:PSModulePath + ";" + "C:\projects"

#---------------------------------# 
# Validate                        # 
#---------------------------------# 
$InstalledModules = Get-Module -Name $RequiredModules -ListAvailable
if ($InstalledModules.count -lt $RequiredModules.Count) { 
  throw "Required modules are missing."
} else {
  Write-Host 'All modules required found' -ForegroundColor Green
}