function Set-BeakerEnvVar {
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','',Justification='Only Setting Environments Vars')]
  param(

    # Verbosity of test ouput. Defaults to yes for max output. Aids in troubleshooting failing tests.
    [ValidateSet('yes','no')]
    [string]
    $BEAKER_debug,

    # What to do with the provisioned machines once the test run is over.
    [ValidateSet('always','no','onpass')]
    [string]
    $BEAKER_destroy,

    # Relative location of the ssh keyfile to use for testing if you are using this form of authentication
    [string]
    $BEAKER_keyfile,

    # URL of the base folder from which you can dowload the Puppet Entrprise installer. This can be a folder where you have placed the build artifact after downloading and building from source.
    [string]
    $BEAKER_PE_DIR,

    # Specific version of the Puppet Enterprise installer to use.
    [string]
    $BEAKER_PE_VER,

    # The version of the agent you would like to install on agent nodes
    [string]
    $BEAKER_PUPPET_AGENT_VERSION,

    # Location of the hosts file to use with a test run. Leave this blank to auto generate a hosts file based on configuration
    [string]
    $BEAKER_setfile,

    # Choose whether to run tests in master agent, agent only, or local mode.
    [ValidateSet('local','apply','agent')]
    [string]
    $BEAKER_TESTMODE,

    # Tell beaker whether you need to create the boxes on this run, or if they are already created and reachable.
    [ValidateSet('yes','no')]
    [string]
    $BEAKER_provision,

    # Choose the test framework to use for testing. Defaults to beaker-rspec both here and in configuration file unless changed.
    [string]
    $TEST_FRAMEWORK,

    # Version of the puppet installer to use with the run_puppet_install_helper function from beaker-puppet_install_helper
    [string]
    $PUPPET_INSTALL_VERSION,

    # Take the name of a configured override set
    [string]
    $OverrideSet,

    # Define environment variables not accounted for in configuration in case you need them for additional helpers that like environment vars. Please pass in a hashtable of key value pairs.
    [hashtable]
    $userDefined
  )

  $vars = Get-ConfigFromDisk

  if($OverrideSet -ne '') {
    $vars = Select-OverrideSet -config $vars -OverrideSet $OverrideSet
  }

  foreach($var in $vars.env) {
    if($userValue = Get-UserValue -name $var.name) {
      Write-Verbose ("Set-BeakerEnvVar: Found user override: {0} with value: {1}" -f $var.name, $userValue)
      $vars.env[$var.name] = $userValue
    }
  }

  foreach($key in $userDefined.keys) {
    $vars.env | Add-Member -MemberType NoteProperty -Name $key -Value $userDefined[$key]
  }

  Write-Verbose ($vars.env | Out-String)

  foreach($var in $vars.env) {
    $path = Join-Path -Path env:\ -ChildPath $var.name
    $value = $var.value
    Write-Verbose "Set-BeakerEnvVar: Setting: $path to: $value"
    New-Item -Path $path -Value $value -force | Out-Null
  }
}