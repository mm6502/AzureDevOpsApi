BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'Get-TcmTestCaseFromFile' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Error -MockWith { }
    }

    Context 'File loading' {

        It 'Should load and parse YAML file correctly' {
            # Arrange
            $testFilePath = Join-Path -Path $TestDrive -ChildPath 'TC001.yaml'
            $yamlContent = @"
testCase:
  id: 123
  title: "Test Case Title"
  steps:
    - stepNumber: 1
      action: "Do something"
      expectedResult: "Something happens"
history:
  lastModifiedAt: "2024-01-15T10:30:00Z"
"@

            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName Get-Content -MockWith { $yamlContent }
            Mock -ModuleName $ModuleName -CommandName ConvertFrom-Yaml -MockWith {
                @{
                    testCase = @{ id = 123; title = "Test Case Title"; steps = @(@{ stepNumber = 1; action = "Do something"; expectedResult = "Something happens" }) }
                    history = @{ lastModifiedAt = "2024-01-15T10:30:00Z" }
                }
            }

            # Act
            $result = Get-TcmTestCaseFromFile -FilePath $testFilePath

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.id | Should -Be 123
            $result.testCase.title | Should -Be "Test Case Title"
        }

        It 'Should handle invalid YAML gracefully' {
            # Arrange
            $testFilePath = Join-Path -Path $TestDrive -ChildPath 'TC001.yaml'
            Mock -ModuleName $ModuleName -CommandName Get-Content -MockWith { "invalid: yaml: content: [" }
            Mock -ModuleName $ModuleName -CommandName ConvertFrom-Yaml -MockWith { throw "YAML parse error" }

            # Act & Assert
            { Get-TcmTestCaseFromFile -FilePath $testFilePath } | Should -Throw
        }
    }
}
