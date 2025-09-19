[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-RegexPattern' {

    It 'Should return a wildcard pattern for an empty string' {
        ConvertTo-RegexPattern -InputObject '' | Should -Be '^.*$'
    }

    It 'Should return the input string for a single character' {
        ConvertTo-RegexPattern -InputObject 'a' | Should -Be '^a$'
    }

    It 'Should return a dot for a question mark' {
        ConvertTo-RegexPattern -InputObject '?' | Should -Be '^.$'
    }

    It 'Should return a wildcard pattern for an asterisk' {
        ConvertTo-RegexPattern -InputObject '*' | Should -Be '^.*$'
    }

    It 'Should replace question marks with dots' {
        ConvertTo-RegexPattern -InputObject 'a?b' | Should -Be '^a.b$'
    }

    It 'Should replace multiple asterisks with a single wildcard' {
        ConvertTo-RegexPattern -InputObject 'a**b' | Should -Be '^a.*b$'
    }

    It 'Should match strings with explicit length' {
        ConvertTo-RegexPattern -InputObject '???' | Should -Be '^...$'
    }

    It 'Should handle multiple input strings' {
        $patterns = ConvertTo-RegexPattern -InputObject 'a*b', 'c?d', 'e'
        $patterns[0] | Should -Be '^a.*b$'
        $patterns[1] | Should -Be '^c.d$'
        $patterns[2] | Should -Be '^e$'
    }
}
