[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-TimeZoneDateTime' {
    BeforeAll {
        $utcDateTime = [DateTime]::new(2023, 5, 15, 12, 0, 0, [DateTimeKind]::Utc)
        $centralEuropeTimeZone = [TimeZoneInfo]::FindSystemTimeZoneById('Central Europe Standard Time')
    }

    It 'Should return null when no DateTime is provided' {
        # Act
        $result = ConvertTo-TimeZoneDateTime -DateTime $null

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should convert UTC to Central Europe Time' {
        # Act
        $result = ConvertTo-TimeZoneDateTime -DateTime $utcDateTime -TimeZone 'Central Europe Standard Time'

        # Assert
        $result.Hour | Should -Be 14
        $result.Kind | Should -Be 'Unspecified'
    }

    It 'Should accept TimeZoneInfo object as input' {
        # Act
        $result = ConvertTo-TimeZoneDateTime -DateTime $utcDateTime -TimeZone $centralEuropeTimeZone

        # Assert
        $result.Hour | Should -Be 14
        $result.Kind | Should -Be 'Unspecified'
    }

    It 'Should handle IANA time zone identifiers' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Get-CustomTimeZone -MockWith { $centralEuropeTimeZone }

        # Act
        $result = ConvertTo-TimeZoneDateTime -DateTime $utcDateTime -TimeZone 'Europe/Prague'

        # Assert
        $result.Hour | Should -Be 14
        $result.Kind | Should -Be 'Unspecified'
    }

    It 'Should default to UTC when no TimeZone is specified' {
        # Act
        $result = ConvertTo-TimeZoneDateTime -DateTime $utcDateTime

        # Assert
        $result | Should -Be $utcDateTime
        $result.Kind | Should -Be 'Utc'
    }

    It 'Should handle string input for DateTime' {
        # Act
        $result = ConvertTo-TimeZoneDateTime `
            -DateTime '2023-05-15T12:00:00Z' `
            -TimeZone 'Central Europe Standard Time'

        # Assert
        $result.Hour | Should -Be 14
        $result.Kind | Should -Be 'Unspecified'
    }

    It 'Should throw an error for invalid TimeZone' {
        # Act & Assert
        {
            ConvertTo-TimeZoneDateTime -DateTime $utcDateTime -TimeZone 'Invalid Time Zone' -ErrorAction Stop
        } | Should -Throw
    }
}
