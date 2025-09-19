[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Add-ReleaseNotesDataItemRelation' {

    BeforeEach {
        $testReleaseNotesData = @{
            '1' = New-ReleaseNotesDataItem -WorkItemUrl '1'
        }
    }

    It 'Should add a new relation when it does not exist' {
        # Act
        $result = Add-ReleaseNotesDataItemRelation `
            -ReleaseNotesData $testReleaseNotesData `
            -SourceWorkItemUrl '1' `
            -TargetWorkItemUrl '2' `
            -RelationName 'Parent'

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.Name | Should -Be 'Parent'
        $result.Relations | Should -Contain '2'
        $testReleaseNotesData['1'].RelationsList | Should -HaveCount 1
    }

    It 'Should add a target to an existing relation' {
        # Arrange
        Add-ReleaseNotesDataItemRelation `
            -ReleaseNotesData $testReleaseNotesData `
            -SourceWorkItemUrl '1' `
            -TargetWorkItemUrl '2' `
            -RelationName 'Parent'

        # Act
        $result = Add-ReleaseNotesDataItemRelation `
            -ReleaseNotesData $testReleaseNotesData `
            -SourceWorkItemUrl '1' `
            -TargetWorkItemUrl '3' `
            -RelationName 'Parent'

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.Name | Should -Be 'Parent'
        $result.Relations | Should -Contain '2'
        $result.Relations | Should -Contain '3'
        $testReleaseNotesData['1'].RelationsList | Should -HaveCount 1
    }

    It 'Should return null when source work item does not exist' {
        # Act
        $result = Add-ReleaseNotesDataItemRelation `
            -ReleaseNotesData $testReleaseNotesData `
            -SourceWorkItemUrl '999' `
            -TargetWorkItemUrl '2' `
            -RelationName 'Parent'

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should return null when any of the required parameters are null or empty - <name>' -ForEach @(
        @{ Name = 'Source'  ; SourceWorkItemUrl = '' ; TargetWorkItemUrl = '2'; RelationName = 'Parent' }
        @{ Name = 'Target'  ; SourceWorkItemUrl = '1'; TargetWorkItemUrl = '' ; RelationName = 'Parent' }
        @{ Name = 'Relation'; SourceWorkItemUrl = '1'; TargetWorkItemUrl = '2'; RelationName = ''       }
    ) {
        # Act
        $result = Add-ReleaseNotesDataItemRelation `
            -ReleaseNotesData $testReleaseNotesData `
            -SourceWorkItemUrl $SourceWorkItemUrl `
            -TargetWorkItemUrl $TargetWorkItemUrl `
            -RelationName $RelationName

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should be case-insensitive for RelationName' {
        # Act
        $result1 = Add-ReleaseNotesDataItemRelation `
            -ReleaseNotesData $testReleaseNotesData `
            -SourceWorkItemUrl '1' `
            -TargetWorkItemUrl '4' `
            -RelationName 'PARENT'
        $result2 = Add-ReleaseNotesDataItemRelation `
            -ReleaseNotesData $testReleaseNotesData `
            -SourceWorkItemUrl '1' `
            -TargetWorkItemUrl '5' `
            -RelationName 'parent'

        # Assert
        $result1 | Should -Not -BeNullOrEmpty
        $result2 | Should -Not -BeNullOrEmpty
        $result1.Relations | Should -Contain '4'
        $result2.Relations | Should -Contain '5'
        $testReleaseNotesData['1'].RelationsList | Should -HaveCount 1
    }
}
