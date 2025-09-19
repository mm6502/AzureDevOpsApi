[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Test-WebAddress' {

    It 'Should return false for null input' {
        # Act
        $result = Test-WebAddress -Address $null

        # Assert
        $result | Should -Be $false
    }

    It 'Should return false for empty string' {
        # Act
        $result = Test-WebAddress -Address ''

        # Assert
        $result | Should -Be $false
    }

    It 'Should return false for whitespace string' {
        # Act
        $result = Test-WebAddress -Address '   '

        # Assert
        $result | Should -Be $false
    }

    It 'Should return true for valid http address' {
        # Act
        $result = Test-WebAddress -Address 'http://example.com'

        # Assert
        $result | Should -Be $true
    }

    It 'Should return true for valid https address' {
        # Act
        $result = Test-WebAddress -Address 'https://example.com'

        # Assert
        $result | Should -Be $true
    }

    It 'Should return false for invalid protocol' {
        # Act
        $result = Test-WebAddress -Address 'ftp://example.com'

        # Assert
        $result | Should -Be $false
    }

    It 'Should return false for malformed URL' {
        # Act
        $result = Test-WebAddress -Address 'not-a-url'

        # Assert
        $result | Should -Be $false
    }

    It 'Should handle pipeline input' {
        # Arrange
        $addresses = @(
            'https://example.com',
            'http://test.com',
            'invalid-url',
            ''
        )

        # Act
        $results = $addresses | Test-WebAddress

        # Assert
        $results.Count | Should -Be 4
        $results[0] | Should -Be $true
        $results[1] | Should -Be $true
        $results[2] | Should -Be $false
        $results[3] | Should -Be $false
    }

    It 'Should return nothing for empty array' {
        # Act
        $result = Test-WebAddress -Address @()

        # Assert
        $result | Should -BeNullOrEmpty
    }
}
