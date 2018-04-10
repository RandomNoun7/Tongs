$private = (Get-ChildItem "$PSScriptRoot\Private\*" -Recurse).FullName
$public  = (Get-ChildItem "$PSScriptRoot\Public\*" -Recurse).FullName

$private + $public | Foreach-Object {. $_}

Export-ModuleMember *
