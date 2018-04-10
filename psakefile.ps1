task default -Depends test

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