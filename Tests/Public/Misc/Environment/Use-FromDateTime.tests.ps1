BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Use-FromDateTime' {

    BeforeAll {
        Set-Variable `
            -Scope 'Script' `
            -Name 'Default' `
            -Value ([DateTime]::new(2000, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc))
    }

    It 'Should return the provided FromDateTime in UTC' {
        # Arrange
        $fromDateTime = Get-Date -Date '2023-05-01 12:00:00'
        $expected = $fromDateTime.ToUniversalTime()

        # Act
        $result = Use-FromDateTime -FromDateTime $fromDateTime

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $expected
    }

    It 'Should return the default FromDateTime from global variable if not provided' {
        # Arrange
        $global:AzureDevOpsApi_DefaultFromDate = Get-Date -Date '2022-01-01 00:00:00'
        $expected = $global:AzureDevOpsApi_DefaultFromDate.ToUniversalTime()

        # Act
        $result = Use-FromDateTime

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $expected
    }

    It 'Should return a default DateTime of 2000-01-01T00:00:00Z if no input or global variable is provided' {
        # Arrange
        $global:AzureDevOpsApi_DefaultFromDate = $null

        # Act
        $result = Use-FromDateTime

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $Default
    }

    It 'Should handle null input' {
        # Act
        $result = Use-FromDateTime -FromDateTime $null

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $Default
    }

    It 'Should handle empty string input' {
        # Act
        $result = Use-FromDateTime -FromDateTime ''

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $Default
    }

    It 'Should handle string input' {
        # Arrange
        $fromDateTimeString = '2023-05-01 12:00:00'
        $expected = (Get-Date -Date $fromDateTimeString).ToUniversalTime()

        # Act
        $result = Use-FromDateTime -FromDateTime $fromDateTimeString

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $expected
    }
}
