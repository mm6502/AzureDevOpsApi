BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Submit-PullRequests' {

    BeforeAll {

        $mocks = [PSCustomObject] @{
            AllRepositories = @(
                [PSCustomObject] @{ name = 'repo1' }
                [PSCustomObject] @{ name = 'repo2' }
                [PSCustomObject] @{ name = 'repo3' }
                [PSCustomObject] @{ name = 'repo4' }
            )

            PullRequest1    = [PSCustomObject] @{
                repositoryId  = 'repo1'
                sourceRefName = 'refs/heads/feature1'
                targetRefName = 'refs/heads/main'
                title         = 'PR 1'
                status        = 'completed'
            }

            PullRequest2    = [PSCustomObject] @{
                repositoryId  = 'repo2'
                sourceRefName = 'refs/heads/feature2'
                targetRefName = 'refs/heads/main'
                title         = 'PR 2'
                status        = 'completed'
            }

            PullRequest3    = [PSCustomObject] @{
                repositoryId  = 'repo3'
                sourceRefName = 'refs/heads/feature3'
                targetRefName = 'refs/heads/main'
                title         = 'PR 3'
                status        = 'completed'
            }

            PullRequest4    = [PSCustomObject] @{
                repositoryId  = 'repo4'
                sourceRefName = 'refs/heads/feature4'
                targetRefName = 'refs/heads/main'
                title         = 'PR 4'
                status        = 'active'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Get-RepositoriesList -MockWith {
            return $mocks.AllRepositories
        }

        Mock -ModuleName $ModuleName -CommandName New-PullRequest -MockWith {
            return $mocks.PullRequest1
        } -ParameterFilter {
            $Repository -eq 'repo1'
        }

        Mock -ModuleName $ModuleName -CommandName New-PullRequest -MockWith {
            return $mocks.PullRequest2
        } -ParameterFilter {
            $Repository -eq 'repo2'
        }

        Mock -ModuleName $ModuleName -CommandName New-PullRequest -MockWith {
            return $mocks.PullRequest3
        } -ParameterFilter {
            $Repository -eq 'repo3'
        }

        Mock -ModuleName $ModuleName -CommandName New-PullRequest -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
    }

    Context 'Without AutoComplete' {
        It 'Should filter repositories' {
            # Act
            $results = @(
                Submit-PullRequests `
                    -SourceBranch 'dev' `
                    -TargetBranch 'main' `
                    -IncludeRepository 'repo1', 'repo2', 'repo3' `
                    -ExcludeRepository 'repo2' `
                    -PassThru
            )

            # Assert
            $results.Count | Should -Be 2
        }
    }

    Context 'With AutoComplete' {
        It 'Should warn when a PullRequest is not completed' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName New-PullRequest -MockWith {
                return $mocks.PullRequest4
            } -ParameterFilter {
                $Repository -eq 'repo4'
            }

            # Act & Assert
            { Submit-PullRequests `
                    -SourceBranch 'dev' `
                    -TargetBranch 'main' `
                    -AutoComplete
            } | Should -Throw -ExpectedMessage "*completed*"
        }

        It 'Should warn when a PullRequest is not created' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName New-PullRequest -MockWith {
                throw "Error"
            } -ParameterFilter {
                $Repository -eq 'repo4'
            }

            # Act & Assert
            { Submit-PullRequests `
                    -SourceBranch 'dev' `
                    -TargetBranch 'main' `
                    -AutoComplete
            } | Should -Throw -ExpectedMessage "*created*"
        }
    }
}