[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Test-ApiCredential' {

    BeforeAll {
        $mockCollectionUri = 'https://dev.azure.com/testorg'
        $mockUser = [PSCustomObject]@{
            displayName = 'Test User'
            mailAddress = 'testuser@example.com'
            id          = 'test-user-id'
        }
    }

    Context 'When credentials are valid' {

        BeforeEach {
            Mock -ModuleName $ModuleName -CommandName Get-CurrentUser -MockWith {
                return $mockUser
            }
        }

        It 'Should return success with user information' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri

            # Assert
            $result.Success | Should -BeTrue
            $result.StatusCode | Should -Be 200
            $result.User | Should -Not -BeNullOrEmpty
            $result.User.displayName | Should -Be 'Test User'
            $result.ErrorMessage | Should -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-CurrentUser -Times 1
        }

        It 'Should return true when -Quiet is specified' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri -Quiet

            # Assert
            $result | Should -BeOfType [bool]
            $result | Should -BeTrue
        }

        It 'Should accept Token parameter and create ApiCredential' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName New-ApiCredential -MockWith {
                return [PSCustomObject]@{
                    PSTypeName    = 'PSTypeNames.AzureDevOpsApi.ApiCredential'
                    Authorization = 'PAT'
                }
            }

            # Act
            $result = Test-ApiCredential `
                -CollectionUri $mockCollectionUri `
                -Token 'test-pat-token'

            # Assert
            $result.Success | Should -BeTrue
            Should -Invoke -ModuleName $ModuleName -CommandName New-ApiCredential -Times 1 -ParameterFilter {
                $Token -eq 'test-pat-token' -and $Authorization -eq 'PAT'
            }
        }

        It 'Should accept ApiCredential parameter' {
            # Arrange
            $apiCredential = [PSCustomObject]@{
                PSTypeName    = 'PSTypeNames.AzureDevOpsApi.ApiCredential'
                Authorization = 'PAT'
            }

            # Act
            $result = Test-ApiCredential `
                -CollectionUri $mockCollectionUri `
                -ApiCredential $apiCredential

            # Assert
            $result.Success | Should -BeTrue
            Should -Invoke -ModuleName $ModuleName -CommandName Get-CurrentUser -Times 1 -ParameterFilter {
                $ApiCredential.Authorization -eq 'PAT'
            }
        }
    }

    Context 'When credentials are invalid (401 Unauthorized)' {

        BeforeEach {
            Mock -ModuleName $ModuleName -CommandName Get-CurrentUser -MockWith {
                $exception = [System.Exception]::new('The remote server returned an error: (401) Unauthorized.')
                $response = [PSCustomObject]@{
                    StatusCode = 401
                }
                $exception | Add-Member -NotePropertyName 'Response' -NotePropertyValue $response -Force
                throw $exception
            }
        }

        It 'Should return failure with 401 status code' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri -WarningAction SilentlyContinue

            # Assert
            $result.Success | Should -BeFalse
            $result.StatusCode | Should -Be 401
            $result.User | Should -BeNullOrEmpty
            $result.ErrorMessage | Should -Not -BeNullOrEmpty
        }

        It 'Should return false when -Quiet is specified' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri -Quiet

            # Assert
            $result | Should -BeOfType [bool]
            $result | Should -BeFalse
        }
    }

    Context 'When credentials lack permissions (403 Forbidden)' {

        BeforeEach {
            Mock -ModuleName $ModuleName -CommandName Get-CurrentUser -MockWith {
                $exception = [System.Exception]::new('The remote server returned an error: (403) Forbidden.')
                $response = [PSCustomObject]@{
                    StatusCode = 403
                }
                $exception | Add-Member -NotePropertyName 'Response' -NotePropertyValue $response -Force
                throw $exception
            }
        }

        It 'Should return failure with 403 status code' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri -WarningAction SilentlyContinue

            # Assert
            $result.Success | Should -BeFalse
            $result.StatusCode | Should -Be 403
            $result.User | Should -BeNullOrEmpty
            $result.ErrorMessage | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When network error occurs' {

        BeforeEach {
            Mock -ModuleName $ModuleName -CommandName Get-CurrentUser -MockWith {
                throw [System.Exception]::new('The operation has timed out.')
            }
        }

        It 'Should return failure with error message' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri -WarningAction SilentlyContinue

            # Assert
            $result.Success | Should -BeFalse
            $result.ErrorMessage | Should -Match 'timed out'
            $result.User | Should -BeNullOrEmpty
        }
    }

    Context 'When using global credentials' {

        BeforeEach {
            Mock -ModuleName $ModuleName -CommandName Get-CurrentUser -MockWith {
                return $mockUser
            }
        }

        It 'Should use global credentials when no parameters specified' {
            # Act
            $result = Test-ApiCredential

            # Assert
            $result.Success | Should -BeTrue
            Should -Invoke -ModuleName $ModuleName -CommandName Get-CurrentUser -Times 1 -ParameterFilter {
                $null -eq $CollectionUri -and $null -eq $ApiCredential
            }
        }
    }

    Context 'Output type validation' {

        BeforeEach {
            Mock -ModuleName $ModuleName -CommandName Get-CurrentUser -MockWith {
                return $mockUser
            }
        }

        It 'Should have correct PSTypeName' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri

            # Assert
            $result.PSTypeNames | Should -Contain 'PSTypeNames.AzureDevOpsApi.TestCredentialResult'
        }

        It 'Should have all required properties' {
            # Act
            $result = Test-ApiCredential -CollectionUri $mockCollectionUri

            # Assert
            $result.PSObject.Properties.Name | Should -Contain 'Success'
            $result.PSObject.Properties.Name | Should -Contain 'StatusCode'
            $result.PSObject.Properties.Name | Should -Contain 'User'
            $result.PSObject.Properties.Name | Should -Contain 'CollectionUri'
            $result.PSObject.Properties.Name | Should -Contain 'ErrorMessage'
        }
    }
}
