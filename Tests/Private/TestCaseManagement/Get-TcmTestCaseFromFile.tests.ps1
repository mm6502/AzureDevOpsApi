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
            $result = Get-TcmTestCaseFromFile -FilePath 'C:\temp\TC001.yaml'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCase.id | Should -Be 123
            $result.testCase.title | Should -Be "Test Case Title"
        }

        It 'Should include metadata when requested' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName Get-Content -MockWith { "testCase: { id: 123 }\nhistory: { lastModifiedAt: '2024-01-15T10:30:00Z' }" }
            Mock -ModuleName $ModuleName -CommandName ConvertFrom-Yaml -MockWith {
                @{ testCase = @{ id = 123 }; history = @{ lastModifiedAt = "2024-01-15T10:30:00Z" } }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmRelativeTestCasePath -MockWith { "TC001.yaml" }

            # Act
            $result = Get-TcmTestCaseFromFile -FilePath 'C:\temp\TC001.yaml' -IncludeMetadata

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.history | Should -Not -BeNullOrEmpty
            $result.history.lastModifiedAt | Should -Be "2024-01-15T10:30:00Z"
        }

        It 'Should handle invalid YAML gracefully' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-Content -MockWith { "invalid: yaml: content: [" }
            Mock -ModuleName $ModuleName -CommandName ConvertFrom-Yaml -MockWith { throw "YAML parse error" }

            # Act & Assert
            { Get-TcmTestCaseFromFile -FilePath 'C:\temp\TC001.yaml' } | Should -Throw
        }
    }
}