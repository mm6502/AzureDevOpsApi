BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Show-Host' {

    BeforeAll {
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
    }

    It 'Should call Write-Host with the provided object' {
        # Arrange
        $testObject = 'Test message'
        # Act
        Show-Host -Object $testObject
        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Write-Host -ParameterFilter {
            $Object -eq $testObject
        }
    }

    It 'Should pass ForegroundColor parameter to Write-Host' {
        # Arrange
        $testColor = [ConsoleColor]::Red
        # Act
        Show-Host -Object 'Test' -ForegroundColor $testColor
        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Write-Host -ParameterFilter {
            $ForegroundColor -eq $testColor
        }
    }

    It 'Should pass NoNewLine switch to Write-Host' {
        # Act
        Show-Host -Object 'Test' -NoNewLine
        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Write-Host -ParameterFilter {
            $NoNewLine -eq $true
        }
    }

    It 'Should handle pipeline input' {
        # Act
        'Pipeline test' | Show-Host
        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Write-Host -ParameterFilter {
            $Object -eq 'Pipeline test'
        }
    }

    It 'Should handle multiple pipeline inputs' {
        # Arrange
        $testObjects = @('Test1', 'Test2', 'Test3')
        # Act
        $testObjects | Show-Host
        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Write-Host -Times 3
    }

    It 'Should handle empty input' {
        # Act
        Show-Host
        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Write-Host -ParameterFilter {
            $Object -eq $null
        }
    }
}
