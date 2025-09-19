BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe "ConvertTo-HashTable" {
    Context "When converting a PSCustomObject" {
        It "Should convert a simple PSCustomObject to a hashtable" {
            # Arrange
            $customObject = [PSCustomObject]@{
                Name = "Test"
                Value = 123
                Enabled = $true
            }

            # Act
            $result = ConvertTo-HashTable -Value $customObject

            # Assert
            $result | Should -BeOfType [hashtable]
            $result.Name | Should -Be "Test"
            $result.Value | Should -Be 123
            $result.Enabled | Should -BeTrue
        }
    }

    Context "When handling an existing hashtable" {
        It "Should return the hashtable unchanged" {
            # Arrange
            $hashtable = @{
                Name = "Test"
                Value = 123
                Enabled = $true
            }

            # Act
            $result = ConvertTo-HashTable -Value $hashtable

            # Assert
            $result | Should -BeOfType [hashtable]
            $result | Should -Be $hashtable
            $result.Name | Should -Be "Test"
            $result.Value | Should -Be 123
            $result.Enabled | Should -BeTrue
        }
    }

    Context "When converting an IDictionary" {
        It "Should convert a Dictionary to a hashtable" {
            # Arrange
            $dictionary = New-Object 'System.Collections.Generic.Dictionary[string,object]'
            $dictionary.Add("Name", "Test")
            $dictionary.Add("Value", 123)
            $dictionary.Add("Enabled", $true)

            # Act
            $result = ConvertTo-HashTable -Value $dictionary

            # Assert
            $result | Should -BeOfType [hashtable]
            $result.Name | Should -Be "Test"
            $result.Value | Should -Be 123
            $result.Enabled | Should -BeTrue
        }

        It "Should convert an OrderedDictionary to a hashtable" {
            # Arrange
            $orderedDictionary = [ordered]@{
                Name = "Test"
                Value = 123
                Enabled = $true
            }

            # Act
            $result = ConvertTo-HashTable -Value $orderedDictionary

            # Assert
            $result | Should -BeOfType [hashtable]
            $result.Name | Should -Be "Test"
            $result.Value | Should -Be 123
            $result.Enabled | Should -BeTrue
            # Verify it's not ordered anymore
            $result.GetType().Name | Should -Be "Hashtable"
        }
    }

    Context "When handling edge cases" {
        It "Should handle an empty PSCustomObject" {
            # Arrange
            $emptyObject = [PSCustomObject]@{}

            # Act
            $result = ConvertTo-HashTable -Value $emptyObject

            # Assert
            $result | Should -BeOfType [hashtable]
            $result.Keys.Count | Should -Be 0
        }

        It "Should handle null properties" {
            # Arrange
            $objectWithNull = [PSCustomObject]@{
                Name = "Test"
                NullValue = $null
            }

            # Act
            $result = ConvertTo-HashTable -Value $objectWithNull

            # Assert
            $result | Should -BeOfType [hashtable]
            $result.Name | Should -Be "Test"
            $result.ContainsKey('NullValue') | Should -BeTrue
            $result.NullValue | Should -BeNullOrEmpty
        }

        It "Should return empty hashtable when Value is null" {
            # Act
            $result = $null | ConvertTo-HashTable

            # Assert
            $result | Should -BeOfType [hashtable]
            $result.Count | Should -Be 0
        }
    }
}
