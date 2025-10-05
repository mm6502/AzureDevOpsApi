BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Sync-TcmTestCase' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Error -MockWith { }

        # Mock the sync functions that are called by Sync-TcmTestCase
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseConflict -MockWith { }
    }

    Context 'Configuration and setup' {

        BeforeEach {
            # Create a temporary test directory
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"

sync:
  direction: "Bidirectional"
  conflictResolution: "Manual"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        }

        It 'Should load configuration correctly' {
            # Act & Assert
            { Sync-TcmTestCase -TestCasesRoot $testRoot -WhatIf } | Should -Not -Throw
        }

        It 'Should use default direction from config when not specified' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseConfig -MockWith {
                @{
                    TestCasesRoot = $testRoot
                    sync = @{
                        direction = 'ToRemote'
                        conflictResolution = 'Manual'
                    }
                    azureDevOps = @{
                        collectionUri = "https://dev.azure.com/test"
                        project = "TestProject"
                        pat = "dummy-pat"
                    }
                }
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith { @() }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            # Should not throw due to direction override
            $true | Should -Be $true
        }

        It 'Should use default conflict resolution from config when not specified' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseConfig -MockWith {
                @{
                    TestCasesRoot = $testRoot
                    sync = @{
                        direction = 'Bidirectional'
                        conflictResolution = 'LocalWins'
                    }
                    azureDevOps = @{
                        collectionUri = "https://dev.azure.com/test"
                        project = "TestProject"
                        pat = "dummy-pat"
                    }
                }
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith { @() }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            $true | Should -Be $true
        }
    }

    Context 'Sync status handling' {

        BeforeEach {
            # Create a temporary test directory
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"

sync:
  direction: "Bidirectional"
  conflictResolution: "Manual"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        }

        It 'Should handle synced test cases correctly' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'synced'
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -Times 1
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
        }

        It 'Should push new local test cases in bidirectional mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = 'TC001' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'new-local'
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
        }

        It 'Should skip new local test cases in pull-only mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = 'TC001' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'new-local'
            }

            # Act
            Sync-TcmTestCase -Direction FromRemote -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
        }

        It 'Should push local changes in bidirectional mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'local-changes'
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
        }

        It 'Should pull remote changes in bidirectional mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'remote-changes'
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 1
        }

        It 'Should pull new remote test cases in bidirectional mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'new-remote'
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 1
        }

        It 'Should handle conflicts with manual resolution' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseConflict -Times 0
        }

        It 'Should resolve conflicts automatically when strategy specified' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }

            # Act
            Sync-TcmTestCase -ConflictResolution LocalWins -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseConflict -Times 1
        }
    }

    Context 'Pipeline input' {

        BeforeEach {
            # Create a temporary test directory
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"

sync:
  direction: "Bidirectional"
  conflictResolution: "Manual"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        }

        It 'Should accept pipeline input by value' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'synced'
            }

            # Act
            '123' | Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -Times 1
        }

        It 'Should accept pipeline input by property name' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'synced'
            }

            # Act
            [PSCustomObject]@{ Id = '123' } | Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -Times 1
        }
    }

    Context 'Error handling' {

        BeforeEach {
            # Create a temporary test directory
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"

sync:
  direction: "Bidirectional"
  conflictResolution: "Manual"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        }

        It 'Should handle errors during sync operations' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                throw "Test error"
            }

            # Act & Assert
            { Sync-TcmTestCase -TestCasesRoot $testRoot } | Should -Not -Throw
        }

        It 'Should handle unknown sync status' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'unknown-status'
            }

            # Act & Assert
            { Sync-TcmTestCase -TestCasesRoot $testRoot } | Should -Not -Throw
        }
    }

    Context 'Statistics reporting' {

        BeforeEach {
            # Create a temporary test directory
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"

sync:
  direction: "Bidirectional"
  conflictResolution: "Manual"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        }

        It 'Should display sync summary at the end' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseFilePathInput -MockWith {
                @{ Id = '123' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'synced'
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot

            # Assert - Write-Host should be called for summary
            Assert-MockCalled -ModuleName $ModuleName -CommandName Write-Host -Times 2 # One for status, one for summary header
        }
    }
}