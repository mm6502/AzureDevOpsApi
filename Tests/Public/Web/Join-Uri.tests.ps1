[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Join-Uri' {

    It 'Should return the BaseUri when RelativeUri is not provided' {
        # Arrange
        $baseUri = 'https://example.com/'
        # Act
        $result = Join-Uri -BaseUri $baseUri
        # Assert
        $result | Should -BeExactly 'https://example.com/'
    }

    It 'Should return the RelativeUri when it is an absolute URI' {
        # Arrange
        $baseUri = 'https://example.com/'
        $relativeUri = 'https://other.com/path/'
        # Act
        $result = Join-Uri -BaseUri $baseUri -RelativeUri $relativeUri
        # Assert
        $result | Should -BeExactly 'https://other.com/path/'
    }

    It 'Should join the BaseUri and RelativeUri correctly' {
        # Arrange
        $baseUri = 'https://example.com/'
        $relativeUri = 'path/to/resource'
        # Act
        $result = Join-Uri -BaseUri $baseUri -RelativeUri $relativeUri
        # Assert
        $result | Should -BeExactly 'https://example.com/path/to/resource/'
    }

    It 'Should handle trailing slashes in BaseUri and RelativeUri' {
        # Arrange
        $baseUri = 'https://example.com/base/'
        $relativeUri = 'path/to/resource/'
        # Act
        $result = Join-Uri -BaseUri $baseUri -RelativeUri $relativeUri
        # Assert
        $result | Should -BeExactly 'https://example.com/base/path/to/resource/'
    }

    It 'Should handle missing trailing slash in BaseUri' {
        # Arrange
        $baseUri = 'https://example.com'
        $relativeUri = 'path/to/resource'
        # Act
        $result = Join-Uri -BaseUri $baseUri -RelativeUri $relativeUri
        # Assert
        $result | Should -BeExactly 'https://example.com/path/to/resource/'
    }

    It 'Should handle missing trailing slash in RelativeUri' {
        # Arrange
        $baseUri = 'https://example.com/'
        $relativeUri = 'path/to/resource'
        # Act
        $result = Join-Uri -BaseUri $baseUri -RelativeUri $relativeUri
        # Assert
        $result | Should -BeExactly 'https://example.com/path/to/resource/'
    }

    It 'Should handle collection of RelativeUris' {
        # Arrange
        $baseUri = 'https://example.com/'
        $relativeUri = 'path','to','resource'
        # Act
        $result = Join-Uri -BaseUri $baseUri -RelativeUri $relativeUri
        # Assert
        $result | Should -BeExactly 'https://example.com/path/to/resource/'
    }
}
