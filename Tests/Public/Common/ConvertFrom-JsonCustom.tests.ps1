BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertFrom-JsonCustom' {

    It 'Should convert a valid JSON string to a PSObject' {
        # Arrange
        $json = '{"Name":"John","Age":30}'

        # Act
        $obj = ConvertFrom-JsonCustom -Value $json

        # Assert
        $obj | Should -BeOfType [PSCustomObject]
        $obj.Name | Should -Be 'John'
        $obj.Age | Should -Be 30
    }

    It 'Should convert a valid JSON string to a hashtable when -AsHashtable is used' {
        # Arrange
        $json = '{"Name":"John","Age":30}'

        # Act
        $hashtable = ConvertFrom-JsonCustom -Value $json -AsHashtable

        # Assert
        $hashtable | Should -BeOfType [Hashtable]
        $hashtable['Name'] | Should -Be 'John'
        $hashtable['Age'] | Should -Be 30
    }

    It 'Should handle null values in JSON' {
        # Arrange
        $json = '{"Name":null,"Age":30}'

        # Act
        $obj = ConvertFrom-JsonCustom -Value $json

        # Assert
        $obj.Name | Should -BeNull
        $obj.Age | Should -Be 30
    }

    It 'Should handle empty strings in JSON' {
        # Arrange
        $json = '{"Name":"","Age":30}'

        # Act
        $obj = ConvertFrom-JsonCustom -Value $json

        # Assert
        $obj.Name | Should -Be ([string]::Empty)
        $obj.Age | Should -Be 30
    }

    It 'Should handle empty JSON string' {
        # Arrange
        $json = [string]::Empty

        # Act
        $obj = ConvertFrom-JsonCustom -Value $json

        # Assert
        $obj | Should -BeNullOrEmpty
    }

    It 'Should handle null input' {
        # Act
        $obj = ConvertFrom-JsonCustom -Value $null

        # Assert
        $obj | Should -BeNullOrEmpty
    }

    It 'Should handle nested objects in JSON' {
        # Arrange
        $json = '{"Name":"John","Address":{"City":"New York","Country":"USA"}}'

        # Act
        $obj = ConvertFrom-JsonCustom -Value $json

        # Assert
        $obj.Name | Should -Be 'John'
        $obj.Address.City | Should -Be 'New York'
        $obj.Address.Country | Should -Be 'USA'
    }

    It 'Should handle arrays in JSON' {
        # Arrange
        $json = '{"Names":["John","Jane","Bob"]}'

        # Act
        $obj = ConvertFrom-JsonCustom -Value $json

        # Assert
        $obj.Names.Count | Should -Be 3
        $obj.Names[0] | Should -Be 'John'
        $obj.Names[1] | Should -Be 'Jane'
        $obj.Names[2] | Should -Be 'Bob'
    }
}
