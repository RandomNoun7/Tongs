function Invoke-BundleCommand {

  [cmdletbinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression','', Justification='Used Here For Mockability')]
  param(
    [Parameter(Mandatory=$true)]
    [string]
    $command
  )

  Invoke-Expression -Command $command

  <#
    .Synopsis
    This cmdlet allows for easy mocking of commands for Pester testing.
    .PARAMETER command
    The command to execute is taken as a string. This parameter allows for easy
    filtering of mocks during Pester testing.
  #>
}