invoke-psake -buildFile ..\..\psakefile.ps1 -taskList refresh

Import-Module puppet_testing_powershell

New-Setfile -verbose -force