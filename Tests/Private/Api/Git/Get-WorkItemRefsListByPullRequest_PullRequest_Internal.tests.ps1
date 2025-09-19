BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemRefsListByPullRequest_PullRequest_Internal' {

    BeforeAll {

        $expected = @{
            ApiProjectConnection = New-TestApiProjectConnection
            RepositoryId         = '96e0832a-94a2-4c0c-887e-48b8f3d2e7ed'
            PullRequestId        = 8357
            PullRequestUri       = $null
            PullRequestArtifactUri = $null
            PullRequestListObject  = $null
            PullRequestDetailObject    = $null
            Result               = @(
                @{
                    id  = 1
                    url = 'https://dev.azure.com/myorg/TestProject/_apis/wit/workitems/1'
                },
                @{
                    id  = 2
                    url = 'https://dev.azure.com/myorg/TestProject/_apis/wit/workitems/2'
                }
            )
        }

        $expected.PullRequestUri = Join-Uri `
            -Base $expected.ApiProjectConnection.ProjectBaseUri `
            -Relative '_apis/git/repositories', $expected.RepositoryId, 'pullRequests', $expected.PullRequestId `
            -NoTrailingSlash

        $expected.PullRequestArtifactUri = @(
            "vstfs:///Git/PullRequestId/"
            $expected.ApiProjectConnection.ProjectId
            '%2f'
            $expected.RepositoryId
            '%2f'
            $expected.PullRequestId
        ) -join ''

        # Detail Object has artifactId attribute
        $expected.PullRequestDetailObject = [PSCustomObject]@{
            pullRequestId = $expected.PullRequestId
            url           = $expected.PullRequestUri
            repository    = @{
                id      = $expected.RepositoryId
                project = @{
                    id = $expected.ApiProjectConnection.ProjectId
                }
            }
            artifactId    = $expected.PullRequestArtifactUri
        }

        # List Object does not have artifactId attribute
        $expected.PullRequestListObject = [PSCustomObject]@{
            pullRequestId = $expected.PullRequestId
            url           = $expected.PullRequestUri
            repository    = @{
                id      = $expected.RepositoryId
                project = @{
                    id = $expected.ApiProjectConnection.ProjectId
                }
            }
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.ApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByArtifactUri -MockWith {
            return $expected.Result
        }

        Mock -ModuleName $ModuleName -CommandName Get-PullRequest -MockWith {
            return $expected.PullRequestDetailObject
        }
    }

    Context 'When PullRequest is a PullRequest ArtifactUri' {

        It 'Should return work item references' {

            # Act
            $result = Get-WorkItemRefsListByPullRequest_PullRequest_Internal `
                -CollectionUri $expected.CollectionUri `
                -Project $expected.ProjectName `
                -PullRequest $expected.PullRequestDetailObject.artifactId

            # Assert
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByArtifactUri -ParameterFilter {
                $ArtifactUri -like $expected.PullRequestArtifactUri
            }
        }
    }

    Context 'When PullRequest is a PullRequest Uri' {

        It 'Should return work item references' {
            # Act
            $result = Get-WorkItemRefsListByPullRequest_PullRequest_Internal `
                -CollectionUri $expected.ApiProjectConnection.CollectionUri `
                -PullRequest $expected.PullRequestUri

            # Assert
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByArtifactUri -ParameterFilter {
                $ArtifactUri -like $expected.PullRequestArtifactUri
            }
        }
    }

    Context 'When PullRequest is a PullRequest Detail object' {

        It 'Should return work item references' {
            # Arrange

            # Act
            $result = Get-WorkItemRefsListByPullRequest_PullRequest_Internal `
                -CollectionUri $expected.ApiProjectConnection.CollectionUri `
                -PullRequest $expected.PullRequestDetailObject

            # Assert
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByArtifactUri -ParameterFilter {
                $ArtifactUri -like $expected.PullRequestArtifactUri
            }
        }
    }

    Context 'When PullRequest is a PullRequest List object' {

        It 'Should return work item references' {
            # Arrange

            # Act
            $result = Get-WorkItemRefsListByPullRequest_PullRequest_Internal `
                -CollectionUri $expected.ApiProjectConnection.CollectionUri `
                -PullRequest $expected.PullRequestListObject

            # Assert
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByArtifactUri -ParameterFilter {
                $ArtifactUri -like $expected.PullRequestArtifactUri
            }
        }
    }

    Context 'When PullRequest is a PullRequest id' {

        It 'Should return work item references' {
            # Arrange

            # Act
            $result = Get-WorkItemRefsListByPullRequest_PullRequest_Internal `
                -CollectionUri $expected.ApiProjectConnection.CollectionUri `
                -PullRequest $expected.PullRequestId

            # Assert
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByArtifactUri -ParameterFilter {
                $ArtifactUri -like $expected.PullRequestArtifactUri
            }
        }
    }
}
