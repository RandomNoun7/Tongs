task default -depends writeModule, modifyModulePath, test
task refresh -depends writeModule, modifyModulePath

$moduleName = 'puppet_testing_powershell'

task test -depends scriptAnalyzer {
  $res = Invoke-Pester -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru

  if($env:APPVEYOR_JOB_ID)
  {
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml))
  }

  if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}
}

task scriptAnalyzer {
  if($env:APPVEYOR_JOB_ID) {
    Add-AppveyorTest -Name "PSScriptAnalyzer" -Outcome Running
  }

  # Analyze module source files and test files, but not the built module.
  $pathsToTest = @(
    "$PSScriptRoot\module"
    "$PSScriptRoot\test\acceptance"
    "$PSScriptRoot\test\unit"
    "$PSScriptRoot\test\*.ps1"
  )

  $results = @()

  foreach ($path in $pathsToTest) {
    if(Test-Path $path){
      $results += Invoke-ScriptAnalyzer -Path $path -Recurse -ErrorAction SilentlyContinue
    }
  }

  if($results) {
    $resultString = $results | Out-String
    Write-Warning $resultString
    if($env:APPVEYOR_JOB_ID) {
      Add-AppveyorMessage -Message "PSScriptAnalyzer found one or more errors."
      Update-AppveyorTest -Name 'PSScriptAnalyzer' -Outcome Failed -ErrorMessage $resultString
    }
  } else {
    if($env:APPVEYOR_JOB_ID){
      Update-AppveyorTest -Name 'PSScriptAnalyzer' -Outcome Passed
    }
  }
}

task writeModule {
  if(-not (Test-Path "$PSScriptRoot\test\module\$modulename\")) {
    New-Item "$PSScriptRoot\test\module\$modulename\" -ItemType Directory
  }
  Copy-Item -Path "$PSScriptRoot\module\$moduleName\$moduleName.ps*1" -Destination "$PSScriptRoot\test\module\$modulename\" -force
  Copy-Item -Path "$PSScriptRoot\module\$modulename\moduleconfig.json" -Destination "$PSScriptRoot\test\module\$modulename" -Force

  $paths = @("$PSScriptRoot\module\$moduleName\private","$PSScriptRoot\module\$moduleName\public")

  $content = Get-ChildItem -Path $paths -Recurse `
             | Get-Content

  Set-Content -Path "$PSScriptRoot\test\module\$modulename\$moduleName.psm1" -Value $content

}

task modifyModulePath {
  $testModulePath = (Get-Item ".\test\module").FullName
  $pathComponents = $env:PSModulePath -split ';'

  if(-not ($pathComponents -eq $testModulePath)){
    $pathComponents = ($testModulePath + $pathComponents)
  }

  $env:PSModulePath = $pathComponents -join ';'
}