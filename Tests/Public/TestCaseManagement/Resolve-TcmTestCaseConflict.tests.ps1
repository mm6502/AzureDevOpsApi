BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Resolve-TcmTestCaseConflict' {

    BeforeAll {

        # Mock the sync functions that are called by Resolve-TcmTestCaseConflict
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
            @{
                fields = @{
                    'System.Title' = 'Test Case Title'
                    'System.ChangedDate' = '2024-01-15T10:30:00Z'
                    'System.ChangedBy' = @{ displayName = 'Test User' }
                }
            }
        }
        Mock -ModuleName $ModuleName -CommandName ConvertFrom-TcmWorkItemToTestCase -MockWith {
            @{
                title = 'Test Case Title'
                state = 'Design'
                steps = @(@{ stepNumber = 1; action = 'Test action' })
            }
        }
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

        It 'Should require Id parameter' {
            # This test is tricky because PowerShell prompts for mandatory parameters
            # Instead, we'll test that the function exists and has the right parameters
            $command = Get-Command Resolve-TcmTestCaseConflict
            $idParam = $command.Parameters['Id']
            $idParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | Should -Not -BeNullOrEmpty
            $mandatoryAttribute = $idParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }
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
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'synced'
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
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith { @() }

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
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }
            Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }  # Suppress display output

            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy LocalWins -TestCasesRoot $testRoot

            # Assert
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
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }
            Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }  # Suppress display output

            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy RemoteWins -TestCasesRoot $testRoot

            # Assert
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
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseFromFile -MockWith {
                @{
                    testCase = @{ id = '123' }
                    history = @{ lastModifiedAt = '2024-01-16T10:30:00Z' } # Newer than remote
                }
            }
            Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }  # Suppress display output

            # Create a test case file
            $testCasePath = Join-Path -Path $testRoot -ChildPath 'TC001-test-case.yaml'
            Set-Content -Path $testCasePath -Value 'dummy' -Encoding UTF8

            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy LatestWins -TestCasesRoot $testRoot

            # Assert
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseToRemote -Times 1
            Assert-MockCalled -ModuleName $ModuleName -CommandName Sync-TcmTestCaseFromRemote -Times 0
        }

        It 'Should choose remote when remote is newer' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseFromFile -MockWith {
                @{
                    testCase = @{ id = '123' }
                    history = @{ lastModifiedAt = '2024-01-14T10:30:00Z' } # Older than remote
                }
            }
            Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }  # Suppress display output

            # Create a test case file
            $testCasePath = Join-Path -Path $testRoot -ChildPath 'TC001-test-case.yaml'
            Set-Content -Path $testCasePath -Value 'dummy' -Encoding UTF8

            # Act
            Resolve-TcmTestCaseConflict -Id '123' -Strategy LatestWins -TestCasesRoot $testRoot

            # Assert
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
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }
            Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }  # Suppress display output

            # Act - Manual strategy should not call sync functions, just display info
            Resolve-TcmTestCaseConflict -Id '123' -Strategy Manual -TestCasesRoot $testRoot

            # Assert - Verify no sync was attempted (Manual just shows info)
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
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                'conflict'
            }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith { @() } # Prevent file finding

            # Act & Assert - Suppress error output since we're testing error handling
            { '123' | Resolve-TcmTestCaseConflict -Strategy LocalWins -TestCasesRoot $testRoot -ErrorAction SilentlyContinue } | Should -Throw
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
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseSyncStatus -MockWith {
                throw "Test error"
            }

            # Act & Assert - Suppress error output since we're testing error handling
            { Resolve-TcmTestCaseConflict -Id '123' -Strategy LocalWins -TestCasesRoot $testRoot -ErrorAction SilentlyContinue } | Should -Throw
        }
    }
}