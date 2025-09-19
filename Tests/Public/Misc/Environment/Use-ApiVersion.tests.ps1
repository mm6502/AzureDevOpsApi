BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Use-ApiVersion' {

    It 'Should return the global ApiVersion if set' {
        # Arrange
        $expected = '6.0'
        Mock -ModuleName $ModuleName -CommandName Use-Value -MockWith {
            $expected
        }
        # Act
        $result = Use-ApiVersion
        # Assert
        $result | Should -Be $expected
    }

    It 'Should return the default ApiVersion if global ApiVersion is not set' {
        # Arrange
        $expected = $null
        Mock -ModuleName $ModuleName -CommandName Use-Value -MockWith {
            $expected
        }
        # Act
        $result = Use-ApiVersion
        # Assert
        $result | Should -Be '5.0'
    }

    It 'Should return the default ApiVersion if given <name>' -ForEach @(
        @{ Name = '$null'; ApiVersion = $null }
        @{ Name = 'empty string'; ApiVersion = '' }
    ) {
        # Act
        $result = Use-ApiVersion -ApiVersion $ApiVersion
        # Assert
        $result | Should -Be '5.0'
    }

    It 'Should return the default ApiVersion not provided' {
        # Act
        $result = Use-ApiVersion
        # Assert
        $result | Should -Be '5.0'
    }

}
