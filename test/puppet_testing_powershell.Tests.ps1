$ModuleManifestName = 'puppet_testing_powershell.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\module\puppet_testing_powershell\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

