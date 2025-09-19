BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Test-ObjectProperty' {

    It 'Should return true when no pattern is provided' {
        # Act
        $result = Test-ObjectProperty -InputObject "dummy"
        # Assert
        $result | Should -BeTrue
    }

    It 'Should return false when no object is provided' {
        # Act
        $result = $null | Test-ObjectProperty -Pattern '*'
        # Assert
        $result | Should -BeFalse
    }

    It 'Should return true when object matches pattern' {
        # Arrange
        $obj = [PSCustomObject] @{
            Name = 'John'
            Age  = 30
        }
        # Act
        $result = Test-ObjectProperty -InputObject $obj -Property 'Name' -Pattern 'John'
        # Assert
        $result | Should -BeTrue
    }

    It 'Should return false when object does not match pattern' {
        # Arrange
        $obj = [PSCustomObject] @{
            Name = 'John'
            Age  = 30
        }
        # Act
        $result = Test-ObjectProperty -InputObject $obj -Property 'Name' -Pattern 'Jane'
        # Assert
        $result | Should -BeFalse
    }

    It 'Should handle multiple properties for case <case>' -ForEach @(
        @{ Case = 'None'; Expected = $false; Name = 'Jane'; City = 'Boston' }
        @{ Case = 'Name'; Expected = $true;  Name = 'John'; City = 'Boston' }
        @{ Case = 'City'; Expected = $true;  Name = 'Jane'; City = 'New York' }
        @{ Case = 'Both'; Expected = $true;  Name = 'John'; City = 'New York' }
    ) {
        # Arrange
        $obj = [PSCustomObject] @{
            Name = 'John'
            Age  = 30
            City = 'New York'
        }
        # Act
        $result = Test-ObjectProperty -InputObject $obj -Property 'Name', 'City' -Pattern $Name, $City
        # Assert
        $result | Should -Be $Expected
    }

    It 'Should handle null properties' {
        # Arrange
        $obj = [PSCustomObject] @{
            Name = $null
            Age  = 30
        }
        # Act
        $result = Test-ObjectProperty -InputObject $obj -Property 'Name'
        # Assert
        $result | Should -BeTrue
    }

    It 'Should handle empty string properties' {
        # Arrange
        $obj = [PSCustomObject] @{
            Name = ''
            Age  = 30
        }
        # Act
        $result = Test-ObjectProperty -InputObject $obj -Property 'Name' -Pattern ''
        # Assert
        $result | Should -BeTrue
    }

    It 'Should handle nested objects' {
        # Arrange
        $obj = [PSCustomObject] @{
            Name    = 'John'
            Age     = 30
            Address = [PSCustomObject] @{
                City    = 'New York'
                Country = 'USA'
            }
        }
        # Act
        $result = $obj | Test-ObjectProperty -Property 'Address.City' -Pattern 'New*'
        # Assert
        $result | Should -BeTrue
    }
}
