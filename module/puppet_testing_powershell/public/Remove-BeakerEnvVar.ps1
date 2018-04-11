function Remove-BeakerEnvVar {
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','',Justification='Only Removing Environments Vars')]
  param(
    # User Defined environment vars to remove. Ideally pass in the same hash that was passed into Set-BeakerEnvVar.
    [hashtable]
    $userDefined
  )

  $varsList = Get-Content "$PSScriptRoot\..\moduleconfig.json" -raw `
              | Out-String `
              | ConvertFrom-JSON


  foreach ($key in $varsList.env.name) {
    $path = Join-Path -path env:\ -ChildPath $key
    if (Test-Path $path) {
      Write-Verbose "Removing: $path"
      Remove-Item $path -Force
    }
  }

  foreach ($key in $userDefined.keys) {
    $path = Join-Path -Path env:\ -ChildPath $key
    if (Test-Path $path) {
      Write-Verbose "Removing: $path"
      Remove-Item $path -force
    }
  }
}