BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-CommitDiffsCount' {

    BeforeAll {
        $expected = @{
            Connection = New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
    }

    It 'Should return the diff count between base and target commits' {
        # Arrange
        $expected = @{
            Connection     = $expected.Connection
            Repository     = 'myrepo'
            RepositoryName = 'myrepo'
            SourceBranch   = 'main'
            TargetBranch   = 'feature/new-feature'
            DiffCount      = 10
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            [pscustomobject] @{
                behindCount = $expected.DiffCount
            }
        }

        # Act
        $result = (
            Get-CommitDiffsCount `
                -CollectionUri $expected.CollectionUri `
                -Project $expected.Project `
                -Repository $expected.Repository `
                -SourceBranch $expected.SourceBranch `
                -TargetBranch $expected.TargetBranch
        )

        # Assert
        $result.behindCount | Should -Be $expected.DiffCount
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "$($expected.Connection.ProjectBaseUri)*" `
            -and `
            $Uri -like "*$($expected.RepositoryName)*" `
        }
    }

    It 'Should handle repository specified as URI' {
        # Arrange
        $expected = @{
            Connection     = $expected.Connection
            Repository     = 'https://dev.azure.com/myorg/myproject/_apis/git/repositories/myrepo'
            RepositoryName = 'myrepo'
            SourceBranch   = 'main'
            TargetBranch   = 'feature/new-feature'
            DiffCount      = 10
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            [pscustomobject]@{
                count = $expected.DiffCount
            }
        }

        # Act
        $result = Get-CommitDiffsCount `
            -CollectionUri $expected.CollectionUri `
            -Repository $expected.Repository `
            -SourceBranch $expected.SourceBranch `
            -TargetBranch $expected.TargetBranch

        # Assert
        $result.count | Should -Be $expected.DiffCount
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "$($expected.Connection.ProjectBaseUri)*" `
            -and `
            $Uri -like "*$($expected.RepositoryName)*" `
        }
    }

    It 'Should handle missing parameters' {
        # Arrange
        $expected = @{
            Connection   = $expected.Connection
            Project      = 'myproject'
            Repository   = 'myrepo'
            SourceBranch = 'main'
            TargetBranch = 'feature/new-feature'
            DiffCount    = 10
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            [pscustomobject]@{
                count = $expected.DiffCount
            }
        }

        # Act
        $result = Get-CommitDiffsCount `
            -Repository $expected.Repository `
            -SourceBranch $expected.SourceBranch `
            -TargetBranch $expected.TargetBranch

        # Assert
        $result.count | Should -Be $expected.DiffCount
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "$($expected.Connection.ProjectBaseUri)*" `
            -and `
            $Uri -like "*$($expected.RepositoryName)*" `
        }
    }
}
