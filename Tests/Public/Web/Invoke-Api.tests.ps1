[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Invoke-Api' {

    BeforeAll {
        $baseUri = 'https://non.existent.domain.qqq/api/data'
    }

    It 'Should throw an error for a relative URI' {
        # Act & Assert
        { Invoke-Api -Uri '/api/test' } | Should -Throw 'Uri must be absolute*'
    }

    It 'Should add the api-version parameter to the URI' {
        # Arrange
        $expected = @{
            Uri        = $baseUri
            ApiVersion = '1.0'
        }

        Mock -ModuleName $ModuleName -CommandName Add-QueryParameter
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            [pscustomobject] @{ Content = '{}' }
        }

        # Act
        $result = Invoke-Api -Uri $expected.Uri -ApiVersion $expected.ApiVersion

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Add-QueryParameter -ParameterFilter {
            $Parameters['api-version'] -eq $expected.ApiVersion
        }
    }

    It 'Should handle 404 response gracefully (native)' {
        # 404 is not an terminating error, so we should return null
        # Arrange
        $expected = @{
            Uri = $baseUri
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            throw (New-WebException)
        }

        # Act
        $result = Invoke-Api -Uri $expected.Uri

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle 404 response gracefully (legacy)' {
        # 404 is not an terminating error, so we should return null
        # Arrange
        $expected = @{
            Uri = $baseUri
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            throw (New-WebException -Legacy)
        }

        # Act
        $result = Invoke-Api -Uri $expected.Uri

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should return the response content as a PSObject' {
        # Arrange
        $expected = @{
            Uri = $baseUri
            PropertyName = 'name'
            PropertyValue = 'test'
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            [pscustomobject] @{
                Content = "{""$($expected.PropertyName)"":""$($expected.PropertyValue)""}"
            }
        }

        # Act
        $result = Invoke-Api -Uri $expected.Uri

        # Assert
        $result | Should -BeOfType [PSCustomObject]
        $result.name | Should -Be $expected.PropertyValue
    }

    It 'Should pass the Body parameter to Invoke-CustomWebRequest' {
        # Arrange
        $expected = @{
            Uri = $baseUri
            Body = [pscustomobject]@{ name = 'test' } | ConvertTo-Json
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            [pscustomobject]@{ Content = '{}' }
        }

        # Act
        $result = Invoke-Api -Uri $expected.Uri -Body $expected.Body

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -ParameterFilter {
            $Body -eq $expected.Body
        }
    }

    It 'Should pass the Method parameter to Invoke-CustomWebRequest' {
        # Arrange
        $expected = @{
            Uri = $baseUri
            Method = 'POST'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            [pscustomobject]@{ Content = '{}' }
        }

        # Act
        $result = Invoke-Api -Uri $expected.Uri -Method $expected.Method

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -ParameterFilter {
            $Method -eq $expected.Method
        }
    }
}
