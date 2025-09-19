BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-PullRequestsList' {

    BeforeEach {
        $expected = @{
            Connection     = New-TestApiProjectConnection
            RepositoryId   = 'repo123'
            RepositoryName = 'MyRepository'
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Get-RepositoriesList -MockWith {
            ([PSCustomObject] @{ id = $expected.RepositoryId })
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            ([PSCustomObject] @{
                repository    = [PSCustomObject] @{
                    name = $expected.RepositoryName
                    id = $expected.RepositoryId
                }
                pullRequestId = 1
                title         = 'PR 1'
                closedDate    = [datetime]::Parse('2024-01-01Z').ToUniversalTime()
                createdDate   = [datetime]::Parse('2024-01-01Z').ToUniversalTime()
            })
            ([PSCustomObject] @{
                repository    = [PSCustomObject] @{
                    name = $expected.RepositoryName
                    id   = $expected.RepositoryId
                }
                pullRequestId = 2
                title         = 'PR 2'
                closedDate    = [datetime]::Parse('2024-01-02Z').ToUniversalTime()
                createdDate   = [datetime]::Parse('2024-01-02Z').ToUniversalTime()
            })
        }
    }

    It 'Should return a list of pull requests' {
        # Act
        $pullRequests = @(
            Get-PullRequestsList `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.RepositoryId `
                -CollectionUri $expected.Connection.CollectionUri
        )

        # Assert
        $pullRequests.Count | Should -Be 2
        $item1 = $pullRequests | Where-Object { $_.pullRequestId -eq 1 } | Select-Object -First 1
        $item1.pullRequestId | Should -Be 1
        $item1.title | Should -Be 'PR 1'
        $item2 = $pullRequests | Where-Object { $_.pullRequestId -eq 2 } | Select-Object -First 1
        $item2.pullRequestId | Should -Be 2
        $item2.title | Should -Be 'PR 2'
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -ParameterFilter {
            ($ApiCredential -eq $expected.Connection.ApiCredential) `
            -and `
            ($Uri -like "$($expected.Connection.ProjectBaseUri)*") `
            -and `
            ($Uri -like "*$($expected.RepositoryId)*") `
        }
    }

    It 'Should return an empty list when no pull requests exist in given time range' {
        # Act
        $pullRequests = @(
            Get-PullRequestsList `
                -Project $expected.ProjectName `
                -Repository $expected.RepositoryId `
                -CollectionUri $expected.CollectionUri `
                -FromDate '2020-01-01' `
                -ToDate '2020-01-02' `
        )

        # Assert
        $pullRequests.Count | Should -Be 0
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -ParameterFilter {
            ($ApiCredential -eq $expected.Connection.ApiCredential) `
            -and `
            ($Uri -like "$($expected.Connection.ProjectBaseUri)*") `
            -and `
            ($Uri -like "*$($expected.RepositoryId)*") `
        }
    }
}
