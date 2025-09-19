BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-RepositoriesList' {

    BeforeAll {
        $expected = @{
            Connection = New-TestApiProjectConnection
            Repositories = @(
                [PSCustomObject] @{ id = 'repo1'; name = 'Repo1' }
                [PSCustomObject] @{ id = 'repo2'; name = 'Repo2' }
            )
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return $expected.Repositories
        }
    }

    It 'Should return list of repositories' {
        # Act
        $result = Get-RepositoriesList `
            -CollectionUri $expected.Connection.CollectionUri `
            -Project $expected.Connection.ProjectName

        # Assert
        $result.id | Should -Be $expected.Repositories.id
    }

    It 'Should return filtered list of repositories' {
        # Arrange
        $expected.FilteredRepositories = @(
            [PSCustomObject] @{ id = 'repo1'; name = 'Repo1' }
        )

        # Act
        $result = Get-RepositoriesList `
            -CollectionUri $expected.CollectionUri `
            -Project $expected.Project `
            -Repository 'repo1'

        # Assert
        $result.id | Should -Be $expected.FilteredRepositories.id
    }
}
