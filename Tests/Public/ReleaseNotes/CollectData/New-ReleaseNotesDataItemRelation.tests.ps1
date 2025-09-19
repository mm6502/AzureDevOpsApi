BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-ReleaseNotesDataItemRelation' {
    It 'Should create an object with correct PSTypeName' {
        # Act
        $result = New-ReleaseNotesDataItemRelation -RelationName 'TestRelation'
        # Assert
        $result.PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItemRelation'
    }

    It 'Should set the Name property correctly' {
        # Arrange
        $relationName = 'TestRelation'
        # Act
        $result = New-ReleaseNotesDataItemRelation -RelationName $relationName
        # Assert
        $result.Name | Should -Be $relationName
    }

    It 'Should create an empty HashSet when no Relations are provided' {
        # Act
        $result = New-ReleaseNotesDataItemRelation -RelationName 'TestRelation'
        # Assert
        ($null -ne $result.Relations) | Should -BeTrue
        $result.Relations.Count | Should -Be 0
    }

    It 'Should create a HashSet with provided Relations' {
        # Arrange
        $relations = @('Relation1', 'Relation2', 'Relation3')
        # Act
        $result = New-ReleaseNotesDataItemRelation -RelationName 'TestRelation' -Relations $relations
        # Assert
        ($null -ne $result.Relations) | Should -BeTrue
        $result.Relations.Count | Should -Be $relations.Count
        foreach ($relation in $relations) {
            $result.Relations.Contains($relation) | Should -BeTrue
        }
    }

    It 'Should handle duplicate Relations' {
        # Arrange
        $relations = @('Relation1', 'Relation2', 'Relation1', 'Relation3')
        # Act
        $result = New-ReleaseNotesDataItemRelation -RelationName 'TestRelation' -Relations $relations
        # Assert
        $result.Relations.Count | Should -Be 3
    }

    It 'Should handle empty string in Relations' {
        # Arrange
        $relations = @('Relation1', '', 'Relation2')
        # Act
        $result = New-ReleaseNotesDataItemRelation -RelationName 'TestRelation' -Relations $relations
        # Assert
        $result.Relations.Count | Should -Be 3
        $result.Relations.Contains('') | Should -BeTrue
    }
}
