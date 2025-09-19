[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

BeforeDiscovery {
    $skipOnPS5 = $PSVersionTable.PSVersion.Major -lt 6
}

Describe 'Invoke-CustomWebRequest' {

    BeforeAll {
        $baseUri = 'https://non.existent.domain.qqq/api/data'

        Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
            [PSCustomObject] @{ StatusCode = $expected.StatusCode }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -MockWith {
            [PSCustomObject] @{ StatusCode = $expected.StatusCode }
        }
    }

    Context 'Testing switch between Invoke-WebRequest and Invoke-CurlWebRequest' {

        It 'Should use Invoke-WebRequest on PSv5 when using default credentials' {
            # Arrange
            $expected = [PSCustomObject] @{
                Uri = $baseUri
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -Uri $expected.Uri

            # Assert
            $response | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest
        }

        It 'Should use Invoke-WebRequest on PSv5 when using other credentials' {
            # Arrange
            $expected = [PSCustomObject] @{
                Uri           = $baseUri
                ApiCredential = New-ApiCredential `
                    -Authorization 'PAT' `
                    -Token 'fake_token'
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri

            # Assert
            $response | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest
        }

        It 'Should use Invoke-WebRequest on PSv6+ on Windows when using default credentials' -Skip:$skipOnPS5 {
            # Arrange
            $expected = [PSCustomObject] @{
                Uri           = $baseUri
                ApiCredential = $null
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 6 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri

            # Assert
            $response | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest
        }

        It 'Should use throw on Linux when using default credentials' {
            # Arrange
            $expected = [PSCustomObject] @{
                Uri           = $baseUri
                ApiCredential = $null
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 6 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Linux' }
            }

            # Act
            { $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri
            } | Should -Throw
        }

        It 'Should use Invoke-CurlWebRequest on Linux by default' {
            # Arrange
            $expected = [PSCustomObject] @{
                Uri           = $baseUri
                ApiCredential = New-ApiCredential `
                    -Authorization PAT `
                    -Token 'fake_token'
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 6 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Linux' }
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri

            # Assert
            $response | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest
        }
    }

    Context 'Common parameters for Invoke-WebRequest' {

        BeforeAll {
            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }
        }

        It 'Should send a GET request and return the response' {
            # Arrange
            $expected = @{
                Uri        = $baseUri
                StatusCode = 200
                Method     = 'GET'
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -Uri $expected.Uri

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode

            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -ParameterFilter {
                ($Method -eq $expected.Method) `
                    -and `
                ($Uri -eq $expected.Uri) `
            }
        }

        It 'Should send a POST request with a body' {
            # Arrange
            $expected = @{
                Uri        = $baseUri
                StatusCode = 200
                Method     = 'POST'
                Body       = (@{ Name = 'John'; Age = 30 } | ConvertTo-Json)
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -Uri $expected.Uri `
                -Body $expected.Body

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -ParameterFilter {
                ($Body -eq $expected.Body) `
                    -and `
                ($Uri -eq $expected.Uri) `
            }
        }

        It 'Should handle HTTP error responses' {
            # Arrange
            $expected = @{
                StatusCode = 404
            }

            $uri = $baseUri

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -Uri $uri `
                -ErrorAction SilentlyContinue

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
        }

        It 'Should handle invalid URI' {
            # Arrange
            $uri = 'invalid://uri'

            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                throw 'Invalid URI'
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -MockWith {
                throw 'Invalid URI'
            }

            # Act & Assert
            { Invoke-CustomWebRequest `
                    -WarningAction SilentlyContinue `
                    -Uri $uri `
                    -ErrorAction Stop `
            } | Should -Throw
        }

        It 'Should support custom headers' {
            # Arrange
            $expected = @{
                Uri        = $baseUri
                StatusCode = 200
                Headers    = @{ 'X-CustomHeader' = 'Value' }
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -Uri $expected.Uri `
                -Headers $expected.Headers

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -ParameterFilter {
                $Headers.Keys -contains ($expected.Headers.Keys | Select-Object -First 1)
            }
        }

        It 'Should support default credentials authorization' {
            # Arrange
            $expected = @{
                Uri           = $baseUri
                StatusCode    = 200
                ApiCredential = (New-ApiCredential)
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -Uri $expected.Uri `
                -ApiCredential $expected.Credential

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -ParameterFilter {
                $UseDefaultCredentials -eq $true
            }
        }

        It 'Should support token authorization' {
            # Arrange
            $expected = @{
                Uri           = $baseUri
                StatusCode    = 200
                Authorization = 'Bearer'
                ApiCredential = $null
            }

            $expected.ApiCredential = (
                New-ApiCredential `
                    -Authorization $expected.Authorization `
                    -Token 'a_bad_token'
            )

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -Uri $expected.Uri `
                -ApiCredential $expected.ApiCredential

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -ParameterFilter {
            ($Headers.Keys -contains 'Authorization') `
                    -and `
                ($Headers['Authorization'] -like "$($expected.Authorization)*")
            }
        }
    }

    Context 'Common parameters for Invoke-CurlWebRequest' {

        BeforeAll {
            $expected = [PSCustomObject] @{
                ApiCredential = New-ApiCredential `
                    -Authorization 'Bearer' `
                    -Token 'a_bad_token'
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 6 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }
        }

        It 'Should send a GET request and return the response' {
            # Arrange
            $expected = @{
                ApiCredential = $expected.ApiCredential
                Uri        = $baseUri
                StatusCode = 200
                Method     = 'GET'
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -ParameterFilter {
                ($params['Method'] -eq $expected.Method) `
                    -and `
                ($params['Uri'] -eq $expected.Uri) `
            }
        }

        It 'Should send a POST request with a body' {
            # Arrange
            $expected = @{
                ApiCredential = $expected.ApiCredential
                Uri        = $baseUri
                StatusCode = 200
                Method     = 'POST'
                Body       = (@{ Name = 'John'; Age = 30 } | ConvertTo-Json)
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri `
                -Body $expected.Body `

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -ParameterFilter {
                ($params['Body'] -eq $expected.Body) `
                    -and `
                ($params['Uri'] -eq $expected.Uri) `
            }
        }

        It 'Should handle HTTP error responses' {
            # Arrange
            $expected = @{
                ApiCredential = $expected.ApiCredential
                StatusCode    = 404
            }

            $uri = $baseUri

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $uri `
                -ErrorAction SilentlyContinue

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
        }

        It 'Should handle invalid URI' {
            # Arrange
            $uri = 'invalid://uri'

            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                throw 'Invalid URI'
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -MockWith {
                throw 'Invalid URI'
            }

            # Act & Assert
            { Invoke-CustomWebRequest `
                    -WarningAction SilentlyContinue `
                    -Uri $uri `
                    -ErrorAction Stop `
            } | Should -Throw
        }

        It 'Should support custom headers' {
            # Arrange
            $expected = @{
                ApiCredential = $expected.ApiCredential
                Uri        = $baseUri
                StatusCode = 200
                Headers    = @{ 'X-CustomHeader' = 'Value' }
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri `
                -Headers $expected.Headers

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -ParameterFilter {
                $params['Headers'].Keys -contains ($expected.Headers.Keys | Select-Object -First 1)
            }
        }

        It 'Should support token authorization' {
            # Arrange
            $expected = @{
                ApiCredential = $expected.ApiCredential
                Uri           = $baseUri
                StatusCode    = 200
            }

            # Act
            $response = Invoke-CustomWebRequest `
                -WarningAction SilentlyContinue `
                -ApiCredential $expected.ApiCredential `
                -Uri $expected.Uri

            # Assert
            $response | Should -Not -BeNullOrEmpty
            $response.StatusCode | Should -Be $expected.StatusCode
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -ParameterFilter {
                ($params['Headers']['Authorization'] -like "$($expected.ApiCredential.Authorization)*")
            }
        }
    }
}
