function Set-VarsForHostsFile {
  [cmdletbinding()]
  param(
  )

  $hasMaster = (Get-Content $env:BEAKER_setfile | Select-String '- master').count -gt 0

  if($hasMaster) {
    Write-Verbose 'Set-VarsForHostsFile: Setting PUPPET_INSTALL_TYPE to "pe" because there is a master in the hosts file.'
    $env:PUPPET_INSTALL_TYPE = 'pe'

    Write-Verbose 'Set-VarsForHostsFile: Setting BEAKER_TESTMODE to "agent" because there is a master in the hosts file.'
    $env:BEAKER_TESTMODE = 'agent'
  }
}