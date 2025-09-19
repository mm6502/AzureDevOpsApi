BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemRefsListByPullRequest' {

    It 'Should return work item references when valid parameters are provided' {
        # Arrange
        $expected = @{
            ApiProjectConnection = New-TestApiProjectConnection
            RepositoryId  = 'repo-guid'
            PullRequestId = 123
            PullRequest = $null
            ResultPart1 = @(
                [PSCustomObject] @{
                    id  = 1
                    url = 'https://dev.azure.com/myorg/MyProject/_apis/wit/workitems/1'
                }
            )
            ResultPart2 = @(
                [PSCustomObject] @{
                    id  = 2
                    url = 'https://dev.azure.com/myorg/MyProject/_apis/wit/workitems/2'
                }
            )
            Result = $null
        }

        $expected.Result = $expected.ResultPart1 + $expected.ResultPart2

        $expected.PullRequest = [PSCustomObject] @{
            artifactId = @(
                'vstfs:///Git/PullRequestId/'
                $expected.ApiProjectConnection.ProjectId
                '%2f'
                $expected.RepositoryId
                '%2f'
                $expected.PullRequestId
            ) -join ''
        }

        Mock -ModuleName $ModuleName -CommandName Get-PullRequestsList -MockWith {
            return $expected.PullRequest
        }

        # First partial result
        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByPullRequest_PullRequest_Internal -MockWith {
            return $expected.ResultPart1
        }

        # Second partial result
        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByPullRequest_Commit_Internal -MockWith {
            return $expected.ResultPart2
        }

        # Act
        $result = Get-WorkItemRefsListByPullRequest `
            -CollectionUri $expected.ApiProjectConnection.CollectionUri `
            -Project $expected.ApiProjectConnection.ProjectName `
            -Repository $expected.RepositoryId `
            -FromCommits

        # Assert
        $result | Should -Be $expected.Result
    }
}
