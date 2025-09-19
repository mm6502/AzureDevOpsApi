BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Add-WorkItemRelationDescriptor' {

    BeforeEach {
        # Reset the cache before each test
        $script:WorkItemRelationDescriptorsCache = $null

        Mock -ModuleName $ModuleName Set-WorkItemRelationDescriptorsCache -MockWith {
            param($Value) $script:WorkItemRelationDescriptorsCache = $Value
        }

        Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsCache -MockWith {
            $script:WorkItemRelationDescriptorsCache
        }

        # Create test descriptors using the proper function
        $script:TestDescriptor1 = New-WorkItemRelationDescriptor `
            -Relation 'System.LinkTypes.Hierarchy-Forward' `
            -FollowFrom @('Task', 'Bug') `
            -NameOnSource 'Parent' `
            -NameOnTarget 'Child'

        $script:TestDescriptor2 = New-WorkItemRelationDescriptor `
            -Relation 'System.LinkTypes.Dependency-Forward' `
            -FollowFrom @('Task') `
            -NameOnSource 'Predecessor' `
            -NameOnTarget 'Successor'

        $script:InvalidDescriptor = [PSCustomObject]@{
            PSTypeName   = 'PSTypeNames.$ModuleName.WorkItemRelationDescriptor'
            Relation     = 'System.LinkTypes.TestRelation'
            # Missing FollowFrom, NameOnSource, NameOnTarget
        }
    }

    Context 'Parameter Validation' {

        It 'Should accept a valid descriptor with all required properties' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $TestDescriptor1 } | Should -Not -Throw
        }

        It 'Should throw when descriptor is missing Relation property' {
            # Arrange
            $invalidDescriptor = [PSCustomObject] @{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
                FollowFrom   = @('Task')
                NameOnSource = 'Source'
                NameOnTarget = 'Target'
            }

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $invalidDescriptor } | Should -Throw
        }

        It 'Should throw when descriptor is missing FollowFrom property' {
            # Arrange
            $invalidDescriptor = [PSCustomObject] @{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
                Relation     = 'System.LinkTypes.TestRelation'
                NameOnSource = 'Source'
                NameOnTarget = 'Target'
            }

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $invalidDescriptor } | Should -Throw
        }

        It 'Should throw when descriptor is missing NameOnSource property' {
            # Arrange
            $invalidDescriptor = [PSCustomObject]@{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
                Relation     = 'System.LinkTypes.TestRelation'
                FollowFrom   = @('Task')
                NameOnTarget = 'Target'
            }

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $invalidDescriptor } | Should -Throw
        }

        It 'Should throw when descriptor is missing NameOnTarget property' {
            # Arrange
            $invalidDescriptor = [PSCustomObject]@{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
                Relation     = 'System.LinkTypes.TestRelation'
                FollowFrom   = @('Task')
                NameOnSource = 'Source'
            }

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $invalidDescriptor } | Should -Throw
        }
    }

    Context 'Adding to Empty Cache' {

        It 'Should add descriptor to empty cache' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            # Act
            Add-WorkItemRelationDescriptor -Descriptor $TestDescriptor1

            # Assert
            $script:WorkItemRelationDescriptorsCache | Should -HaveCount 1
            $script:WorkItemRelationDescriptorsCache[0].Relation | Should -Be $TestDescriptor1.Relation
        }

        It 'Should add multiple descriptors with different relations' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            # Act
            Add-WorkItemRelationDescriptor -Descriptor $TestDescriptor1

            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @($TestDescriptor1) }

            # Act
            Add-WorkItemRelationDescriptor -Descriptor $TestDescriptor2

            # Assert
            $script:WorkItemRelationDescriptorsCache | Should -HaveCount 2
            $script:WorkItemRelationDescriptorsCache.Relation | Should -Contain $TestDescriptor1.Relation
            $script:WorkItemRelationDescriptorsCache.Relation | Should -Contain $TestDescriptor2.Relation
        }
    }

    Context 'Duplicate Detection' {

        It 'Should write error when adding descriptor with existing relation' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @($TestDescriptor1) }

            $duplicateDescriptor = New-WorkItemRelationDescriptor `
                -Relation $TestDescriptor1.Relation `
                -FollowFrom @('Bug') `
                -NameOnSource 'Different' `
                -NameOnTarget 'Different'

            # Act
            Add-WorkItemRelationDescriptor -Descriptor $duplicateDescriptor -ErrorVariable errorVar -ErrorAction SilentlyContinue

            # Assert
            $errorVar | Should -Not -BeNullOrEmpty
            $errorVar[0].Exception.Message | Should -Match ".*already exists.*"
        }

        It 'Should not modify cache when duplicate is detected' {
            # Arrange
            $script:WorkItemRelationDescriptorsCache = @($TestDescriptor1)

            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { $script:WorkItemRelationDescriptorsCache }

            $duplicateDescriptor = New-WorkItemRelationDescriptor `
                -Relation $TestDescriptor1.Relation `
                -FollowFrom @('Bug') `
                -NameOnSource 'Different' `
                -NameOnTarget 'Different'

            # Act
            Add-WorkItemRelationDescriptor -Descriptor $duplicateDescriptor -ErrorAction SilentlyContinue

            # Assert
            # Cache should remain unchanged
            $script:WorkItemRelationDescriptorsCache | Should -HaveCount 1
            $script:WorkItemRelationDescriptorsCache[0].Relation | Should -Be $TestDescriptor1.Relation
        }
    }

    Context 'Cache Management' {

        It 'Should call Get-WorkItemRelationDescriptorsList to get current descriptors' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            # Act
            Add-WorkItemRelationDescriptor -Descriptor $TestDescriptor1

            # Assert
            Should -Invoke -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -Exactly 1
        }

        It 'Should update the script-level cache variable' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @($TestDescriptor1) }

            # Act
            Add-WorkItemRelationDescriptor -Descriptor $TestDescriptor2

            # Assert
            $script:WorkItemRelationDescriptorsCache | Should -HaveCount 2
            $script:WorkItemRelationDescriptorsCache | Should -Contain $TestDescriptor1
            $script:WorkItemRelationDescriptorsCache | Should -Contain $TestDescriptor2
        }
    }

    Context 'Edge Cases' {

        It 'Should handle descriptor with empty FollowFrom array' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            $descriptorWithEmptyFollowFrom = New-WorkItemRelationDescriptor `
                -Relation 'System.LinkTypes.TestRelation' `
                -FollowFrom @() `
                -NameOnSource 'Source' `
                -NameOnTarget 'Target'

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $descriptorWithEmptyFollowFrom } | Should -Not -Throw
            $script:WorkItemRelationDescriptorsCache | Should -HaveCount 1
        }

        It 'Should handle descriptor with null FollowFrom' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            $descriptorWithNullFollowFrom = New-WorkItemRelationDescriptor `
                -Relation 'System.LinkTypes.TestRelation' `
                -NameOnSource 'Source' `
                -NameOnTarget 'Target'
            # Override FollowFrom to null to test edge case
            $descriptorWithNullFollowFrom.FollowFrom = $null

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $descriptorWithNullFollowFrom } | Should -Not -Throw
            $script:WorkItemRelationDescriptorsCache | Should -HaveCount 1
        }

        It 'Should handle empty and whitespace-only string properties' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            $descriptorWithEmptyStrings = [PSCustomObject]@{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
                Relation     = '   '  # Whitespace only
                FollowFrom   = @('Task')
                NameOnSource = ''     # Empty string
                NameOnTarget = 'Target'
            }

            # Act & Assert
            { Add-WorkItemRelationDescriptor -Descriptor $descriptorWithEmptyStrings } | Should -Not -Throw
            $script:WorkItemRelationDescriptorsCache | Should -HaveCount 1
        }
    }
}
