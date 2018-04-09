
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$here\..\..\module\puppet_testing_powershell\private\Get-ConfigFromDisk.ps1"

function Get-RepoTopLevel {}
function Merge-Config {}

Describe 'Unit - Get-ConfigFromDisk' {

  context 'Verify Dependancy Mocks' {
    Mock Get-RepoTopLevel -MockWith {return 'Testdrive:\'}
    Mock Merge-Config {return ''}

    Mock Get-Content {return ''} -ParameterFilter {$Path -match 'moduleconfig'}
    Mock Get-Content {return ''} -ParameterFilter {$Path -match '.puppet'}
    Mock ConvertFrom-Json {return ''}
    Mock Test-Path {return $true}

    it 'Should return an empty string' {
      Get-ConfigFromDisk | Should be ''
    }

    Assert-MockCalled -CommandName Get-RepoTopLevel -Times 1
    Assert-MockCalled -CommandName Get-Content -times 2
    Assert-MockCalled -CommandName Merge-Config
    Assert-MockCalled -CommandName ConvertFrom-Json -times 2
  }

  context 'No git found' {
    $errorString = "The term 'git' is not recognized as the name of a cmdlet, function, script file, or operable program."

    Mock Get-RepoTopLevel {throw $errorString}
    Mock Merge-Config {return ''}

    Mock Get-Content {return ''}
    Mock ConvertFrom-Json {return ''}
    Mock Test-Path {return $true}

    it 'Should not find git' {
      {Get-ConfigFromDisk} | Should -Throw 'git not found'
    }

    Assert-MockCalled -CommandName Get-RepoTopLevel -Times 1
    Assert-MockCalled -CommandName Get-Content -times 0
    Assert-MockCalled -CommandName Merge-Config -Times 0
    Assert-MockCalled -CommandName ConvertFrom-Json -times 0

  }
}
