function Invoke-RakeTask {
  [cmdletbinding()]
  param(
    [string[]]$TaskName,
    [switch]$SkipEnvVars,
    [string]$OverrideSet,
    [hashtable]$UserDefined,
    [string]$userHostsString,
    [string]$hypervisor,
    [string]$hostsString,
    [switch]$ForceCreateHosts
  )
  # Tasklist
  # Set Environment Vars
  if (!$SkipEnvVars) {
    $envParams = @{
      verbose = $VerbosePreference
    }

    foreach($variable in @('overrideset','userdefined')) {
      if($PSBoundParameters.ContainsKey($variable)) {
        $envParams[$variable] = Get-Variable -Name $variable -ValueOnly
      }
    }

    Set-BeakerEnvVar @envParams
  }

  # Create Setfile
  $hostsParams = @{
    verbose = $VerbosePreference
  }

  foreach($variable in @('userHostsString','hypervisor','hostsstring')) {
    if($PSBoundParameters.ContainsKey($variable)) {
      $hostsParams[$variable] = Get-Variable -Name $variable -ValueOnly
    }

    if($ForceCreateHosts) {
      $hostsParams['force'] = $true
    }

    New-SetFile @hostsParams
  }
  # Parse for master or agent only and set vars to match
  Set-VarsForHostsFile
  # Run test pattern

  Invoke-BundleCommand -command "rake $TaskName"
  # Delete env vars.
  $removeParams = @{
    verbose = $VerbosePreference
  }

  if($PSBoundParameters.ContainsKey('userdefined')) {
    $removeParams['userdefined'] = $UserDefined
  }

  Remove-BeakerEnvVar @removeParams
}