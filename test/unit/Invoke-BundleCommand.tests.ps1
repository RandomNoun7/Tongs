. "$PSScriptRoot\..\..\module\puppet_testing_powershell\private\Invoke-BundleCommand.ps1"

Describe 'Invoke-BundleCommand' {
  Mock Invoke-Expression

  $cmdString = 'rake acceptance_tests'

  Invoke-BundleCommand -command $cmdString

  it 'Should have called Invoke-Expression once' {
    Assert-MockCalled -CommandName Invoke-Expression -times 1
  }

  it 'Should have called Invoke-Expression with the correct command' {
    Assert-MockCalled -CommandName Invoke-Expression -ParameterFilter {$command -eq "bundle exec $cmdString"}
  }
}