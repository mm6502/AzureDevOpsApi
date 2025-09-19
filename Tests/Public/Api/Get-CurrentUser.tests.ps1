BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-CurrentUser' {

    It 'Should return the authenticated user when valid parameters are provided' {
        # Arrange
        $expected = @{
            CollectionUri = 'https://dev.azure.com/myorg'
            ApiCredential = New-ApiCredential
            User          = @{
                authenticatedUser = 'testuser@example.com'
                authorizedUser    = 'testuser@example.com'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Get-ConnectionData -MockWith {
            return $expectedUser
        }

        # Act
        $result = Get-CurrentUser `
            -CollectionUri $expected.CollectionUri `
            -ApiCredential $expected.ApiCredential

        # Assert
        $result | Should -Be $expectedUser.authenticatedUser
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ConnectionData -ParameterFilter {
            ($CollectionUri -eq $expected.CollectionUri) `
            -and `
            ($ApiCredential -eq $expected.ApiCredential) `
        }
    }
}
