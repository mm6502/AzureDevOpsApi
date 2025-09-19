BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Test-DateTimeRange' {

    It 'Should return false for null DateTime' {
        # Act & Assert
        Test-DateTimeRange -Value $null | Should -BeFalse
    }

    It 'Should return true for DateTime within the range' {
        # Arrange
        $dateTime = Get-Date '2023-05-01T12:00:00Z'
        $from = Get-Date '2023-01-01T00:00:00Z'
        $to = Get-Date '2023-12-31T23:59:59Z'
        # Act & Assert
        Test-DateTimeRange -Value $dateTime -From $from -To $to | Should -BeTrue
    }

    It 'Should return false for DateTime outside the range' {
        # Arrange
        $dateTime = Get-Date '2022-12-31T23:59:59Z'
        $from = Get-Date '2023-01-01T00:00:00Z'
        $to = Get-Date '2023-12-31T23:59:59Z'
        # Act & Assert
        Test-DateTimeRange -Value $dateTime -From $from -To $to | Should -BeFalse
    }

    It 'Should handle DateTime with different DateTimeKind' {
        # Arrange
        $dateTime = Get-Date '2023-05-01T12:00:00' # Local time
        $from = Get-Date '2023-01-01T00:00:00Z'
        $to = Get-Date '2023-12-31T23:59:59Z'
        # Act & Assert
        Test-DateTimeRange -Value $dateTime -From $from -To $to | Should -BeTrue
    }

    It 'Should use default From value if not provided' {
        # Arrange
        $global:AzureDevOpsApi_DefaultFromDate = Get-Date '2000-01-01T00:00:00Z'
        $dateTime = Get-Date '2023-05-01T12:00:00Z'
        $to = Get-Date '2023-12-31T23:59:59Z'
        # Act & Assert
        Test-DateTimeRange -Value $dateTime -To $to | Should -BeTrue
    }

    It 'Should use current time as To value if not provided' {
        # Arrange
        $dateTime = Get-Date '2023-05-01T12:00:00Z'
        $from = Get-Date '2000-01-01T00:00:00Z'
        # Act & Assert
        Test-DateTimeRange -Value $dateTime -From $from | Should -BeTrue
    }
}
