[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-ExcelGetCellAddress' {
    It 'Should return only row when column is not specified' {
        $result = Export-ExcelGetCellAddress -Row 5
        $result | Should -Be 5
    }

    It 'Should return correct address for alphabetic column and numeric row' {
        $result = Export-ExcelGetCellAddress -Row 10 -Column 'C'
        $result | Should -Be 'C10'
    }

    It 'Should convert numeric column to alphabetic and combine with row' {
        $result = Export-ExcelGetCellAddress -Row 15 -Column 3
        $result | Should -Be 'C15'
    }

    It 'Should handle double-letter columns correctly' {
        $result = Export-ExcelGetCellAddress -Row 20 -Column 27
        $result | Should -Be 'AA20'
    }

    It 'Should handle triple-letter columns correctly' {
        $result = Export-ExcelGetCellAddress -Row 25 -Column 703
        $result | Should -Be 'AAA25'
    }

    It 'Should return only column when row is not specified' {
        $result = Export-ExcelGetCellAddress -Column 'D'
        $result | Should -Be 'D'
    }

    It 'Should convert large numeric column to alphabetic correctly' {
        $result = Export-ExcelGetCellAddress -Row 30 -Column 1000
        $result | Should -Be 'ALL30'
    }
}
