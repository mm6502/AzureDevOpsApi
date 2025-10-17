BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Resolve-TcmTestCaseConflict' {

    BeforeAll {

        # Helper function to create mock test case objects
        function New-MockTestCaseObject {
            param(
                [string]$Id = '123',
                [string]$SyncStatus = 'conflict',
                [string]$LocalLastModified = '2024-01-15T09:00:00Z',
                [string]$RemoteChangedDate = '2024-01-15T10:30:00Z',
                [string]$FilePath = $null
            )

            if (-not $FilePath) {
                $FilePath = Join-Path -Path $TestDrive -ChildPath "$Id.yaml"
            }

            $obj = [PSCustomObject]@{
                Id = $Id
                SyncStatus = $SyncStatus
                FilePath = $FilePath
                LocalData = @{
                    id = $Id
                    title = 'Test Case Title'
                    state = 'Design'
                    steps = @(@{ stepNumber = 1; action = 'Test action'; expectedResult = 'Expected' })
                    history = @{
                        lastModifiedAt = $LocalLastModified
                        lastModifiedBy = 'Test User'
                    }
                }
                RemoteData = @{
                    id = $Id
                    title = 'Test Case Title'
                    state = 'Design'
                    steps = @(@{ stepNumber = 1; action = 'Test action'; expectedResult = 'Expected' })
                }
                RemoteWorkItem = @{
                    id = [int]$Id
                    fields = @{
                        'System.WorkItemType' = 'Test Case'
                        'System.Title' = 'Test Case Title'
                        'System.ChangedDate' = $RemoteChangedDate
                        'System.ChangedBy' = @{ displayName = 'Test User' }
                    }
                }
            }

            $obj.PSTypeNames.Insert(0, 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')
            return $obj
        }

        # Mock Get-TcmTestCase to return properly structured test case objects
        Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
            param($InputObject, $Id, $TestCasesRoot)
            $testId = if ($InputObject) { $InputObject } elseif ($Id) { $Id } else { '123' }
            New-MockTestCaseObject -Id $testId
        }

        # Mock the sync functions that are called by Resolve-TcmTestCaseConflict
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
    }

    Context 'Parameter validation' {

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

        It 'Should require InputObject parameter' {
            # This test is tricky because PowerShell prompts for mandatory parameters
            # Instead, we'll test that the function exists and has the right parameters
            $command = Get-Command Resolve-TcmTestCaseConflict
            $inputParam = $command.Parameters['InputObject']
            $inputParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | Should -Not -BeNullOrEmpty
            $mandatoryAttribute = $inputParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }
            $mandatoryAttribute | Should -Not -BeNullOrEmpty
        }

        It 'Should require Strategy parameter' {
            # Similar approach for Strategy parameter
            $command = Get-Command Resolve-TcmTestCaseConflict
            $strategyParam = $command.Parameters['Strategy']
            $strategyParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | Should -Not -BeNullOrEmpty
            $mandatoryAttribute = $strategyParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }
            $mandatoryAttribute | Should -Not -BeNullOrEmpty
        }

        It 'Should validate Strategy parameter values' {
            # Test that the ValidateSet attribute is present
            $command = Get-Command Resolve-TcmTestCaseConflict
            $strategyParam = $command.Parameters['Strategy']
            $validateSetAttribute = $strategyParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSetAttribute | Should -Not -BeNullOrEmpty
            $validateSetAttribute.ValidValues | Should -Contain 'Manual'
            $validateSetAttribute.ValidValues | Should -Contain 'LocalWins'
            $validateSetAttribute.ValidValues | Should -Contain 'RemoteWins'
            $validateSetAttribute.ValidValues | Should -Contain 'LatestWins'
        }
    }

    Context 'Conflict detection' {

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

        It 'Should warn when test case does not have a conflict' {
            # Arrange
            $testFilePath = Join-Path -Path $TestDrive -ChildPath '123.yaml'
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                [PSCustomObject]@{
                    Id = '123'
                    SyncStatus = 'synced'
                    LocalData = @{ id = '123'; title = 'Test' }
                    RemoteData = @{ id = '123'; title = 'Test' }
                    RemoteWorkItem = @{
                        fields = @{
                            'System.WorkItemType' = 'Test Case'
                            'System.Title' = 'Test'
                            'System.ChangedDate' = '2024-01-15T10:30:00Z'
                            'System.ChangedBy' = @{ displayName = 'Test User' }
                        }
                    }
                    FilePath = $testFilePath
                }
            }

            # Act - Capture warning output
            $warnings = @()
            Resolve-TcmTestCaseConflict -Id '123' -Strategy LocalWins -TestCasesRoot $testRoot -WarningVariable warnings -WarningAction SilentlyContinue

            # Assert - Verify warning was issued and sync was not called
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -Match "does not have a conflict"
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
        }

        It 'Should throw when test case file is not found' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                throw "Work item 123 is not a Test Case (type: )"
            }

            # Act & Assert - Suppress error output since we're testing error handling
            { Resolve-TcmTestCaseConflict -Id '123' -Strategy LocalWins -TestCasesRoot $testRoot -ErrorAction SilentlyContinue } | Should -Throw
        }
    }

    Context 'LocalWins strategy' {

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

            # Create a test case file
            $testCasePath = Join-Path -Path $testRoot -ChildPath 'TC001-test-case.yaml'
            $testCaseContent = @"
testCase:
  id: "123"
  title: "Test Case Title"
  areaPath: "TestProject"
  state: "Design"

history:
  lastModifiedAt: "2024-01-15T09:00:00Z"
  lastModifiedBy: "Test User"
"@
            Set-Content -Path $testCasePath -Value $testCaseContent -Encoding UTF8
        }

        It 'Should call Sync-TcmTestCaseToRemote for LocalWins strategy' {
            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy LocalWins -TestCasesRoot $testRoot

            # Assert
            # Resolve-TcmTestCaseSyncStatus is now called internally by Get-TcmTestCase
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
        }
    }

    Context 'RemoteWins strategy' {

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

            # Create a test case file
            $testCasePath = Join-Path -Path $testRoot -ChildPath 'TC001-test-case.yaml'
            $testCaseContent = @"
testCase:
  id: "123"
  title: "Test Case Title"
  areaPath: "TestProject"
  state: "Design"

history:
  lastModifiedAt: "2024-01-15T09:00:00Z"
  lastModifiedBy: "Test User"
"@
            Set-Content -Path $testCasePath -Value $testCaseContent -Encoding UTF8
        }

        It 'Should call Sync-TcmTestCaseFromRemote for RemoteWins strategy' {
            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy RemoteWins -TestCasesRoot $testRoot

            # Assert
            # Resolve-TcmTestCaseSyncStatus is now called internally by Get-TcmTestCase
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 1
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
        }
    }

    Context 'LatestWins strategy' {

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

        It 'Should choose local when local is newer' {
            # Arrange - Mock Get-TcmTestCase to return a test case where local is newer
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                New-MockTestCaseObject -SyncStatus 'conflict' -LocalLastModified '2024-01-16T10:30:00Z' -RemoteChangedDate '2024-01-15T10:30:00Z'
            }

            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy LatestWins -TestCasesRoot $testRoot

            # Assert
            # Resolve-TcmTestCaseSyncStatus is now called internally by Get-TcmTestCase
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
        }

        It 'Should choose remote when remote is newer' {
            # Arrange - Mock Get-TcmTestCase to return a test case where remote is newer
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                New-MockTestCaseObject -SyncStatus 'conflict' -LocalLastModified '2024-01-14T10:30:00Z' -RemoteChangedDate '2024-01-15T10:30:00Z'
            }
            Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }  # Suppress display output

            # Create a test case file
            $testCasePath = Join-Path -Path $testRoot -ChildPath 'TC001-test-case.yaml'
            Set-Content -Path $testCasePath -Value 'dummy' -Encoding UTF8

            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy LatestWins -TestCasesRoot $testRoot

            # Assert - Remote is newer, so we should sync FROM remote
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 1
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
        }
    }

    Context 'Manual strategy' {

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

            # Create a test case file
            $testCasePath = Join-Path -Path $testRoot -ChildPath 'TC001-test-case.yaml'
            $testCaseContent = @"
testCase:
  id: "123"
  title: "Test Case Title"
  areaPath: "TestProject"
  state: "Design"

history:
  lastModifiedAt: "2024-01-15T09:00:00Z"
  lastModifiedBy: "Test User"
"@
            Set-Content -Path $testCasePath -Value $testCaseContent -Encoding UTF8
        }

        It 'Should display conflict information for Manual strategy' {
            # Act - Manual strategy should not call sync functions, just display info
            Resolve-TcmTestCaseConflict -Id '123' -Strategy Manual -TestCasesRoot $testRoot

            # Assert - Verify no sync was attempted (Manual just shows info)
            # Resolve-TcmTestCaseSyncStatus is now called internally by Get-TcmTestCase
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 0
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
            # Verify Write-Host was called to display conflict info
            Assert-MockCalled -ModuleName $ModuleName -CommandName Write-Host -Times 1 -ParameterFilter { $Object -like "*Conflict Details*" }
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

        It 'Should accept pipeline input' {
            # Act & Assert
            # Pipeline input should work with the mocked Get-TcmTestCase
            { '123' | Resolve-TcmTestCaseConflict -Strategy LocalWins -TestCasesRoot $testRoot } | Should -Not -Throw
            # Resolve-TcmTestCaseSyncStatus is now called internally by Get-TcmTestCase
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
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

        It 'Should handle errors during conflict resolution' {
            # Arrange - Mock Get-TcmTestCase to throw an error
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCase -MockWith {
                throw "Test error"
            }

            # Act & Assert - Suppress error output since we're testing error handling
            { Resolve-TcmTestCaseConflict -Id '123' -Strategy LocalWins -TestCasesRoot $testRoot -ErrorAction SilentlyContinue } | Should -Throw
        }
    }
}
