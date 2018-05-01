function Get-RepoTopLevel {
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
    git rev-parse --show-toplevel
  }

  end {
  }
}