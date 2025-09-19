BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-PullRequest' {

    BeforeAll {
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return [PSCustomObject] @{
                CollectionUri = 'https://dev.azure.com/myorg'
                ApiCredential = New-ApiCredential
                ApiVersion    = '6.0'
            }
        }
    }

    Context 'When given a pull request artifact URI' {

        It 'Should return the pull request details' {
            # Arrange
            $collectionUri = 'https://dev.azure.com/myorg'
            $pullRequestId = 8357
            $pullRequestUri = "$($collectionUri)/_apis/git/pullrequests/$($pullRequestId)"
            $artifactUri = "vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f$($pullRequestId)"

            $expected = [PSCustomObject] @{
                CollectionUri  = 'https://dev.azure.com/myorg'
                ArtifactUri    = $artifactUri
                PullRequestUri = $pullRequestUri
                PullRequestId  = $pullRequestId
                Response       = @{
                    pullRequestId = $pullRequestId
                    title         = 'Test Pull Request'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
                return $expected.Response
            }

            # Act
            $result = Get-PullRequest -PullRequest $expected.ArtifactUri

            # Assert
            $result | Should -Be $expected.Response
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
                $Uri -eq $expected.PullRequestUri
            }
        }
    }

    Context 'When given a pull request URL' {

        It 'Should return the pull request details' {
            # Arrange
            $collectionUri = 'https://dev.azure.com/myorg'
            $pullRequestId = 8357
            $pullRequestUri = "$($collectionUri)/myproject/_apis/git/pullrequests/$($pullRequestId)"

            $expected = [PSCustomObject] @{
                CollectionUri  = $collectionUri
                PullRequestUri = $pullRequestUri
                PullRequestId  = $pullRequestId
                Response       = @{
                    pullRequestId = $pullRequestId
                    title         = 'Test Pull Request'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
                return $expected.Response
            }

            # Act
            $result = Get-PullRequest -PullRequest $expected.PullRequestUri

            # Assert
            $result | Should -Be $expected.Response
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
                $Uri -eq $expected.PullRequestUri
            }
        }
    }

    Context 'When given a pull request ID' {

        It 'Should return the pull request details' {
            # Arrange
            $collectionUri = 'https://dev.azure.com/myorg'
            $pullRequestId = 8357
            $pullRequestUri = "$($collectionUri)/_apis/git/pullRequests/$($pullRequestId)"

            $expected = [PSCustomObject] @{
                CollectionUri  = $collectionUri
                PullRequestUri = $pullRequestUri
                PullRequestId  = $pullRequestId
                Response       = @{
                    pullRequestId = $pullRequestId
                    title         = 'Test Pull Request'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
                return $expected.Response
            }

            # Act
            $result = Get-PullRequest -PullRequest $expected.PullRequestId -CollectionUri $expected.CollectionUri

            # Assert
            $result | Should -Be $expected.Response
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
                $Uri -eq $expected.PullRequestUri
            }
        }
    }

    Context 'When given null or empty input' {

        It 'Should return null for null input' {
            # Act
            $result = Get-PullRequest -PullRequest $null

            # Assert
            $result | Should -BeNullOrEmpty
        }

        It 'Should return null for empty string input' {
            # Act
            $result = Get-PullRequest -PullRequest ''

            # Assert
            $result | Should -BeNullOrEmpty
        }

        It 'Should return null for empty array input' {
            # Act
            $result = Get-PullRequest -PullRequest @()

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }
}
