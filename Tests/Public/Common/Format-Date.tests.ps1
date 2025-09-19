[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Format-Date' {

    BeforeAll {
        $ExpectedRegex = '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z'
        $SampleDateStringUtc = '2023-05-01T12:34:56.000Z'
        $SampleDateStringLocal = '2023-05-01T14:34:56.000+02:00'
        $SampleDateObject = (Get-Date -Date $SampleDateStringLocal)
    }

    It 'Should format a valid DateTime object to the expected format' {
        # Arrange
        $date = $SampleDateObject
        $expected = $SampleDateStringUtc
        # Act
        $result = Format-Date -Value $date
        # Assert
        $result | Should -Be $expected
    }

    It 'Should format a valid string date to the expected format' {
        # Arrange
        $dateString = $SampleDateStringLocal
        $expected = $SampleDateStringUtc
        # Act
        $result = Format-Date -Value $dateString
        # Assert
        $result | Should -Be $expected
    }

    It 'Should format the current date and time if no value is provided' {
        # Act
        $result = Format-Date
        # Assert
        $result | Should -Match $ExpectedRegex
    }

    It 'Should format the current date and time if empty value is provided' {
        # Act
        $result = Format-Date -Value ''
        # Assert
        $result | Should -Match $ExpectedRegex
    }

    It 'Should format the current date and time if null value is provided' {
        # Act
        $result = Format-Date -Value $null
        # Assert
        $result | Should -Match $ExpectedRegex
    }
}
