BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'Resolve-TcmTestCaseSyncStatus' {

    BeforeAll {
        # Mock Get-WorkItem
        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
            @{
                fields = @{
                    'System.Title' = 'Remote Test Case'
                    'System.ChangedDate' = '2024-01-15T10:30:00Z'
                }
            }
        }

        # Mock Get-TcmTestCaseFromFile
        Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseFromFile -MockWith {
            @{
                testCase = @{ id = '123'; title = 'Local Test Case' }
                history = @{ lastModifiedAt = '2024-01-15T09:00:00Z' }
            }
        }
    }

    Context 'Sync status determination' {

        It 'Should return new-local for non-numeric ID' {
            # Act
            $inputObject = [PSCustomObject]@{
                Id = 'TC001'
                LocalData = $null
                RemoteData = $null
                LocalDataHash = $null
                RemoteDataHash = $null
                SyncStatus = $null
            }
            $inputObject.PSTypeNames.Insert(0, 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')
            $result = Resolve-TcmTestCaseSyncStatus -InputObject $inputObject -Config @{ }

            # Assert
            $result.SyncStatus | Should -Be 'new-local'
        }

        It 'Should return new-remote when local file not found' {
            # Arrange
            $inputObject = [PSCustomObject]@{
                Id = '123'
                LocalData = $null
                RemoteData = @{ id = '123'; title = 'Remote Test Case' }
                LocalDataHash = $null
                RemoteDataHash = 'remote-hash'
                SyncStatus = $null
            }
            $inputObject.PSTypeNames.Insert(0, 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')

            # Act
            $result = Resolve-TcmTestCaseSyncStatus -InputObject $inputObject -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result.SyncStatus | Should -Be 'new-remote'
        }

        It 'Should return synced when hashes match' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmHashCache -MockWith {
                @{ '123' = @{ local = 'same-hash'; remote = 'same-hash'; lastSync = '2024-01-01T00:00:00Z' } }
            }
            $inputObject = [PSCustomObject]@{
                Id = '123'
                LocalData = @{
                    id = '123'
                    title = 'Local Test Case'
                }
                RemoteData = @{
                    id = '123'
                    title = 'Remote Test Case'
                }
                LocalDataHash = 'same-hash'
                RemoteDataHash = 'same-hash'
                SyncStatus = $null
            }
            $inputObject.PSTypeNames.Insert(0, 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')

            # Act
            $result = Resolve-TcmTestCaseSyncStatus -InputObject $inputObject -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result.SyncStatus | Should -Be 'synced'
        }

        It 'Should return local-changes when local hash differs' {
            # Arrange
            # Mock cache to have existing entry with different local hash
            Mock -ModuleName $ModuleName -CommandName Get-TcmHashCache -MockWith {
                @{ '123' = @{ local = 'old-local-hash'; remote = 'remote-hash'; lastSync = '2024-01-01T00:00:00Z' } }
            }
            $inputObject = [PSCustomObject]@{
                Id = '123'
                LocalData = @{
                    id = '123'
                    title = 'Local Test Case'
                }
                RemoteData = @{
                    id = '123'
                    title = 'Remote Test Case'
                }
                LocalDataHash = 'local-hash'
                RemoteDataHash = 'remote-hash'
                SyncStatus = $null
            }
            $inputObject.PSTypeNames.Insert(0, 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')

            # Act
            $result = Resolve-TcmTestCaseSyncStatus -InputObject $inputObject -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result.SyncStatus | Should -Be 'local-changes'
        }

        It 'Should return local-changes when local hash differs from remote' {
            # Arrange
            # Mock cache to have existing entry with matching remote hash but different local hash
            Mock -ModuleName $ModuleName -CommandName Get-TcmHashCache -MockWith {
                @{ '123' = @{ local = 'old-local-hash'; remote = 'remote-hash'; lastSync = '2024-01-01T00:00:00Z' } }
            }
            $inputObject = [PSCustomObject]@{
                Id = '123'
                LocalData = @{
                    id = '123'
                    title = 'Local Test Case'
                }
                RemoteData = @{
                    id = '123'
                    title = 'Remote Test Case'
                }
                LocalDataHash = 'local-hash'
                RemoteDataHash = 'remote-hash'
                SyncStatus = $null
            }
            $inputObject.PSTypeNames.Insert(0, 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')

            # Act
            $result = Resolve-TcmTestCaseSyncStatus -InputObject $inputObject -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result.SyncStatus | Should -Be 'local-changes'
        }

        It 'Should handle remote fetch failure gracefully' {
            # Arrange
            # Mock cache to have existing entry (previously synced)
            Mock -ModuleName $ModuleName -CommandName Get-TcmHashCache -MockWith {
                @{ '123' = @{ local = 'local-hash'; remote = 'remote-hash'; lastSync = '2024-01-01T00:00:00Z' } }
            }
            $inputObject = [PSCustomObject]@{
                Id = '123'
                LocalData = @{
                    id = '123'
                    title = 'Local Test Case'
                }
                RemoteData = $null
                LocalDataHash = 'local-hash'
                RemoteDataHash = $null
                SyncStatus = $null
            }
            $inputObject.PSTypeNames.Insert(0, 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')

            # Act
            $result = Resolve-TcmTestCaseSyncStatus -InputObject $inputObject -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result.SyncStatus | Should -Be 'local-changes'
        }
    }
}
