BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ProjectsList' {

    Context 'When CollectionUri and ApiCredential are provided' {

        It 'Should return a list of projects' {
            # Arrange
            $expected = @{
                Connection = New-TestApiCollectionConnection
                Top        = 3
                Skip       = 5
            }

            # Mock the API calls
            Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionConnection -MockWith {
                return $expected.Connection
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
                ([PSCustomObject] @{
                    url  = Join-Uri `
                        -Base $expected.Connection.CollectionUri `
                            -Relative '_apis/projects/project1' `
                            -NoTrailingSlash
                    id   = 'project1'
                    name = 'Project_1'
                })
                ([PSCustomObject] @{
                    url  = Join-Uri `
                        -Base $expected.Connection.CollectionUri `
                        -Relative '_apis/projects/project2' `
                        -NoTrailingSlash
                    id   = 'project2'
                    name = 'Project_2'
                })
            }

            # Act
            $projects = @(
                Get-ProjectsList `
                    -CollectionUri $expected.Connection.CollectionUri `
                    -Top $expected.Top `
                    -Skip $expected.Skip
            )

            # Assert
            $projects.Count | Should -Be 2
            $projects[0].id | Should -Be 'project1'
            $projects[0].name | Should -Be 'Project_1'
            $projects[1].id | Should -Be 'project2'
            $projects[1].name | Should -Be 'Project_2'
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -ParameterFilter {
                ($ApiCredential -eq $expected.Connection.ApiCredential) `
                -and `
                ($Uri -like "$($expected.Connection.CollectionUri)*") `
                -and `
                ($Top -eq $expected.Top) `
                -and `
                ($Skip -eq $expected.Skip) `
            }
        }
    }
}
