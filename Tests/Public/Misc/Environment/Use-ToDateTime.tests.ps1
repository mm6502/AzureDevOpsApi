BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Use-ToDateTime' {

    Context 'When Value is not provided' {
        It 'Should return the current UTC DateTime' {
            # Arrange
            $before = [DateTime]::UtcNow

            # Act
            $result = Use-ToDateTime

            # Assert
            $after = [DateTime]::UtcNow
            $result | Should -BeOfType [DateTime]
            $result.Kind | Should -Be 'Utc'
            $result | Should -BeGreaterThan $before.AddSeconds(-1)
            $result | Should -BeLessThan $after.AddSeconds(1)
        }
    }

    Context 'When Value is a valid DateTime string' {
        It 'Should parse the string and return the DateTime in UTC' {
            # Arrange
            $dateString = '2023-05-01 12:34:56'
            $expected = [DateTime]::ParseExact($dateString, 'yyyy-MM-dd HH:mm:ss', $null).ToUniversalTime()

            # Act
            $result = Use-ToDateTime -Value $dateString

            # Assert
            $result | Should -Be $expected
        }
    }

    Context 'When Value is a DateTime object' {
        It 'Should convert the DateTime to UTC' {
            # Arrange
            $dateTime = Get-Date '2023-05-01 12:34:56'
            $expected = $dateTime.ToUniversalTime()

            # Act
            $result = Use-ToDateTime -Value $dateTime

            # Assert
            $result | Should -Be $expected
        }
    }

    Context 'When Value is an invalid type' {
        It 'Should return the current UTC DateTime' {
            # Arrange
            $invalidValue = 42
            $before = [DateTime]::UtcNow

            # Act
            $result = Use-ToDateTime -Value $invalidValue

            # Assert
            $after = [DateTime]::UtcNow
            $result | Should -BeOfType [DateTime]
            $result.Kind | Should -Be 'Utc'
            $result | Should -BeGreaterThan $before.AddSeconds(-1)
            $result | Should -BeLessThan $after.AddSeconds(1)
        }
    }
}
