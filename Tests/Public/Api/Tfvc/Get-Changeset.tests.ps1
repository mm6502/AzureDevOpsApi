[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-Changeset' {

    BeforeAll {
        $mockConnection = New-TestApiProjectConnection
        $mockCollectionUri = 'https://dev.azure.com/myorg'
        $mockProject = 'TestProject'
        $mockChangesetId = 12345
    }

    Context 'When called with valid parameters' {

        BeforeAll {

            Mock -ModuleName $ModuleName Get-ApiProjectConnection {
                $mockConnection
            }

            Mock -ModuleName $ModuleName Invoke-Api {
                return @{
                    changesetId = $mockChangesetId
                    author      = @{
                        displayName = 'Test User'
                    }
                    createdDate = '2023-05-01T10:00:00Z'
                    comment     = 'Test changeset'
                }
            }
        }

        It 'Should return the changeset details' {
            # Act
            $result = Get-Changeset `
                -CollectionUri $mockCollectionUri `
                -Project $mockProject `
                -Changeset $mockChangesetId

            # Assert
            $result.changesetId | Should -Be $mockChangesetId
            $result.author.displayName | Should -Be 'Test User'
            $result.createdDate | Should -Be '2023-05-01T10:00:00Z'
            $result.comment | Should -Be 'Test changeset'
        }

        It 'Should call Invoke-Api with the correct parameters' {
            # Arrange
            $expected = [PSCustomObject] @{
                Uri           = "$($mockCollectionUri)/_apis/tfvc/changesets/$($mockChangesetId)"
                Method        = 'GET'
                ApiCredential = $mockConnection.ApiCredential
            }

            # Act
            $result = Get-Changeset `
                -CollectionUri $mockCollectionUri `
                -Project $mockProject `
                -Changeset $mockChangesetId

            # Assert
            Should -Invoke -ModuleName $ModuleName Invoke-Api -ParameterFilter {
                $a = $Uri -eq $expected.Uri
                $b = $ApiCredential -eq $expected.ApiCredential
                $z = $a -and $b
                $z
            }
        }
    }
}
