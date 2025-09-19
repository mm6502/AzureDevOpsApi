BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-CommitsList' {

    BeforeAll {

        $expected = [PSCustomObject] @{
            Connection = New-TestApiProjectConnection
            Repo       = [PSCustomObject] @{
                id   = 'myrepo'
                name = 'My Repo'
                url  = 'https://dev.azure.com/myorg/myproject/_apis/git/repositories/myrepo'
            }
            Commit     = $null
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith { $expected.Connection }
        Mock -ModuleName $ModuleName -CommandName Get-RepositoriesList -MockWith { $expected.Repo }
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { $expected.Commit }
    }

    BeforeEach {
        # Commit is modified before returning from Get-CommitsList
        $expected.Commit = [PSCustomObject] @{
            commitId = 'abcd1234'
            comment  = 'Initial commit'
            author   = [PSCustomObject] @{
                name = 'John Doe'
                date = '2023-05-01T12:00:00Z'
            }
        }
    }

    It 'Should return commits for a repository' {
        # Act
        $commits = @(
            Get-CommitsList `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.Repo.name
        )

        # Assert
        $commits.Count | Should -Be 1
        $commits[0].commitId | Should -Be $expected.Commit.commitId
        $commits[0].author.name | Should -Be $expected.Commit.author.name
        $commits[0].comment | Should -Be $expected.Commit.comment
        $commits[0].collectionUri | Should -Be $expected.Connection.CollectionUri
        $commits[0].project.id | Should -Be $expected.Connection.ProjectId
        $commits[0].project.name | Should -Be $expected.Connection.ProjectName
        $commits[0].project.url | Should -Be $expected.Connection.ProjectUri
        $commits[0].repository.id | Should -Be $expected.Repo.id
        $commits[0].repository.name | Should -Be $expected.Repo.name
        $commits[0].repository.url | Should -Be $expected.Repo.url
    }

    It 'Should post filter commits by author - <name>' -ForEach @(
        @{ Name = 'Jo*'; Count = 1 }
        @{ Name = 'Ja*'; Count = 0 }
    ) {
        # Act
        $commits = @(
            Get-CommitsList `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.Repo.name `
                -Author $Name
        )

        # Assert
        $commits.Count | Should -Be $Count
    }

    It 'Should filter commits by author on server' -ForEach @(
        @{ Name = 'John'; Count = 1 }
    ) {
        # Act
        $commits = @(
            Get-CommitsList `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.Repo.name `
                -Author $Name
        )

        # Assert
        $commits.Count | Should -Be $Count
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -ParameterFilter {
            $Uri -like "*author=$($Name)*"
        }
    }

    It 'Should filter commits by date range' {
        # Arrange
        $expected = [PSCustomObject] @{
            DateFrom   = Format-Date '2023-04-01Z'
            DateTo     = Format-Date '2023-04-30Z'
            Connection = $expected.Connection
            Repo       = $expected.Repo
            Commit     = $expected.Commit
        }

        # Act
        $null = @(
            Get-CommitsList `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.Repo.name `
                -DateFrom $DateFrom `
                -DateTo $DateTo
        )

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -ParameterFilter {
            ($Uri -like "*fromDate=$($DateFrom)*") `
                -and `
            ($Uri -like "*toDate=$($DateTo)*") `
        }
    }

    It 'Should return simple output' {
        # Act
        $commits = @(
            Get-CommitsList `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.Repo.name `
                -Simple
        )

        # Assert
        $commits.Count | Should -Be 1
        $commits[0].project | Should -Be $expected.Connection.ProjectName
        $commits[0].repo | Should -Be $expected.Repo.name
        $commits[0].commitId | Should -Be $expected.Commit.commitId
        $commits[0].commit | Should -Be $expected.Commit.commitId.SubString(0, 8)
        $commits[0].author | Should -Be $expected.Commit.author.name
        $commits[0].dateTime | Should -Be ([datetime]($expected.Commit.author.date))
        $commits[0].comment | Should -Be $expected.Commit.comment
    }
}
