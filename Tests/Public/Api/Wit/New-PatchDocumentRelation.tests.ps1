[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-PatchDocumentRelation' {
    BeforeAll {
        $targetWorkItemUrl = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
        $targetWorkItem = @{
            url = $targetWorkItemUrl
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRelationDescriptorsList -MockWith {
            [PSCustomObject] @{
                Relation     = 'System.LinkTypes.Hierarchy-Reverse'
                NameOnSource = 'Parent'
            }
            [PSCustomObject] @{
                Relation     = 'System.LinkTypes.Related'
                NameOnSource = 'Related'
            }
        }
    }

    It 'Should create patch document with string URI input' {
        # Act
        $result = New-PatchDocumentRelation `
            -TargetWorkItem $targetWorkItemUrl `
            -RelationType 'System.LinkTypes.Hierarchy-Reverse'

        # Assert
        $result.op | Should -Be 'add'
        $result.path | Should -Be '/relations/-'
        $result.value.url | Should -Be $targetWorkItemUrl
        $result.value.rel | Should -Be 'System.LinkTypes.Hierarchy-Reverse'
    }

    It 'Should create patch document with work item object input' {
        # Act
        $result = New-PatchDocumentRelation `
            -TargetWorkItem $targetWorkItem `
            -RelationType 'System.LinkTypes.Hierarchy-Reverse'

        # Assert
        $result.op | Should -Be 'add'
        $result.value.url | Should -Be $targetWorkItemUrl
    }

    It 'Should find RelationType when only RelationName is provided' {
        # Act
        $result = New-PatchDocumentRelation `
            -TargetWorkItem $targetWorkItemUrl `
            -RelationName 'Parent'

        # Assert
        $result.value.rel | Should -Be 'System.LinkTypes.Hierarchy-Reverse'
        $result.value.attributes.name | Should -Be 'Parent'
    }

    It 'Should find RelationName when only RelationType is provided' {
        # Act
        $result = New-PatchDocumentRelation `
            -TargetWorkItem $targetWorkItemUrl `
            -RelationType 'System.LinkTypes.Hierarchy-Reverse'

        # Assert
        $result.value.attributes.name | Should -Be 'Parent'
    }

    It 'Should throw when neither RelationType nor RelationName is provided' {
        # Act & Assert
        { New-PatchDocumentRelation -TargetWorkItem $targetWorkItemUrl } |
        Should -Throw 'Either RelationType or RelationName must be specified.'
    }

    It 'Should set isLocked attribute to false' {
        # Act
        $result = New-PatchDocumentRelation `
            -TargetWorkItem $targetWorkItemUrl `
            -RelationType 'System.LinkTypes.Hierarchy-Reverse'

        # Assert
        $result.value.attributes.isLocked | Should -Be $false
    }

    It 'Should accept pipeline input for TargetWorkItem' {
        # Act
        $result = $targetWorkItem | New-PatchDocumentRelation -RelationType 'System.LinkTypes.Hierarchy-Reverse'

        # Assert
        $result.value.url | Should -Be $targetWorkItemUrl
    }
}
