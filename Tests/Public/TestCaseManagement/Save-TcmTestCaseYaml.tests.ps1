BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Save-TcmTestCaseYaml' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
    }

    Context 'Folder structure creation' {

        BeforeEach {
            # Create a temporary test directory
            $testRoot = Join-Path -Path $TestDrive -ChildPath "TestCases_$((New-Guid).Guid)"
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create test data
            $testCaseData = @{
                testCase = @{
                    id = "TC001"
                    title = "Test Case"
                    areaPath = "TestProject\Authentication\Login"
                }
                history = @{
                    createdAt = "2024-01-01T00:00:00Z"
                    createdBy = "testuser"
                }
            }

            # Create config (folder structure is always enabled)
            $config = @{
                TestCasesRoot = $testRoot
            }
        }

        It 'Should create folder structure' {
            # Arrange
            $fileName = "tc001-test-case.yaml"
            $fullPath = Join-Path -Path $testRoot -ChildPath $fileName
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'TestProject/Authentication/Login/'
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath $fileName

            # Act
            $result = Save-TcmTestCaseYaml -FilePath $fullPath -Data $testCaseData -TestCasesRoot $testRoot

            # Assert
            $result | Should -Be $expectedFile
            Test-Path -Path $expectedFolder | Should -Be $true
            Test-Path -Path $expectedFile | Should -Be $true
        }


        It 'Should handle null area path' {
            # Arrange
            $testCaseData.testCase.areaPath = $null
            $fileName = "tc001-test-case.yaml"
            $fullPath = Join-Path -Path $testRoot -ChildPath $fileName
            $expectedFile = $fullPath

            # Act
            $result = Save-TcmTestCaseYaml -FilePath $fullPath -Data $testCaseData -TestCasesRoot $testRoot

            # Assert
            $result | Should -Be $expectedFile
            Test-Path -Path $expectedFile | Should -Be $true
        }

        It 'Should handle empty area path' {
            # Arrange
            $testCaseData.testCase.areaPath = ""
            $fileName = "tc001-test-case.yaml"
            $fullPath = Join-Path -Path $testRoot -ChildPath $fileName
            $expectedFile = $fullPath

            # Act
            $result = Save-TcmTestCaseYaml -FilePath $fullPath -Data $testCaseData -TestCasesRoot $testRoot

            # Assert
            $result | Should -Be $expectedFile
            Test-Path -Path $expectedFile | Should -Be $true
        }

        It 'Should sanitize area path components' {
            # Arrange
            $testCaseData.testCase.areaPath = 'TestProject\Feature: Login\Auth*Module'
            $fileName = "tc001-test-case.yaml"
            $fullPath = Join-Path -Path $testRoot -ChildPath $fileName
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'TestProject/Feature__Login/Auth_Module/'
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath $fileName

            # Act
            $result = Save-TcmTestCaseYaml -FilePath $fullPath -Data $testCaseData -TestCasesRoot $testRoot

            # Assert
            $result | Should -Be $expectedFile
            Test-Path -Path $expectedFolder | Should -Be $true
            Test-Path -Path $expectedFile | Should -Be $true
        }

        It 'Should handle absolute file paths' {
            # Arrange
            $absolutePath = Join-Path -Path $testRoot -ChildPath 'custom-location.yaml'
            $expectedFolder = Join-Path -Path $testRoot -ChildPath 'TestProject/Authentication/Login/'
            $expectedFile = Join-Path -Path $expectedFolder -ChildPath 'custom-location.yaml'

            # Act
            $result = Save-TcmTestCaseYaml -FilePath $absolutePath -Data $testCaseData -TestCasesRoot $testRoot

            # Assert
            $result | Should -Be $expectedFile
            Test-Path -Path $expectedFolder | Should -Be $true
            Test-Path -Path $expectedFile | Should -Be $true
        }
    }

    Context 'YAML content validation' {

        It 'Should save valid YAML content' {
            # Arrange
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'YamlTest'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            $testCaseData = @{
                testCase = @{
                    id = "TC001"
                    title = "Test Case"
                    areaPath = "TestProject"
                }
                history = @{
                    createdAt = "2024-01-01T00:00:00Z"
                    createdBy = "testuser"
                }
            }

            $config = @{
                TestCasesRoot = $testRoot
            }

            $fullPath = Join-Path -Path $testRoot -ChildPath "test.yaml"

            # Act
            $result = Save-TcmTestCaseYaml -FilePath $fullPath -Data $testCaseData -TestCasesRoot $testRoot

            # Assert
            Test-Path -Path $result | Should -Be $true

            # Verify content can be parsed back
            $content = Get-Content -Path $result -Raw
            $parsed = ConvertFrom-Yaml $content
            $parsed.testCase.id | Should -Be "TC001"
            $parsed.testCase.title | Should -Be "Test Case"
        }
    }
}