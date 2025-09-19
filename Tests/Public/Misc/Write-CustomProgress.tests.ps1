BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Write-CustomProgress' {

    It 'Should call Write-Progress with correct parameters' {
        # Arrange
        $expected = @{
            Activity = 'Test Activity'
            Status   = 'Test Status'
            Count    = 100
            Index    = 50
        }

        # Act
        Write-CustomProgress @expected

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Write-Progress -Times 1 -ParameterFilter {
            ($Activity -eq $expected.Activity) -and
            ($Status -like "*$($expected.Status)*")
        }
    }
}
