BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-TcmTestCase' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        $script:dirSep = [System.IO.Path]::DirectorySeparatorChar
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

            # Act
            $result = New-TcmTestCase -Id "TC001" -Title "Login Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.id | Should -Be "TC001"
            $result.testCase.areaPath | Should -Be $areaPath

            # Check that the file was created and path contains the area path components
            $result.FilePath | Should -Not -BeNullOrEmpty
            Test-Path -Path $result.FilePath | Should -Be $true
            $result.FilePath | Should -Match ([regex]::Escape("TestProject"))
            $result.FilePath | Should -Match ([regex]::Escape("Authentication"))
            $result.FilePath | Should -Match ([regex]::Escape("Login"))
            $result.FilePath | Should -Match ([regex]::Escape("TC001-login-test.yaml"))
        }

        It 'Should create nested folder structure for multi-level area path' {
            # Arrange
            $areaPath = "TestProject\WebApp\API\Endpoints"

            # Act
            $result = New-TcmTestCase -Id "TC002" -Title "API Endpoint Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.areaPath | Should -Be $areaPath

            # Check file was created with area path components in the path
            $result.FilePath | Should -Not -BeNullOrEmpty
            Test-Path -Path $result.FilePath | Should -Be $true
            $result.FilePath | Should -Match ([regex]::Escape("TestProject"))
            $result.FilePath | Should -Match ([regex]::Escape("WebApp"))
            $result.FilePath | Should -Match ([regex]::Escape("API"))
            $result.FilePath | Should -Match ([regex]::Escape("Endpoints"))
        }

        It 'Should sanitize area path components for filesystem safety' {
            # Arrange
            $areaPath = 'TestProject\Feature: Login\Auth*Module'

            # Act
            $result = New-TcmTestCase -Id "TC003" -Title "Special Chars Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty

            # Check file was created with sanitized folder names
            $result.FilePath | Should -Not -BeNullOrEmpty
            Test-Path -Path $result.FilePath | Should -Be $true
            $result.FilePath | Should -Match ([regex]::Escape("TestProject"))
            $result.FilePath | Should -Match ([regex]::Escape("Feature__Login"))
            $result.FilePath | Should -Match ([regex]::Escape("Auth_Module"))
        }

        It 'Should use default area path when none specified' {
            # Arrange & Act
            $result = New-TcmTestCase -Id "TC004" -Title "Default Area Test" -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.areaPath | Should -Be "TestProject"

            # Check file was created in default area folder
            $result.FilePath | Should -Not -BeNullOrEmpty
            Test-Path -Path $result.FilePath | Should -Be $true
            $result.FilePath | Should -Match ([regex]::Escape("TestProject"))
            $result.FilePath | Should -Match ([regex]::Escape("TC004-default-area-test.yaml"))
        }

        It 'Should handle single component area path' {
            # Arrange
            $areaPath = "SingleComponent"
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'SingleComponent'

            # Act
            $result = New-TcmTestCase -Id "TC005" -Title "Single Component Test" -AreaPath $areaPath -TestCasesRoot $testRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty

            # The file path returned should be absolute and exist
            $result.FilePath | Should -Not -BeNullOrEmpty
            Test-Path -Path $result.FilePath | Should -Be $true

            # The file should be in the SingleComponent subfolder
            $result.FilePath | Should -Match ([regex]::Escape("SingleComponent"))
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
