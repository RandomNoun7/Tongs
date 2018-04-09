function Get-UserValue {
  [CmdletBinding()]
  param (
    [string]$name
  )

  begin {
  }

  process {
    (Get-Variable -Name $name -ErrorAction SilentlyContinue).value
  }

  end {
  }
}