[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Show-ApiCredentialsList' {

    BeforeEach {
        Mock -ModuleName $ModuleName -CommandName Get-ApiCredentialsList -MockWith {
            @(
                [PSCustomObject]@{
                    CollectionUri = 'https://example.com/collection2'
                    Project       = 'Project1'
                    Authorization = 'Basic'
                    UserName      = 'user1'
                },
                [PSCustomObject]@{
                    CollectionUri = 'https://example.com/collection1'
                    Project       = 'Project2'
                    Authorization = 'Bearer'
                    UserName      = 'user2'
                }
            )
        }
    }

    It 'Should display a list of API credentials' {
        $output = Show-ApiCredentialsList | Out-String
        $output | Should -Match 'https://example.com/collection1'
        $output | Should -Match 'Project1'
        $output | Should -Match 'Basic'
        $output | Should -Match 'user1'
        $output | Should -Match 'https://example.com/collection2'
        $output | Should -Match 'Project2'
        $output | Should -Match 'Bearer'
        $output | Should -Match 'user2'
    }

    It 'Should sort the output by CollectionUri, Project, Authorization, and UserName' {
        $output = Show-ApiCredentialsList | Out-String
        $lines = $output -split "`n"
        $lines[3] | Should -Match 'https://example.com/collection1'
        $lines[4] | Should -Match 'https://example.com/collection2'
    }

    It 'Should handle no API credentials' {
        Mock -ModuleName $ModuleName -CommandName Get-ApiCredentialsList -MockWith { @() }
        $output = Show-ApiCredentialsList | Out-String
        $output | Should -BeNullOrEmpty
    }
}
