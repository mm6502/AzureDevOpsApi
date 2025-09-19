BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-Identity' {

    It 'Should return identity details for user <_>' -ForEach @(
        'user1', [guid]'00000000-0000-0000-cafe-000000000000'
    ) {
        # Arrange
        $user = $_

        $expected = @{
            CollectionUri = 'https://dev.azure.com/myorg'
            ApiCredential = New-ApiCredential
            Result = @{
                id                  = 'some-guid'
                descriptor          = 'Microsoft.IdentityModel.Claims.ClaimsIdentity'
                providerDisplayName = 'Test User'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return $expected.Result
        }

        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }

        # Act
        $result = Get-Identity `
            -User $user `
            -CollectionUri $expected.CollectionUri

        # Assert
        $result | Should -Be $expected.Result
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -ParameterFilter {
            $Uri -like "*=$($user)*"
        }
    }
}
