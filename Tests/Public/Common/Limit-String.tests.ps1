BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Limit-String' {

    It 'Should return unique strings that match include and exclude filters' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        $include = @('*d*')
        $exclude = @('*e*')
        # Act
        $result = $inputs | Limit-String -Include $include -Exclude $exclude
        # Assert
        $result | Should -BeExactly @('bcd')
    }

    It 'Should return all strings when no filters are provided' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        # Act
        $result = $inputs | Limit-String
        # Assert
        $result | Should -BeExactly $inputs
    }

    It 'Should return empty array when no input is provided' {
        # Act
        $result = @() | Limit-String
        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should respect case sensitivity when -CaseSensitive is provided' {
        # Arrange
        $inputs = @('ABC', 'abc', 'DEF', 'def')
        $include = @('abc')
        # Act
        $result = $inputs | Limit-String -Include $include -CaseSensitive
        # Assert
        $result | Should -BeExactly @('abc')
    }

    It 'Should handle null and empty inputs' {
        # Arrange
        $inputs = @('abc', $null, '', 'def')
        $include = @('*e*')
        $exclude = @('a*')
        # Act
        $result = $inputs | Limit-String -Include $include -Exclude $exclude
        # Assert
        $result | Should -BeExactly @('def')
    }

    It 'Should handle includes and excludes' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        $include = @('*')
        $exclude = @('Abc', 'B*', '*E')
        # Act
        $result = $inputs | Limit-String -Include $include -Exclude $exclude
        # Assert
        $result | Should -BeExactly @('def')
    }

    It 'Should handle null and empty filters' {
        # Arrange
        $inputs = @('abc', 'bcd', 'cde', 'def')
        $include = $null
        $exclude = @()
        # Act
        $result = $inputs | Limit-String -Include $include -Exclude $exclude
        # Assert
        $result | Should -BeExactly $inputs
    }

    It 'Should handle multiple excludes' {

        # Arrange
        $inputs = @(
            'WorkItemId'
            'InclusionReason'
            'TestedWorkItemStates'
            'WorkItemType'
            'Title'
            'State'
            'Reason'
            'AreaPath'
            'IterationPath'
            'CatalogueRequestNumber'
            'ExternalIdentificationNumber'
            'AssignedToDisplayName'
            'AssignedToUniqueName'
            'Discipline'
            'ResolvedDate'
            'ResolvedByDisplayName'
            'ResolvedByUniqueName'
            'ResolvedReason'
            'ClosedDate'
            'ClosedByDisplayName'
            'ClosedByUniqueName'
            'RequiresTest'
            'OriginalEstimate'
            'CompletedWork'
            'RemainingWork'
            'TargetDate'
            'Tags'
            'Parent'
        )

        $IncludeProperties = @('*')

        $ExcludeProperties = @(
            'Created*',
            'Resolved*',
            'Closed*',
            'Discipline',
            'Target*',
            'Requires*',
            'RemainingWork',
            'CompletedWork',
            '*Estimate',
            'AssignedTo*'
        )

        # Act
        $result = $inputs `
        | Limit-String `
            -Include $IncludeProperties `
            -Exclude $ExcludeProperties

        # Assert
        foreach ($item in $result) {
            foreach ($property in $ExcludeProperties) {
                $item | Should -Not -BeLike $property
            }
        }
    }
}
