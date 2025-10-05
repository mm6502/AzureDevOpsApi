BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'Get-TcmTestCaseConfig' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Error -MockWith { }
    }

    Context 'Configuration loading' {

        It 'Should return config when file exists' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName Get-Content -MockWith { "testCasesRoot: 'C:\\temp'" }
            Mock -ModuleName $ModuleName -CommandName ConvertFrom-Yaml -MockWith { @{ testCasesRoot = 'C:\temp' } }

            # Act
            $result = Get-TcmTestCaseConfig -TestCasesRoot 'C:\temp'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.testCasesRoot | Should -Be 'C:\temp'
        }
    }
}