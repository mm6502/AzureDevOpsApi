[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Select-WorkItemRelationDescriptor' {

    BeforeAll {

        $mockRelationDescriptors = @(
            @{
                Relation = 'System.LinkTypes.Hierarchy-Forward'
                FollowFrom = @('Epic', 'Feature')
            },
            @{
                Relation = 'System.LinkTypes.Related'
                FollowFrom = @('Bug', 'Task')
            }
        )

        $mockWorkItem = @{
            fields = @{
                'System.WorkItemType' = 'Feature'
            }
        }

        $mockRelation = @{
            rel = 'System.LinkTypes.Hierarchy-Forward'
        }
    }

    It 'Should return null when WorkItem is not provided' {
        # Act
        $result = Select-WorkItemRelationDescriptor `
            -RelationDescriptors $mockRelationDescriptors `
            -Relation $mockRelation
        # Assert
        $result | Should -BeNull
    }

    It 'Should return null when Relation is not provided' {
        # Act
        $result = Select-WorkItemRelationDescriptor `
            -RelationDescriptors $mockRelationDescriptors `
            -WorkItem $mockWorkItem
        # Assert
        $result | Should -BeNull
    }

    It 'Should return the correct descriptor when all parameters are valid' {
        # Act
        $result = Select-WorkItemRelationDescriptor `
            -RelationDescriptors $mockRelationDescriptors `
            -WorkItem $mockWorkItem `
            -Relation $mockRelation
        # Assert
        $result | Should -Be $mockRelationDescriptors[0]
    }

    It 'Should return null when no matching descriptor is found' {
        # Arrange
        $nonMatchingRelation = 'System.LinkTypes.NonExistent'
        # Act
        $result = Select-WorkItemRelationDescriptor `
            -RelationDescriptors $mockRelationDescriptors `
            -WorkItem $mockWorkItem `
            -Relation $nonMatchingRelation
        # Assert
        $result | Should -BeNull
    }

    It 'Should be case-insensitive when matching work item types' {
        $lowercaseWorkItem = @{
            fields = @{
                'System.WorkItemType' = 'feature'
            }
        }
        $result = Select-WorkItemRelationDescriptor `
            -RelationDescriptors $mockRelationDescriptors `
            -WorkItem $lowercaseWorkItem `
            -Relation $mockRelation
        $result | Should -Be $mockRelationDescriptors[0]
    }

    It 'Should return the first matching descriptor when multiple matches are found' {
        $multipleMatchDescriptors = @(
            @{
                Relation = 'System.LinkTypes.Hierarchy-Forward'
                FollowFrom = @('Epic', 'Feature')
            },
            @{
                Relation = 'System.LinkTypes.Hierarchy-Forward'
                FollowFrom = @('Feature', 'Story')
            }
        )
        $result = Select-WorkItemRelationDescriptor `
            -RelationDescriptors $multipleMatchDescriptors `
            -WorkItem $mockWorkItem `
            -Relation $mockRelation
        $result | Should -Be $multipleMatchDescriptors[0]
    }
}
