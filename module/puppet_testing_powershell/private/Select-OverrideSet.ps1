function Select-OverrideSet {
  [CmdletBinding()]
  param (
    [PSCustomObject]$config,
    [string]$OverrideSet
  )

  $overrideSettings = $config.env_override_sets `
                      | Where-Object -Property name -EQ -Value $OverrideSet

  foreach($var in $overrideSettings.values) {
    $valueToChange = $config.env `
                     | Where-Object -Property name -EQ -Value $var.name
    $valueToChange.value = $var.value
  }

  foreach($var in $overrideSettings.delete_values) {
    $config.env = $config.env | Where-Object -Property name -NE -Value $var
  }

  return $config
}