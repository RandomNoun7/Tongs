function New-SetFile {
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','',Justification='Not changing state of system. Only writing a file in the repo.')]
  param (
    [string]$outpath = '.\hosts.yaml',
    [string]$userHostsString,
    [string]$hypervisor,
    [string]$hostsString,
    [switch]$force
  )

  $defaults = Get-ConfigFromDisk

  if ((Test-Path $outpath) -And (-not $force)) {
    Write-Warning 'Hosts file already present.'
    return $NULL
  }

  # If the user gave us a host string we don't need anythign else. Generate the
  # Hosts file and return.
  if(-not [string]::IsNullOrEmpty($userHostsString)) {
    try{
      Push-Location (Get-repoTopLevel)
      Write-Verbose "New-SetFile: Using string: $userHostsString"
      $content = Invoke-BundleCommand -command "beaker-hostgenerator $userHostsString" -Verbose:$VerbosePreference
      Write-Verbose "New-SetFile: Content returned: $content"
      Pop-Location
      Set-Content -Path $outpath -Value $content -Encoding ASCII -Verbose:$VerbosePreference
      return
    }
    catch {
      Pop-Location
      throw $_
    }
  }

  $hypervisor = (($hypervisor, $defaults.host_generator_strings.default_hypervisor) -ne '')[0]
  Write-Verbose "New-SetFile: Using hypervisor: $hypervisor"
  $hostsString = (($hostsString, $defaults.host_generator_strings.default_string) -ne '')[0]
  Write-Verbose "New-SetFile: Using string: $hostsString"

  $hypervisorGroup = $defaults.host_generator_strings.hypervisors `
                     | Where-Object -Property name -EQ -Value $hypervisor

  $string = ($hypervisorGroup.strings `
            | Where-Object -Property name -EQ -Value $hostsString).value
  Write-Verbose "New-SetFile: Final string: $string"

  try{
    Push-Location (Get-RepoTopLevel)
    $content = Invoke-BundleCommand -command "beaker-hostgenerator $string" -Verbose:$VerbosePreference
    Write-Verbose "New-SetFile: Content returned:"
    Write-Verbose ($content -join [Environment]::NewLine)
    Pop-Location
    Set-Content -Path $outpath -Value $content -Encoding ASCII -Verbose:$VerbosePreference
  }
  catch {
    Pop-Location
    throw $_
  }

}