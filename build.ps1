param (
  [string[]]$task = 'Default'
)

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

$moduleList = @('Psake', 'PSDeploy', 'PSScriptAnalyzer', 'Pester')

foreach($module in $moduleList) {
  if(-not (Get-Module -Name $module -ListAvailable)){
    Write-Host "Installing Module: $module"
    Install-Module -Name $module -Force -SkipPublisherCheck
  }
}

Import-Module Psake

Invoke-psake -buildFile .\psakefile.ps1 -taskList $Task -nologo
exit ( [int]( -not $psake.build_success ) )