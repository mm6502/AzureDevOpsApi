BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ConnectionData' {

    It 'Should return connection data' {

        # Arrange
        $expected = @{
            Connection = New-TestApiCollectionConnection
            Uri = 'https://dev.azure.com/myorg/_apis/connectionData'
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            return [PSCustomObject]@{
                authenticatedUser = 'user@example.com'
                authorizedUser    = 'user@example.com'
            }
        }

        # Act
        $result = Get-ConnectionData `
            -CollectionUri $expected.CollectionUri `
            -ApiCredential $expected.ApiCredential

        # Assert
        $result.authenticatedUser | Should -Be 'user@example.com'
        $result.authorizedUser | Should -Be 'user@example.com'
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            ($Uri -eq $expected.Uri) `
            -and `
            ($ApiVersion -like "$($expected.Connection.ApiVersion)*") `
            -and `
            ($ApiCredential -eq $expected.Connection.ApiCredential) `
        }
    }
}
