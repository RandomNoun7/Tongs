function Get-ConfigFromDisk {
  [CmdletBinding()]
  param (

  )

  begin {
    if (Get-Command git) {
      $baseDir = git rev-parse --show-toplevel
    }
    else {
      Write-Error 'git not found.'
      return
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