BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-CurrentUserProfile' {

    It 'Should return the current user profile when valid parameters are provided' {

        # Arrange
        $expected = @{
            Connection  = New-TestApiProjectConnection
            UserProfile = @{
                id   = 'user123'
                name = 'Test User'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            return $expected.UserProfile
        }

        # Act
        $result = Get-CurrentUserProfile `
            -CollectionUri $expected.CollectionUri `
            -ApiCredential $expected.ApiCredential

        # Assert
        $result | Should -BeOfType PSCustomObject
        $result.id | Should -Be $expected.UserProfile.id
        $result.name | Should -Be $expected.UserProfile.name
    }
}
