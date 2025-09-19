[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Add-QueryParameter' {

    BeforeAll {
        $baseUri = 'https://example.com/tfs'
        $basePath = '/api'
        $expectedPath = 'api'
    }

    Context 'When Uri is a string' {
        It 'Should add query parameters to the Uri' {
            # Arrange
            $uri = $baseUri
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
        }

        It 'Should preserve existing query parameters in the Uri' {
            # Arrange
            $uri = $baseUri + "?c=3"
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
            $result | Should -BeLike "*c=3*"
        }

        It 'Should replace existing query parameters in the Uri' {
            # Arrange
            $uri = $baseUri + "?c=3"
            $params = @{ a = 1; b = 2; c = 1 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
            $result | Should -BeLike "*c=1*"
        }
    }

    Context 'When Uri is a System.Uri' {
        It 'Should add query parameters to the Uri' {
            # Arrange
            $uri = [System.Uri]::new($baseUri)
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
        }

        It 'Should preserve existing query parameters in the Uri' {
            # Arrange
            $uri = [System.Uri]::new($baseUri + "?c=3")
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
            $result | Should -BeLike "*c=3*"
        }

        It 'Should replace existing query parameters in the Uri' {
            # Arrange
            $uri = $baseUri + "?c=3"
            $params = @{ a = 1; b = 2; c = 1 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
            $result | Should -BeLike "*c=1*"
        }
    }

    Context 'When Uri is a relative Uri' {
        It 'Should add query parameters to the relative Uri' {
            # Arrange
            $uri = $basePath
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($expectedPath)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
        }

        It 'Should set query parameters in the relative Uri' {
            # Arrange
            $uri = $basePath + "?c=3"
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($expectedPath)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
            $result | Should -BeLike "*c=3*"
        }
    }

    Context 'When Uri has a default port' {
        It 'Should remove the port from the Uri' {
            # Arrange
            $uri = 'https://example.com:443/tfs'
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
        }
    }

    Context 'When Uri has a non default port' {
        It 'Should keep the port in the Uri' {
            # Arrange
            $baseUri = 'https://example.com:8443/tfs'
            $uri = $baseUri
            $params = @{ a = 1; b = 2 }

            # Act
            $result = Add-QueryParameter -Uri $uri -Parameters $params

            # Assert
            $result | Should -BeLike "$($baseUri)?*"
            $result | Should -BeLike "*a=1*"
            $result | Should -BeLike "*b=2*"
        }
    }
}
