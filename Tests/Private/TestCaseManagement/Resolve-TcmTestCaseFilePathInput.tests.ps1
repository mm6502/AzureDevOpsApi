BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'Resolve-TcmTestCaseFilePathInput' {

    Context 'Path resolution' {

        It 'Should handle string input' {
            # Arrange
            $filePath = 'C:\TestCases\TC001.yaml'
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseFromFile -MockWith {
                @{ testCase = @{ id = '123' }; FilePath = $filePath }
            }

            # Act
            $result = Resolve-TcmTestCaseFilePathInput -InputObject $filePath -TestCasesRoot 'C:\TestCases'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.FilePath | Should -Be $filePath
        }
    }
}