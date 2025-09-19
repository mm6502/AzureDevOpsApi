BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Use-AsOfDateTime' {
    BeforeAll {

        $expected = [PSCustomObject] @{
            UtcNow = [datetime]::Parse('2022-03-04T01:02:03Z').ToUniversalTime()
            DateTo = [datetime]::Parse('2023-04-05T02:03:04Z').ToUniversalTime()
            AsOf   = [datetime]::Parse('2024-05-06T03:04:05Z').ToUniversalTime()
        }

        Mock -ModuleName $ModuleName -CommandName Use-ToDateTime -MockWith {
            param($Value)
            if (!$Value) {
                Use-ToDateTime -Value $expected.UtcNow
            } else {
                Use-ToDateTime -Value $Value
            }
        }
    }

    It 'Should return the current UTC time when no input is provided' {
        # Act
        $result = Use-AsOfDateTime

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -BeGreaterThan ($expected.UtcNow.AddSeconds(-1))
        $result | Should -BeLessThan ($expected.UtcNow.AddSeconds(1))
    }

    It 'Should return the provided Value when it is specified' {
        # Act
        $result = Use-AsOfDateTime -Value $expected.AsOf

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $expected.AsOf
    }

    It 'Should return the provided DateTo when Value is not specified' {
        # Act
        $result = Use-AsOfDateTime -DateTo $expected.DateTo

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $expected.DateTo
    }

    It 'Should prioritize Value over DateTo when both are provided' {
        # Act
        $result = Use-AsOfDateTime -Value $expected.AsOf -DateTo $expected.DateTo

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $expected.AsOf
    }

    It 'Should handle pipeline input' {
        # Act
        $result = $expected.AsOf | Use-AsOfDateTime

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -Be $expected.AsOf
    }

    It 'Should handle null Value' {
        # Act
        $result = Use-AsOfDateTime -Value $null

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -BeGreaterThan ($expected.UtcNow.AddSeconds(-1))
        $result | Should -BeLessThan ($expected.UtcNow.AddSeconds(1))
    }

    It 'Should handle empty string Value' {
        # Act
        $result = Use-AsOfDateTime -Value ''

        # Assert
        $result | Should -BeOfType [DateTime]
        $result | Should -BeGreaterThan ($expected.UtcNow.AddSeconds(-1))
        $result | Should -BeLessThan ($expected.UtcNow.AddSeconds(1))
    }
}
