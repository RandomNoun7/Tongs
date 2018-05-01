function Get-ConfigFromDisk {
  [CmdletBinding()]
  param (

  )

  begin {
    try {
      $baseDir = Get-RepoTopLevel
    }
    catch {
      throw 'git not found'
      return $NULL
    }
  }

  process {
    $global = Get-Content "$PSScriptRoot\moduleconfig.json" -Raw `
      | ConvertFrom-Json

    if (Test-Path "$baseDir\.puppet_testing_powershell") {
      $repo = Get-Content "$baseDir\.puppet_testing_powershell" -Raw `
        | ConvertFrom-Json
    }

    $fileSettings = Merge-Config -base $global -child $repo -Verbose:$VerbosePreference

    return $fileSettings
  }

  end {
  }
}