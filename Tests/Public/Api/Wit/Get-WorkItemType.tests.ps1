BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemType' {

    It 'Should return the correct work item type' -ForEach @(
        @{ WorkItemType = 'Bug' }
        @{ WorkItemType = 'Task' }
    ) {
        # Arrange
        $workItem = [PSCustomObject] @{
            fields = @{
                'System.WorkItemType' = $WorkItemType
            }
        }

        # Act
        $result = Get-WorkItemType -WorkItem $workItem

        # Assert
        $result | Should -Be $WorkItemType
    }

    It 'Should handle missing System.WorkItemType field' {
        # Arrange
        $workItem = [PSCustomObject]@{
            fields = @{}
        }

        # Act
        $result = Get-WorkItemType -WorkItem $workItem

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle null work item' {
        # Act & Assert
        { Get-WorkItemType -WorkItem $null } | Should -Throw
    }

    It 'Should accept pipeline input' {
        # Arrange
        $workItems = @(
            [PSCustomObject] @{ fields = @{ 'System.WorkItemType' = 'Task' } },
            [PSCustomObject] @{ fields = @{ 'System.WorkItemType' = 'User Story' } }
        )

        # Act
        $results = $workItems | Get-WorkItemType

        # Assert
        $results.Count | Should -Be 2
        $results[0] | Should -Be 'Task'
        $results[1] | Should -Be 'User Story'
    }
}
