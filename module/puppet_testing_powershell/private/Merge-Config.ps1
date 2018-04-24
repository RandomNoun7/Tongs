function Merge-Config {
  [CmdletBinding()]
  param (
    [PSCustomObject]$base,
    [PSCustomObject]$child
  )

  begin {
    if ((-not $PSBoundParameters.ContainsKey('child')) -or ([string]::IsNullOrEmpty($child))) {
      return $base
    }
  }

  process {

    # Merge Env node

    foreach ($var in $child.env) {
      if ($baseVar = $base.env | Where-Object -Property 'name' -EQ -Value $var.name) {
        Write-Verbose ("Found variable: {0} with value: {1} in repo scoped file." -f $var.name, $var.value)
        $baseVar.value = $var.value
      }
    }

    # Merge Override Sets

    if (-not ($base.env_override_sets)) {
      [PSCustomObject[]]$holder = @()
      $base | Add-Member -MemberType NoteProperty -Name 'env_override_sets' -Value $holder
    }

    foreach ($overrideSet in $child.env_override_sets) {
      if ($baseOverrideSet = $base.env_override_sets | Where-Object -Property 'name' -EQ -Value $overrideSet.name) {
        foreach ($overrideItem in $overrideSet.values) {
          if ($baseOverrideItem = $baseOverrideSet.values | Where-Object -Property 'name' -EQ -Value $overrideItem.name) {
            Write-Verbose ("Found environment variable override item in set {0} with name {1} with value {2} in repo scoped file" -f $overrideSet.name, $overrideItem.name, $overrideItem.value.ToString())
            $baseOverrideItem.value = $overrideItem.value
          } else {
            Write-Verbose ("Adding override item from set {0} with name {1} and value {2} from repo scoped file." -f $overrideSet.name, $overrideItem.name, $overrideItem.value)
            $baseOverrideSet.values += $overrideItem
          }
        }
      } else {
        Write-Verbose ("Adding override set {0} from repo scoped file." -f $overrideSet.name)
        $base.env_override_sets += $overrideSet
      }
    }

    # Merge default hypervisor and string

    if ($default_hypervisor = $child.host_generator_strings.default_hypervisor) {
      Write-Verbose ("Found new default_hypervisor {0} in repo scoped file" -f $default_hypervisor)
      $base.host_generator_strings.default_hypervisor = $default_hypervisor
    }

    if ($default_string = $child.host_generator_strings.default_string) {
      Write-Verbose ("Found new default_string {0} in repo scoped file" -f $default_string)
      $base.host_generator_strings.default_string = $default_string
    }

    # Merge strings for each hypervisor

    $baseHypervisors = $base.host_generator_strings.hypervisors

    foreach ($hypervisor in $child.host_generator_strings.hypervisors) {
      if($baseHypervisor = $baseHypervisors | Where-Object -Property 'name' -EQ -Value $hypervisor.name) {
        foreach($string in $hypervisor.strings) {
          if($baseString = $baseHypervisor.strings | Where-Object -Property 'name' -EQ -Value $string.name) {
            Write-Verbose ("Found Hypervisor string {0} with value {1} for hypervisor {2} in repo scoped file." -f $string.name, $string.value, $hypervisor.name)
            $baseString.value = $string.value
          } else {
            Write-Verbose ("Adding Hypervisor string {0} with value {1} for hypervisor {2} from repo scoped file" -f $string.name, $string.value, $hypervisor.name)
            $baseHypervisor.strings += $string
          }
        }
      } else {
        Write-Verbose ("Adding Hypervisor string set {0} from repo scoped file." -f $hypervisor.name)
        $base.host_generator_strings.hypervisors += $hypervisor
      }
    }

    # Merge global config

    if($global_config = $child.host_generator_strings.global_config) {
      $base.host_generator_strings.global_config = $global_config
    }

    return $base
  }

  end {
  }
}