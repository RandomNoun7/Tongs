task default -Depends test

task test {
  $res = Invoke-Pester -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru

  if($env:APPVEYOR_JOB_ID)
  {
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml))
  }

  if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}
}