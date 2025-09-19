[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Format-Uri' {

    It 'Should return an empty string for null or whitespace input' -ForEach @(
        @{ Uri = $null; Expected = '' }
        @{ Uri = '   '; Expected = '' }
    ) {
        Format-Uri -Uri $Uri | Should -BeExactly $Expected
    }

    It 'Should replace backslashes with forward slashes' {
        # Act
        $result = Format-Uri -Uri 'https://example.com\path\to\resource'
        # Assert
        $result | Should -BeExactly 'https://example.com/path/to/resource/'
    }

    It 'Should trim leading and trailing whitespace' {
        # Act
        $result = Format-Uri -Uri '   https://example.com/path/   '
        # Assert
        $result | Should -BeExactly 'https://example.com/path/'
    }

    It 'Should trim trailing forward slash, backslash, and question mark' -ForEach @(
        @{ Uri = 'https://example.com/path/?'   ; Expected = 'https://example.com/path/'     }
        @{ Uri = 'https://example.com/path/?a=b'; Expected = 'https://example.com/path/?a=b' }
        @{ Uri = 'https://example.com/path//'   ; Expected = 'https://example.com/path/'     }
        @{ Uri = 'https://example.com/path\\'   ; Expected = 'https://example.com/path/'     }
    ) {
        # Act & Assert
        Format-Uri -Uri $Uri | Should -BeExactly $Expected
    }

    It 'Should add a trailing forward slash if missing' {
        # Act
        $result = Format-Uri -Uri 'https://example.com/path'
        # Assert
        $result | Should -BeExactly 'https://example.com/path/'
    }

    It 'Should handle absolute URIs' {
        # Act
        $result = Format-Uri -Uri 'https://example.com/path/to/resource'
        # Assert
        $result | Should -BeExactly 'https://example.com/path/to/resource/'
    }

    It 'Should handle relative URIs' {
        # Act
        $result = Format-Uri -Uri '/path/to/resource'
        # Assert
        # We will join the relative uri to the baseUri,
        # and do not want to remove partial path in the baseUri.
        $result | Should -BeExactly 'path/to/resource/'
    }
}
