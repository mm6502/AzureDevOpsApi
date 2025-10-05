BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-TcmTestCase' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
    }

    Context 'Folder structure creation' {

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

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        }

        It 'Should create test case in folder structure based on area path' {
            # Arrange
            $areaPath = "TestProject\Authentication\Login"
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'TestProject/Authentication/Login/'

            # Act
            $result = New-TcmTestCase -Id "TC001" -Title "Login Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.id | Should -Be "TC001"
            $result.testCase.areaPath | Should -Be $areaPath

            # Check that the file was created in the correct folder
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath 'TC001-login-test.yaml'
            Test-Path -Path $expectedFile | Should -Be $true
        }

        It 'Should create nested folder structure for multi-level area path' {
            # Arrange
            $areaPath = "TestProject\WebApp\API\Endpoints"
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'TestProject/WebApp/API/Endpoints/'

            # Act
            $result = New-TcmTestCase -Id "TC002" -Title "API Endpoint Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.areaPath | Should -Be $areaPath

            # Check folder structure was created
            Test-Path -Path $expectedFolder | Should -Be $true

            # Check file exists
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath 'TC002-api-endpoint-test.yaml'
            Test-Path -Path $expectedFile | Should -Be $true
        }

        It 'Should sanitize area path components for filesystem safety' {
            # Arrange
            $areaPath = 'TestProject\Feature: Login\Auth*Module'
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'TestProject/Feature__Login/Auth_Module/'

            # Act
            $result = New-TcmTestCase -Id "TC003" -Title "Special Chars Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty

            # Check sanitized folder was created
            Test-Path -Path $expectedFolder | Should -Be $true

            # Check file exists
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath 'TC003-special-chars-test.yaml'
            Test-Path -Path $expectedFile | Should -Be $true
        }

        It 'Should use default area path when none specified' {
            # Arrange
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'TestProject/'

            # Act
            $result = New-TcmTestCase -Id "TC004" -Title "Default Area Test" -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.areaPath | Should -Be "TestProject"

            # Check file was created in default area folder
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath 'TC004-default-area-test.yaml'
            Test-Path -Path $expectedFile | Should -Be $true
        }

        It 'Should handle single component area path' {
            # Arrange
            $areaPath = "SingleComponent"
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'SingleComponent/'

            # Act
            $result = New-TcmTestCase -Id "TC005" -Title "Single Component Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty

            # Check folder was created
            Test-Path -Path $expectedFolder | Should -Be $true

            # Check file exists
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath 'TC005-single-component-test.yaml'
            Test-Path -Path $expectedFile | Should -Be $true
        }
    }

    Context 'Error handling' {

        It 'Should throw error when test case with same ID already exists' {
            # Arrange
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCasesDuplicate'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8

            # Create first test case
            New-TcmTestCase -Id "TC007" -Title "First Test" -TestCasesRoot $testRoot | Out-Null

            # Act & Assert
            { New-TcmTestCase -Id "TC007" -Title "Duplicate Test" -TestCasesRoot $testRoot } | Should -Throw "*already exists*"
        }

        It 'Should allow overwrite with Force parameter' {
            # Arrange
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCasesForce'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"

testCase:
  defaultAreaPath: "TestProject"
  defaultIterationPath: "TestProject"
  defaultState: "Design"
  defaultPriority: 2
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8

            # Create first test case
            New-TcmTestCase -Id "TC008" -Title "Original Test" -TestCasesRoot $testRoot | Out-Null

            # Act - should not throw
            $result = New-TcmTestCase -Id "TC008" -Title "Updated Test" -TestCasesRoot $testRoot -Force

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.title | Should -Be "Updated Test"
        }
    }
}