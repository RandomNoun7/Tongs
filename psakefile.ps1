task default -Depends test
task refresh -depends writeModule, modifyModulePath, ImportModule

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

  $results = Invoke-ScriptAnalyzer -Path $pwd -Recurse -Severity Warning -ErrorAction SilentlyContinue

  if($results) {
    $resultString = $results | Out-String
    Write-Warning $resultString
    if($env:APPVEYOR_JOB_ID) {
      Add-AppveyorMessage -Message "PSScriptAnalyzer found one or more errors."
      Update-AppveyorTest -Name 'PSScriptAnalyzer' -Outcome Failed -ErrorMessage $resultString
    }

    throw 'Script Analysis Failed'
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
  Copy-Item -Path "$PSScriptRoot\module\$moduleName\$moduleName.psm1" -Destination "$PSScriptRoot\test\module\$modulename\$modulename.psm1" -force

  $paths = @("$PSScriptRoot\module\$moduleName\private","$PSScriptRoot\module\$moduleName\public")

  $privateContent = Get-ChildItem -Path $paths[0] -Recurse `
                    | Get-Content

  $publicContent = Get-ChildItem -Path $paths[1] -Recurse `
                   | Get-Content

  Set-Content -Path "$PSScriptRoot\test\module\$modulename\$moduleName.psm1" -Value $privateContent
  Add-Content -Path "$PSScriptRoot\test\module\$modulename\$moduleName.psm1" -Value $publicContent

}

task modifyModulePath {
  $testModulePath = (Get-Item ".\test\module").FullName
  $pathComponents = $env:PSModulePath -split ';'

  if(-not ($pathComponents -eq $testModulePath)){
    $pathComponents += $testModulePath
  }

  $env:PSModulePath = $pathComponents -join ';'
}

task ImportModule {
  Import-Module $moduleName -force
}