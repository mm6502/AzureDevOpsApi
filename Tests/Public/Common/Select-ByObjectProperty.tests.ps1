[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Select-ByObjectProperty' {

    BeforeAll {

        $john = [PSCustomObject]@{
            Name    = "John"
            Age     = 30
            Address = [PSCustomObject]@{
                City    = "New York"
                Country = "USA"
            }
        }

        $jane = [PSCustomObject]@{
            Name    = "Jane"
            Age     = 25
            Address = [PSCustomObject]@{
                City    = "London"
                Country = "UK"
            }
        }

        $bob = [PSCustomObject]@{
            Name    = "Bob"
            Age     = 35
            Address = [PSCustomObject]@{
                City    = "Paris"
                Country = "France"
            }
        }

        $testObjects = @(
            $john, $jane, $bob
        )
    }

    It 'Should filter objects based on a single property' {
        # Arrange
        $expected = @($john, $jane)
        # Act
        $result = $testObjects | Select-ByObjectProperty -Property 'Name' -Pattern 'J*'
        # Assert
        $result | Should -Be $expected
    }

    It 'Should filter objects based on multiple properties' {
        # Arrange
        $expected = @($jane)
        # Act
        $result = $testObjects | Select-ByObjectProperty -Property 'Name', 'Age' -Pattern '*a*', '25'
        # Assert
        $result | Should -Be $expected
    }

    It 'Should filter objects based on nested properties' {
        # Arrange
        $expected = @($john, $jane)
        # Act
        $result = $testObjects | Select-ByObjectProperty -Property 'Address.Country' -Pattern 'U*'
        # Assert
        $result | Should -Be $expected
    }

    It 'Should return all objects when no property is specified' {
        # Arrange
        $expected = @($john, $jane, $bob)
        # Act
        $result = $testObjects | Select-ByObjectProperty -Pattern '*'
        # Assert
        $result | Should -Be $expected
    }

    It 'Should return no objects when pattern does not match' {
        # Arrange
        $expected = @()
        # Act
        $result = $testObjects | Select-ByObjectProperty -Property 'Name' -Pattern 'Z*'
        # Assert
        $result | Should -Be $expected
    }

    It 'Should handle null input' {
        # Arrange
        $expected = @()
        # Act
        $result = $null | Select-ByObjectProperty -Property 'Name' -Pattern '*'
        # Assert
        $result | Should -Be $expected
    }

    It 'Should handle empty pattern' {
        # Arrange
        $expected = @($john, $jane, $bob)
        # Act
        $result = $testObjects | Select-ByObjectProperty -Property 'Name' -Pattern ''
        # Assert
        $result | Should -Be $expected
    }

    It 'Should handle null pattern' {
        # Arrange
        $expected = @($john, $jane, $bob)
        # Act
        $result = $testObjects | Select-ByObjectProperty -Property 'Name' -Pattern $null
        # Assert
        $result | Should -Be $expected
    }
}
