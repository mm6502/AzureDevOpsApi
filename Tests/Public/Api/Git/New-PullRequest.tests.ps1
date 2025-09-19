[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-PullRequest' {
    BeforeAll {

        $expected = [PSCustomObject] @{
            Connection   = New-TestApiProjectConnection
            RepositoryId = 'repo-id'
            SourceRef    = 'refs/heads/feature'
            TargetRef    = 'refs/heads/main'

            PullRequest  = [PSCustomObject] @{
                pullRequestId = 123
                name          = 'repo-name'
                mergeStatus   = 'succeeded'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection { return $expected.Connection }
        Mock -ModuleName $ModuleName -CommandName Get-CommitDiffsCount { return @{ behindCount = 1 } }
    }

    Context 'Without AutoComplete' {
        It 'Should work' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Invoke-Api { return $expected.PullRequest } -ParameterFilter {
                $null -ne $Body
            }

            # Act
            $result = New-PullRequest `
                -CollectionUri $expected.Connection.CollectionUri `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.RepositoryId `
                -SourceBranch 'feature' `
                -TargetBranch 'main'

            # Assert
            $result | Should -Be $expected.PullRequest
        }
    }

    Context 'With AutoComplete' {

        BeforeAll {
            Mock -ModuleName $ModuleName -CommandName Get-CurrentUser -MockWith { return @{ id = 'user-id' } }
            Mock -ModuleName $ModuleName -CommandName Start-Sleep -MockWith { }
        }

        It 'Should work when queued' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Invoke-Api { return $expected.PullRequest } -ParameterFilter {
                $null -ne $Body
            }

            $PullRequestQueued = [PSCustomObject] @{
                pullRequestId = 123
                name          = 'repo-name'
                mergeStatus   = 'queued'
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api { return $PullRequestQueued } -ParameterFilter {
                $Method -eq 'PATCH'
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api { return $expected.PullRequest } -ParameterFilter {
                $a = $null -eq $Method
                $b = $Uri -like "*/pullrequests/$($PullRequestQueued.pullRequestId)*"
                $z = $a -and $b
                $z
            }

            # Act
            $result = New-PullRequest `
                -CollectionUri $expected.Connection.CollectionUri `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.RepositoryId `
                -SourceBranch 'feature' `
                -TargetBranch 'main' `
                -AutoComplete

            # Assert
            $result | Should -Be $expected.PullRequest
        }

        It 'Should warn when conflicts' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }

            $PullRequestQueued = [PSCustomObject] @{
                pullRequestId = 123
                name          = 'repo-name'
                mergeStatus   = 'conflicts'
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api { return $expected.PullRequest } -ParameterFilter {
                $null -ne $Body
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api { return $PullRequestQueued } -ParameterFilter {
                $Method -eq 'PATCH'
            }

            # Act
            $result = New-PullRequest `
                -CollectionUri $expected.Connection.CollectionUri `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.RepositoryId `
                -SourceBranch 'feature' `
                -TargetBranch 'main' `
                -AutoComplete

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Write-Warning -Exactly -Times 1 -Scope It
        }

        It 'Should warn when queued too long' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }

            $PullRequestQueued = [PSCustomObject] @{
                pullRequestId = 123
                name          = 'repo-name'
                mergeStatus   = 'queued'
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api { return $PullRequestQueued }

            # Act
            $result = New-PullRequest `
                -CollectionUri $expected.Connection.CollectionUri `
                -Project $expected.Connection.ProjectName `
                -Repository $expected.RepositoryId `
                -SourceBranch 'feature' `
                -TargetBranch 'main' `
                -AutoComplete

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Write-Warning -Exactly -Times 1 -Scope It
        }
    }
}
