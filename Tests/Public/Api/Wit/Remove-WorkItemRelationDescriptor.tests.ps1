[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')

    # Rewrite global cache variable to be script-scoped for testing
    $script:WorkItemRelationDescriptorsCache = $null

    function Set-WorkItemRelationDescriptorsCache {
        param($Value) $script:WorkItemRelationDescriptorsCache = $Value
    }

    function Get-WorkItemRelationDescriptorsCache {
        $script:WorkItemRelationDescriptorsCache
    }

    Mock -ModuleName $ModuleName -CommandName Set-WorkItemRelationDescriptorsCache -MockWith {
        param($Value) Set-WorkItemRelationDescriptorsCache -Value $Value
    }

    Mock -ModuleName $ModuleName -CommandName Get-WorkItemRelationDescriptorsCache -MockWith {
        Get-WorkItemRelationDescriptorsCache
    }
}

Describe 'Remove-WorkItemRelationDescriptor' {

    BeforeEach {
        # Reset the cache before each test
        Set-WorkItemRelationDescriptorsCache -Value $null

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

        $script:TestDescriptor3 = New-WorkItemRelationDescriptor `
            -Relation 'System.LinkTypes.Hierarchy-Reverse' `
            -FollowFrom @('Bug') `
            -NameOnSource 'Child' `
            -NameOnTarget 'Parent'
    }

    Context 'Parameter Validation' {

        It 'Should accept a valid relation string' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { $TestDescriptor1 }

            # Act & Assert
            { Remove-WorkItemRelationDescriptor -Relation $TestDescriptor1.Relation } | Should -Not -Throw
        }

        It 'Should be mandatory parameter' {
            # Assert
            { Remove-WorkItemRelationDescriptor -Relation $null } | Should -Throw
        }
    }

    Context 'Removing Existing Descriptors' {

        It 'Should remove descriptor when relation exists' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith {
                @($TestDescriptor1, $TestDescriptor2, $TestDescriptor3)
            }

            # Act
            Remove-WorkItemRelationDescriptor -Relation $TestDescriptor2.Relation

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty
            $cache | Should -HaveCount 2
            $cache.Relation | Should -Not -Contain $TestDescriptor2.Relation
            $cache.Relation | Should -Contain $TestDescriptor1.Relation
            $cache.Relation | Should -Contain $TestDescriptor3.Relation
        }

        It 'Should remove all matching descriptors when multiple have same relation' {
            # Arrange
            $duplicateDescriptor = New-WorkItemRelationDescriptor `
                -Relation $TestDescriptor1.Relation `
                -FollowFrom @('Feature') `
                -NameOnSource 'Different Source' `
                -NameOnTarget 'Different Target'

            Set-WorkItemRelationDescriptorsCache `
                -Value @($TestDescriptor1, $duplicateDescriptor, $TestDescriptor2)

            # Act
            Remove-WorkItemRelationDescriptor -Relation $TestDescriptor1.Relation

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty
            $cache | Should -HaveCount 1
            $cache.Relation | Should -Not -Contain $TestDescriptor1.Relation
            $cache.Relation | Should -Contain $TestDescriptor2.Relation
        }

        It 'Should remove descriptor from single-item cache' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1)

            # Act
            Remove-WorkItemRelationDescriptor -Relation $TestDescriptor1.Relation

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }
    }

    Context 'Non-Existing Descriptors' {

        It 'Should write warning when relation does not exist' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1)

            # Act
            $warningVar = @()
            Remove-WorkItemRelationDescriptor `
                -Relation 'Non.Existing.Relation' `
                -WarningVariable warningVar `
                -WarningAction SilentlyContinue

            # Assert
            $warningVar | Should -Not -BeNullOrEmpty
            $warningVar[0] | Should -Match "No descriptor found with Relation: Non.Existing.Relation"
        }

        It 'Should not modify cache when relation does not exist' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1, $TestDescriptor2)

            # Act
            Remove-WorkItemRelationDescriptor -Relation 'Non.Existing.Relation' -WarningAction SilentlyContinue

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty
            $cache | Should -HaveCount 2
            $cache | Should -Contain $TestDescriptor1
            $cache | Should -Contain $TestDescriptor2
        }

        It 'Should write warning when removing from empty cache' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value @()
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @() }

            # Act
            $warningVar = @()
            Remove-WorkItemRelationDescriptor `
                -Relation $TestDescriptor1.Relation `
                -WarningVariable warningVar `
                -WarningAction SilentlyContinue

            # Assert
            $warningVar | Should -Not -BeNullOrEmpty
            $warningVar[0] | Should -Match "No descriptor found with Relation.*"
        }
    }

    Context 'Cache Management' {

        It 'Should update the script-level cache variable' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1, $TestDescriptor2)

            # Act
            Remove-WorkItemRelationDescriptor -Relation $TestDescriptor1.Relation

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty
            $cache | Should -HaveCount 1
            $cache[0] | Should -Be $TestDescriptor2
        }

        It 'Should handle null cache gracefully' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value $null
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { $null }

            # Act
            $warningVar = @()
            Remove-WorkItemRelationDescriptor `
                -Relation $TestDescriptor1.Relation `
                -WarningVariable warningVar `
                -WarningAction SilentlyContinue

            # Assert
            $warningVar | Should -Not -BeNullOrEmpty
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }
    }

    Context 'Edge Cases' {

        It 'Should handle empty string relation parameter' {
            # Arrange
            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith { @($TestDescriptor1) }

            # Act & Assert
            { Remove-WorkItemRelationDescriptor -Relation '' } | Should -Throw
        }

        It 'Should handle descriptors with special characters in relation names' {
            # Arrange
            $specialCharDescriptor = New-WorkItemRelationDescriptor `
                -Relation 'System.LinkTypes.Special-Characters_&_Symbols!' `
                -FollowFrom @('Task') `
                -NameOnSource 'Source' `
                -NameOnTarget 'Target'

            Mock -ModuleName $ModuleName Get-WorkItemRelationDescriptorsList -MockWith {
                @($TestDescriptor1, $specialCharDescriptor)
            }

            # Act
            Remove-WorkItemRelationDescriptor -Relation $specialCharDescriptor.Relation

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty
            $cache | Should -HaveCount 1
            $cache[0] | Should -Be $TestDescriptor1
        }
    }
}
