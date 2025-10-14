BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TcmTestCase' {

    BeforeEach {
        # Create a unique temporary test directory for each test
        $testId = [guid]::NewGuid().ToString()
        $script:testRoot = Join-Path -Path $TestDrive -ChildPath "TestCases_$testId"
        New-Item -Path $script:testRoot -ItemType Directory -Force | Out-Null

        # Create a test config file
        $configPath = Join-Path -Path $script:testRoot -ChildPath '.tcm-config.yaml'
        $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test-org"
  project: "TestProject"
  pat: "dummy-pat"

sync:
  direction: "bidirectional"
  conflictResolution: "manual"
  excludePatterns:
    - "**/*-draft.yaml"
    - ".metadata/"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
        Set-Content -Path $configPath -Value $configContent -Encoding UTF8

        # Mock Azure DevOps API calls for all tests
        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
            [PSCustomObject]@{
                id = 123
                fields = [PSCustomObject]@{
                    'System.WorkItemType' = 'Test Case'
                    'System.Id' = 123
                    'System.Title' = 'Test Case 1'
                    'System.AreaPath' = 'TestProject'
                    'System.State' = 'Design'
                    'Microsoft.VSTS.Common.Priority' = 2
                }
            }
        }
        Mock -ModuleName $ModuleName -CommandName ConvertFrom-TcmWorkItemToTestCase -MockWith {
            [ordered]@{
                id = 123
                title = 'Test Case 1'
                areaPath = 'TestProject'
                state = 'Design'
                priority = 2
                assignedTo = ''
                tags = @()
                description = ''
                preconditions = ''
                steps = @([ordered]@{stepNumber=1; attachments=@(); action=''; expectedResult=''})
                automationStatus = 'Not Automated'
                customFields = @{}
            }
        }
        Mock -ModuleName $ModuleName -CommandName Get-TcmStringHash -MockWith {
            'mocked-remote-data-hash-value'
        }
    }

    Context 'Parameter validation and configuration' {

        It 'Should load configuration correctly' {
            # Act
            $result = @(Get-TcmTestCase -TestCasesRoot $script:testRoot)

            # Assert - should return empty array when no files exist
            $result.Count | Should -Be 0
        }

        It 'Should use default parameter set when no parameters specified' {
            # Act
            $result = @(Get-TcmTestCase -TestCasesRoot $script:testRoot)

            # Assert
            $result.Count | Should -Be 0
        }
    }

    Context 'Loading by path' {

        It 'Should load test case by relative path' {
            # Arrange
            $testCasePath = Join-Path -Path $script:testRoot -ChildPath 'TC001-test-case.yaml'
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

            # Act
            $result = Get-TcmTestCase -Path 'TC001-test-case.yaml' -TestCasesRoot $script:testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.LocalData.id | Should -Be "123"
            $result.LocalData.title | Should -Be "Test Case Title"
        }

        It 'Should throw when file does not exist' {
            # Act & Assert
            { Get-TcmTestCase -Path 'nonexistent.yaml' -TestCasesRoot $script:testRoot -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Loading by ID' {

        It 'Should load test case by ID' {

            # Act
            $result = Get-TcmTestCase -Id '123' -TestCasesRoot $script:testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.RemoteData.id | Should -Be 123
            $result.RemoteData.title | Should -Be "Test Case 1"
            $result.RemoteDataHash | Should -Be 'mocked-remote-data-hash-value'
        }

        It 'Should throw when ID is not found' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
                throw "Work item 999 not found"
            }

            # Act & Assert
            { Get-TcmTestCase -Id '999' -TestCasesRoot $script:testRoot -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Loading all test cases' {

        It 'Should load all test cases' {
            # Arrange
            $subdir = Join-Path -Path $script:testRoot -ChildPath 'testcases'
            New-Item -Path $subdir -ItemType Directory -Force | Out-Null

            $testCase1Path = Join-Path -Path $subdir -ChildPath 'TC001-test-case.yaml'
            $testCase1Content = @"
testCase:
  id: "123"
  title: "Test Case 1"
  areaPath: "TestProject"
  state: "Design"

history:
  lastModifiedAt: "2024-01-15T09:00:00Z"
  lastModifiedBy: "Test User"
"@
            Set-Content -Path $testCase1Path -Value $testCase1Content -Encoding UTF8

            $testCase2Path = Join-Path -Path $subdir -ChildPath 'TC002-another-test.yaml'
            $testCase2Content = @"
testCase:
  id: "124"
  title: "Test Case 2"
  areaPath: "TestProject"
  state: "Ready"

history:
  lastModifiedAt: "2024-01-16T10:00:00Z"
  lastModifiedBy: "Another User"
"@
            Set-Content -Path $testCase2Path -Value $testCase2Content -Encoding UTF8

            # Create a draft file that should be excluded
            $draftPath = Join-Path -Path $subdir -ChildPath 'TC003-test-case-draft.yaml'
            $draftContent = @"
testCase:
  id: "125"
  title: "Draft Test Case"
  areaPath: "TestProject"
  state: "Design"
"@
            Set-Content -Path $draftPath -Value $draftContent -Encoding UTF8

            # Act
            $result = Get-TcmTestCase -TestCasesRoot $script:testRoot

            # Assert
            $result | Should -HaveCount 3
            $result.LocalData.id | Should -Contain "123"
            $result.LocalData.id | Should -Contain "124"
            $result.LocalData.id | Should -Contain "125" # Draft is now included
        }

        It 'Should load all files including draft files' {
            # Arrange
            $subdir = Join-Path -Path $script:testRoot -ChildPath 'testcases'
            New-Item -Path $subdir -ItemType Directory -Force | Out-Null

            $testCase1Path = Join-Path -Path $subdir -ChildPath 'TC001-test-case.yaml'
            $testCase1Content = @"
testCase:
  id: "123"
  title: "Test Case 1"
  areaPath: "TestProject"
  state: "Design"
"@
            Set-Content -Path $testCase1Path -Value $testCase1Content -Encoding UTF8

            # Draft files are now included (no exclude pattern filtering)
            $draftPath = Join-Path -Path $subdir -ChildPath 'TC002-draft.yaml'
            $draftContent = @"
testCase:
  id: "125"
  title: "Draft Test Case"
  areaPath: "TestProject"
  state: "Design"
"@
            Set-Content -Path $draftPath -Value $draftContent -Encoding UTF8

            # Act
            $result = @(Get-TcmTestCase -TestCasesRoot $script:testRoot)

            # Assert
            $result.Count | Should -Be 2
            $result.LocalData.title | Should -Contain "Test Case 1"
            $result.LocalData.title | Should -Contain "Draft Test Case"
        }

        It 'Should always exclude config file' {
            # Arrange - The config file should always be excluded automatically
            $testCasePath = Join-Path -Path $script:testRoot -ChildPath 'TC001-test-case.yaml'
            $testCaseContent = @"
testCase:
  id: "123"
  title: "Test Case 1"
  areaPath: "TestProject"
  state: "Design"
"@
            Set-Content -Path $testCasePath -Value $testCaseContent -Encoding UTF8

            # Act
            $result = @(Get-TcmTestCase -TestCasesRoot $script:testRoot)

            # Assert - should not try to parse the config file
            $result.Count | Should -Be 1 # Only the valid test case
            $result[0].LocalData.id | Should -Be "123"
        }

        It 'Should handle invalid YAML files gracefully' {
            # Arrange
            $testCasePath = Join-Path -Path $script:testRoot -ChildPath 'TC001-test-case.yaml'
            $testCaseContent = @"
testCase:
  id: "123"
  title: "Test Case 1"
  areaPath: "TestProject"
  state: "Design"
"@
            Set-Content -Path $testCasePath -Value $testCaseContent -Encoding UTF8

            # Create an invalid YAML file
            $invalidPath = Join-Path -Path $script:testRoot -ChildPath 'invalid.yaml'
            Set-Content -Path $invalidPath -Value 'invalid: yaml: content: [' -Encoding UTF8

            # Act
            $result = @(Get-TcmTestCase -TestCasesRoot $script:testRoot -ErrorAction SilentlyContinue)

            # Assert - should still return valid test cases
            $result.Count | Should -Be 1
            $result[0].LocalData.id | Should -Be "123"
        }

        It 'Should return empty array when no test cases exist' {
            # Act
            $result = @(Get-TcmTestCase -TestCasesRoot $script:testRoot)

            # Assert
            $result.Count | Should -Be 0
        }
    }

    Context 'Error handling' {

        It 'Should throw when configuration file is missing' {
            # Arrange
            $testRootNoConfig = Join-Path -Path $TestDrive -ChildPath 'NoConfig'
            New-Item -Path $testRootNoConfig -ItemType Directory -Force | Out-Null

            # Act & Assert
            { Get-TcmTestCase -TestCasesRoot $testRootNoConfig } | Should -Throw "*Configuration file not found*"
        }

        It 'Should throw when configuration is invalid' {
            # Arrange
            $testRootBadConfig = Join-Path -Path $TestDrive -ChildPath 'BadConfig'
            New-Item -Path $testRootBadConfig -ItemType Directory -Force | Out-Null

            $badConfigPath = Join-Path -Path $testRootBadConfig -ChildPath '.tcm-config.yaml'
            Set-Content -Path $badConfigPath -Value 'invalid: yaml: [[[' -Encoding UTF8

            # Act & Assert
            { Get-TcmTestCase -TestCasesRoot $testRootBadConfig } | Should -Throw "*Failed to parse configuration*"
        }
    }
}
