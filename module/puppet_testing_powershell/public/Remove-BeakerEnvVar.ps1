function Remove-BeakerEnvVar {
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','',Justification='Only Removing Environments Vars')]
  param(
    # User Defined environment vars to remove. Ideally pass in the same hash that was passed into Set-BeakerEnvVar.
    [hashtable]
    $userDefined
  )

  $varsList = Get-ChildItem env:\ | Where-Object -Property Name -Match 'PUPPET|BEAKER'

  foreach($item in $varslist.name) {
    Write-Verbose ("Remove-BeakerEnvVar: Removing $item")
    Remove-Item -Path "env:\$item"
  }
}