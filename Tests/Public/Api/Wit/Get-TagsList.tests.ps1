[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TagsList' {
    BeforeAll {
        $expected = @{
            ApiProjectConnection = New-TestApiProjectConnection
            Url = 'https://dev.azure.com/test/test/_apis/wit/tags'
            Tags = @(
                @{ name = 'Tag1' },
                @{ name = 'Tag2' },
                @{ name = 'TestTag' },
                @{ name = 'DevTag' }
            )
        }

        Mock -ModuleName $ModuleName Get-ApiProjectConnection {
            return $expected.ApiProjectConnection
        }

        Mock -ModuleName $ModuleName Invoke-ApiListPaged {
            return $expected.Tags
        }

        Mock -ModuleName $ModuleName Join-Uri {
            return $expected.Url
        }
    }

    Context 'When calling with default parameters' {
        It 'Should return all tags' {
            # Act
            $result = Get-TagsList

            # Assert
            $result.Count | Should -Be 4
            $result | Should -Contain $expected.Tags[0]
            $result | Should -Contain $expected.Tags[1]
        }
    }

    Context 'When using Include filter' {
        It 'Should return only tags matching the include pattern' {
            # Act
            $result = @(Get-TagsList -Include 'Test*')

            # Assert
            $result.Count | Should -Be 1
            $result[0].name | Should -Be 'TestTag'
        }

        It 'Should handle multiple include patterns' {
            # Act
            $result = Get-TagsList -Include @('Test*', 'Dev*')

            # Assert
            $result.Count | Should -Be 2
            $result.name | Should -Contain 'TestTag'
            $result.name | Should -Contain 'DevTag'
        }
    }

    Context 'When using Exclude filter' {
        It 'Should exclude specified tags' {
            # Act
            $result = Get-TagsList -Exclude 'Test*'

            # Assert
            $result.Count | Should -Be 3
            $result.name | Should -Not -Contain 'TestTag'
        }

        It 'Should handle multiple exclude patterns' {
            # Act
            $result = Get-TagsList -Exclude @('Test*', 'Dev*')

            # Assert
            $result.Count | Should -Be 2
            $result.name | Should -Not -Contain 'TestTag'
            $result.name | Should -Not -Contain 'DevTag'
        }
    }

    Context 'When using CaseSensitive parameter' {
        It 'Should respect case sensitivity in filtering' {
            # Act
            $result = Get-TagsList -Include 'test*' -CaseSensitive

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'When API version is below 6.0' {
        It 'Should upgrade API version to 6.0-preview' {
            # Arrange
            $connection = New-TestApiProjectConnection
            $connection.ApiVersion = '5.0'

            Mock -ModuleName $ModuleName Get-ApiProjectConnection {
                return $connection
            }

            # Act
            $null = Get-TagsList

            # Assert
            Should -Invoke -ModuleName $ModuleName Invoke-ApiListPaged -ParameterFilter {
                $ApiVersion -eq '6.0-preview'
            }
        }
    }

    Context 'When using custom credentials' {
        It 'Should pass custom credentials to connection' {
            # Arrange
            $customUri = 'https://custom.azure.com'
            $customCred = [PSCustomObject]@{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.ApiCredential'
                Username = 'custom'
            }

            # Act
            $null = Get-TagsList -CollectionUri $customUri

            # Assert
            Should -Invoke -ModuleName $ModuleName Get-ApiProjectConnection -ParameterFilter {
                $CollectionUri -eq $customUri
            }
        }
    }
}
