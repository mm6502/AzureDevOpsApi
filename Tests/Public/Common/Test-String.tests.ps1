BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Test-String' {

    It 'Should include all strings when no filters are provided' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        # Act
        $result = $inputs | Where-Object { $_ | Test-String }
        # Assert
        $result.Count | Should -Be $inputs.Count
        $result | Should -Be $inputs
    }

    It 'Should include strings matching the Include filter' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        $include = @('*d*')
        # Act
        $result = $inputs | Where-Object { $_ | Test-String -Include $include }
        # Assert
        $result.Count | Should -Be 3
        $result | Should -BeIn @('bcd', 'cde', 'def')
    }

    It 'Should exclude strings matching the Exclude filter' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        $exclude = @('*e*')
        # Act
        $result = $inputs | Where-Object { $_ | Test-String -Exclude $exclude }
        # Assert
        $result.Count | Should -Be 2
        $result | Should -BeIn @('abc', 'bcd')
    }

    It 'Should respect case sensitivity when -CaseSensitive is provided' {
        # Arrange
        $inputs = @('abc', 'bcd', 'CDE', 'def')
        $include = @('*d*')
        $exclude = @('*e*')
        # Act
        $result = $inputs | Where-Object { $_ | Test-String -Include $include -Exclude $exclude -CaseSensitive }
        # Assert
        $result.Count | Should -Be 1
        $result | Should -Be 'bcd'
    }

    It 'Should handle empty input array' {
        # Arrange
        $inputs = @()
        # Act
        $result = $inputs | Where-Object { $_ | Test-String }
        # Assert
        $result.Count | Should -Be 0
    }

    It 'Should handle null input array' {
        # Arrange
        $inputs = $null
        # Act
        $result = $inputs | Where-Object { $_ | Test-String }
        # Assert
        $result.Count | Should -Be 0
    }

    It 'Should handle empty Include filter' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        $include = @()
        # Act
        $result = $inputs | Where-Object { $_ | Test-String -Include $include }
        # Assert
        $result.Count | Should -Be 0
    }

    It 'Should handle null Include filter' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        $include = $null
        # Act
        $result = $inputs | Where-Object { $_ | Test-String -Include $include }
        # Assert
        $result.Count | Should -Be $inputs.Count
        $result | Should -Be $inputs
    }
}
