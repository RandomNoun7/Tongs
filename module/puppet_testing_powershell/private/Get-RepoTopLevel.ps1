function Get-RepoTopLevel {
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
    (Get-Item -path (git rev-parse --show-toplevel)).fullname
  }

  end {
  }
}