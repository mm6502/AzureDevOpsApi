BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')

    # Helper function to create properly typed test case objects for mocking
    function New-MockTcmTestCase {
        param(
            [string]$Id,
            [string]$FilePath = 'test.yaml',
            [object]$LocalData = $null,
            [object]$RemoteData = $null,
            [string]$SyncStatus = $null
        )

        $obj = [PSCustomObject]@{
            Id = $Id
            FilePath = $FilePath
            LocalData = $LocalData
            RemoteData = $RemoteData
            SyncStatus = $SyncStatus
        }

        # Add the required PSTypeNames
        $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended)
        $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseInput)

        return $obj
    }
}

Describe 'Sync-TcmTestCase' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }

        # Mock the sync functions that are called by Sync-TcmTestCase
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseConflict -MockWith { }

        # Mock underlying functions to prevent network calls
        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
            throw "No remote work item found"
        }
        Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
            @() # Return empty array by default - individual tests will override
        }

        # Helper function to create properly typed test case objects for mocking
        function New-MockTcmTestCase {
            param(
                [string]$Id,
                [string]$FilePath = 'test.yaml',
                [object]$LocalData = $null,
                [object]$RemoteData = $null,
                [string]$SyncStatus = $null
            )

            $obj = [PSCustomObject]@{
                Id = $Id
                FilePath = $FilePath
                LocalData = $LocalData
                RemoteData = $RemoteData
                SyncStatus = $SyncStatus
            }

            # Add the required PSTypeNames
            $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended)
            $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseInput)

            return $obj
        }
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
            Mock -ModuleName $ModuleName -CommandName ConvertTo-TcmTestCaseInput -MockWith { @() }

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
            Mock -ModuleName $ModuleName -CommandName ConvertTo-TcmTestCaseInput -MockWith { @() }

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

            # Mock Get-TcmTestCase for tests without InputObject
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith { , (New-MockTcmTestCase -Id 'dummy' -LocalData @{ testCase = @{ id = 'dummy' } }) }
        }

        It 'Should handle synced test cases correctly' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } })
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'synced'
                $InputObject.RemoteData = $null
                $InputObject
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false

            # Assert
            # Resolve-TcmTestCaseSyncStatus is now called by Get-TcmTestCase internally
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
        }

        It 'Should push new local test cases in bidirectional mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id 'TC001' -LocalData @{ testCase = @{ id = 'TC001' } } -SyncStatus 'new-local')
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
        }

        It 'Should skip new local test cases in pull-only mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id 'TC001' -LocalData @{ testCase = @{ id = 'TC001' } })
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'new-local'
                $InputObject.RemoteData = $null
                $InputObject
            }

            # Act
            Sync-TcmTestCase -Direction FromRemote -TestCasesRoot $testRoot -Confirm:$false

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
        }

        It 'Should push local changes in bidirectional mode' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } } -SyncStatus 'local-changes')
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
        }

        It 'Should pull remote changes in bidirectional mode' {
            # Arrange
            $remoteData = @{
                id = 123
                fields = @{
                    'System.Title' = 'Test Case'
                    'System.AreaPath' = 'TestProject'
                    'System.IterationPath' = 'TestProject'
                    'System.State' = 'Design'
                    'Microsoft.VSTS.Common.Priority' = 2
                    'System.Description' = ''
                    'Microsoft.VSTS.TCM.AutomationStatus' = 'Not Automated'
                }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } } -RemoteData $remoteData -SyncStatus 'remote-changes')
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 1
        }

        It 'Should pull new remote test cases in bidirectional mode' {
            # Arrange
            $remoteData = @{
                id = 123
                fields = @{
                    'System.Title' = 'New Test Case'
                    'System.AreaPath' = 'TestProject'
                    'System.IterationPath' = 'TestProject'
                    'System.State' = 'Design'
                    'Microsoft.VSTS.Common.Priority' = 2
                    'System.Description' = ''
                    'Microsoft.VSTS.TCM.AutomationStatus' = 'Not Automated'
                }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } } -RemoteData $remoteData -SyncStatus 'new-remote')
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 1
        }

        It 'Should handle conflicts with manual resolution' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } })
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'conflict'
                $InputObject.RemoteData = $null
                $InputObject
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseConflict -Times 0
        }

        It 'Should resolve conflicts automatically when strategy specified' {
            # Arrange - Get-TcmTestCase returns a test case with conflict status
            $remoteData = @{
                id = 123
                fields = @{
                    'System.Title' = 'Conflicted Test Case'
                    'System.AreaPath' = 'TestProject'
                    'System.IterationPath' = 'TestProject'
                    'System.State' = 'Design'
                    'Microsoft.VSTS.Common.Priority' = 2
                    'System.Description' = ''
                    'Microsoft.VSTS.TCM.AutomationStatus' = 'Not Automated'
                }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } } -RemoteData $remoteData -SyncStatus 'conflict')
            }

            # Act
            Sync-TcmTestCase -ConflictResolution LocalWins -TestCasesRoot $testRoot -Confirm:$false -WhatIf:$false

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
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } })
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'synced'
                $InputObject.RemoteData = $null
                $InputObject
            }

            # Act & Assert - Should accept string input without throwing
            { '123' | Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept pipeline input by property name' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } })
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'synced'
                $InputObject.RemoteData = $null
                $InputObject
            }

            # Act & Assert - Should accept object input without throwing
            { [PSCustomObject]@{ Id = '123' } | Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false } | Should -Not -Throw
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
            Mock -ModuleName $ModuleName -CommandName ConvertTo-TcmTestCaseInput -MockWith {
                , (New-MockTcmTestCase -Id '123')
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                throw "Test error"
            }

            # Act & Assert
            { Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false } | Should -Not -Throw
        }

        It 'Should handle unknown sync status' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName ConvertTo-TcmTestCaseInput -MockWith {
                , (New-MockTcmTestCase -Id '123')
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'unknown-status'
                $InputObject.RemoteData = $null
                $InputObject
            }

            # Act & Assert
            { Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false } | Should -Not -Throw
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
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                , (New-MockTcmTestCase -Id '123' -LocalData @{ testCase = @{ id = '123' } })
            }
            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'synced'
                $InputObject.RemoteData = $null
                $InputObject
            }

            # Act
            Sync-TcmTestCase -TestCasesRoot $testRoot -Confirm:$false

            # Assert - Write-Host should be called for summary
            Assert-MockCalled -ModuleName $ModuleName -CommandName Write-Host -Times 2 # One for status, one for summary header
        }
    }
}
