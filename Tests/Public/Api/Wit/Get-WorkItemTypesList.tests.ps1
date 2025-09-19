BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemTypesList' {

    BeforeAll {
        $expected = @{
            Connection = New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
    }

    It 'Should return work item types for a project' {
        # Arrange
        $expected = @{
            Connection = $expected.Connection
            Item1Type = 'Bug'
            Item2Type = 'Task'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @(
                [PSCustomObject] @{
                    name          = $expected.Item1Type
                    referenceName = $expected.Item1Type
                },
                [PSCustomObject] @{
                    name          = $expected.Item2Type
                    referenceName = $expected.Item2Type
                }
            )
        }

        # Act
        $result = Get-WorkItemTypesList -Project 'myproject'

        # Assert
        $result.Count | Should -Be 2
        $result[0].name | Should -Be $expected.Item1Type
        $result[1].name | Should -Be $expected.Item2Type
    }

    It 'Should handle null or empty Project' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { }

        # Act & Assert
        { Get-WorkItemTypesList -Project $null } | Should -Not -Throw
        { Get-WorkItemTypesList -Project '' } | Should -Not -Throw
    }

    It 'Should handle custom CollectionUri and ApiCredential' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { }

        # Act & Assert
        { Get-WorkItemTypesList `
            -Project $expected.ProjectName `
            -CollectionUri $expected.CollectionUri
        } | Should -Not -Throw
    }
}
