BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemRefsListByPullRequest_Commit_Internal' {

    BeforeEach {

        $connection = New-TestApiProjectConnection
        $workItemUri = Join-Uri `
            -Base $connection.CollectionUri `
            -Relative '_apis/wit/workitems/1' `
            -NoTrailingSlash

        $expected = @{
            ApiProjectConnection    = $connection
            PullRequest             = @{
                url = Join-Uri `
                    -Base $connection.CollectionUri `
                    -Relative '_apis/git/pullrequests/1' `
                    -NoTrailingSlash
            }
            CommitArtifactUriObject = @{ ArtifactUri = 'vstfs:///Git/Commit/123' }
            CommitUri               = Join-Uri `
                -Base $connection.CollectionUri `
                -Relative '_apis/git/repositories/FakeRepo/commits/123' `
                -NoTrailingSlash
            WorkItemRef             = @{ id = 1; url = $workItemUri }
        }

        Mock -ModuleName $ModuleName Get-ApiProjectConnection {
            return $expected.ApiProjectConnection
        }

        Mock -ModuleName $ModuleName Invoke-ApiListPaged {
            return @(
                @{ url = $expected.CommitUri }
            )
        }

        Mock -ModuleName $ModuleName ConvertTo-CommitArtifactUriObject {
            return $expected.CommitArtifactUriObject
        }

        Mock -ModuleName $ModuleName Get-WorkItemRefsListByArtifactUri {
            return @($expected.WorkItemRef)
        }
    }

    It 'Should return work item refs when given a valid pull request' {
        # Act
        $result = Get-WorkItemRefsListByPullRequest_Commit_Internal -PullRequest $expected.PullRequest
        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.id | Should -Be 1
        $result.url | Should -Be $expected.WorkItemRef.url
    }

    It 'Should return null when given a null pull request' {
        # Act
        $result = Get-WorkItemRefsListByPullRequest_Commit_Internal -PullRequest $null
        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle empty commits list' {
        # Arrange
        Mock -ModuleName $ModuleName Invoke-ApiListPaged { return @() }
        # Act
        $result = Get-WorkItemRefsListByPullRequest_Commit_Internal -PullRequest $expected.PullRequest
        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should use default values when CollectionUri and ApiCredential are not provided' {
        # Act
        Get-WorkItemRefsListByPullRequest_Commit_Internal -PullRequest $expected.PullRequest
        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -ParameterFilter {
            $CollectionUri -eq $null -and $ApiCredential -eq $null
        }
    }

    It 'Should use provided CollectionUri' {
        # Arrange
        $customUri = 'https://custom.azure.com/org'

        # Act
        Get-WorkItemRefsListByPullRequest_Commit_Internal `
            -PullRequest $expected.PullRequest `
            -CollectionUri $customUri

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -ParameterFilter {
            ($CollectionUri -eq $customUri)
        }
    }
}
