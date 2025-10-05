BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'Get-TcmTestCaseSyncStatus' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Error -MockWith { }

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
            $result = Get-TcmTestCaseSyncStatus -Id 'TC001' -Config @{ }

            # Assert
            $result | Should -Be 'new-local'
        }

        It 'Should return new-remote when local file not found' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith { @() }

            # Act
            $result = Get-TcmTestCaseSyncStatus -Id '123' -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result | Should -Be 'new-remote'
        }

        It 'Should return synced when hashes match' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmStringHash -MockWith { 'same-hash' }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                @{ FullName = 'C:\temp\TC001.yaml' }
            }

            # Act
            $result = Get-TcmTestCaseSyncStatus -Id '123' -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result | Should -Be 'synced'
        }

        It 'Should return local-changes when local hash differs' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmStringHash -MockWith {
                param($InputObject)
                if ($InputObject.title -eq 'Local Test Case') { 'local-hash' } else { 'remote-hash' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                @{ FullName = 'C:\temp\TC001.yaml' }
            }

            # Act
            $result = Get-TcmTestCaseSyncStatus -Id '123' -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result | Should -Be 'local-changes'
        }

        It 'Should return local-changes when local hash differs from remote' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmStringHash -MockWith {
                param($InputObject)
                if ($InputObject.title -eq 'Local Test Case') { 'local-hash' } else { 'remote-hash' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                @{ FullName = 'C:\temp\TC001.yaml' }
            }

            # Act
            $result = Get-TcmTestCaseSyncStatus -Id '123' -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result | Should -Be 'local-changes'
        }

        It 'Should handle remote fetch failure gracefully' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith { throw "API error" }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                @{ FullName = 'C:\temp\TC001.yaml' }
            }

            # Act
            $result = Get-TcmTestCaseSyncStatus -Id '123' -Config @{ TestCasesRoot = 'C:\temp' }

            # Assert
            $result | Should -Be 'local-changes'
        }
    }
}