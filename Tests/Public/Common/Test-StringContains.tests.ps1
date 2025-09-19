BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Test-StringContains' {

    Context 'When Haystack is null or empty' {

        It 'Should return false when Haystack is null and Needle is not null' {
            Test-StringContains -Haystack $null -Needle 'test' | Should -BeFalse
        }

        It 'Should return false when Haystack is empty and Needle is not null' {
            Test-StringContains -Haystack @() -Needle 'test' | Should -BeFalse
        }
    }

    Context 'When Needle is null or empty' {

        It 'Should return false when Needle is null and Haystack is not null' {
            Test-StringContains -Haystack 'test' -Needle $null | Should -BeFalse
        }

        It 'Should return false when Needle is empty and Haystack is not null' {
            Test-StringContains -Haystack 'test' -Needle @() | Should -BeFalse
        }
    }

    Context 'When both Haystack and Needle are provided' {

        It 'Should return true when Needle is found in Haystack' {
            Test-StringContains -Haystack 'This is a test' -Needle 'test' | Should -BeTrue
        }

        It 'Should return false when Needle is not found in Haystack' {
            Test-StringContains -Haystack 'This is a test' -Needle 'notfound' | Should -BeFalse
        }

        It 'Should handle case sensitivity based on StringComparison parameter' {
            Test-StringContains -Haystack 'This is a TEST' -Needle 'test' -StringComparison 'CurrentCulture' `
            | Should -BeFalse
            Test-StringContains -Haystack 'This is a TEST' -Needle 'test' -StringComparison 'CurrentCultureIgnoreCase' `
            | Should -BeTrue
        }

        It 'Should handle multiple Needles' {
            Test-StringContains -Haystack 'This is a test' -Needle 'This', 'test' | Should -BeTrue
            Test-StringContains -Haystack 'This is a test' -Needle 'This', 'notfound' | Should -BeFalse
        }

        It 'Should handle multiple Haystacks' {
            Test-StringContains -Haystack 'This is a test', 'Another test' -Needle 'test' | Should -BeTrue
            Test-StringContains -Haystack 'This is a test', 'Another string' -Needle 'notfound' | Should -BeFalse
        }
    }
}
