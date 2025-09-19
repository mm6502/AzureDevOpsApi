[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Show-Parameters' {

    BeforeAll {
        Mock -ModuleName $ModuleName -CommandName Out-Host -MockWith { }
    }

    It 'Should output parameter information for a single parameter 1' {
        # Arrange
        $testParams = @{
            'TestParam' = 'TestValue'
        }

        Mock -ModuleName $ModuleName -CommandName Format-List { }

        # Act
        $output = Show-Parameters -Parameters $testParams

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Format-List -Times 1 -ParameterFilter {
            $InputObject.TestParam -eq 'TestValue'
        }
    }

    It 'Should output parameter information for a single parameter 2' {
        # Arrange
        $testParams = @{
            'TestParam' = 'TestValue'
        }

        # Act
        $output = Show-Parameters -Parameters $testParams

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Out-Host -Times 1
    }

    It 'Should handle empty parameter hashtable' {
        # Arrange
        $testParams = @{}

        # Act
        $output = Show-Parameters -Parameters $testParams | Out-String

        # Assert
        $output.Trim() | Should -BeNullOrEmpty
    }
}
