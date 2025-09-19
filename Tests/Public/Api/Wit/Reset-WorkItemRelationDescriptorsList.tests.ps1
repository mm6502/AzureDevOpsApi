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

Describe 'Reset-WorkItemRelationDescriptorsList' {

    BeforeEach {
        # Reset the cache before each test and set it to a known state
        $script:TestDescriptor1 = New-WorkItemRelationDescriptor `
            -Relation 'System.LinkTypes.Hierarchy-Forward' `
            -FollowFrom @('Task', 'Bug') `
            -NameOnSource 'Parent' `
            -NameOnTarget 'Child'

        Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1)

        # Mock the config file path that the function will use
        $script:MockConfigPath = 'TestDrive:\Config\WorkItemRelationDescriptors.json'

        # Create the config directory structure for testing
        $configDir = Split-Path -Path $MockConfigPath
        if (-not (Test-Path -Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }
    }

    Context 'Cache Clearing' {

        It 'Should clear the cache when called without parameters' {
            # Arrange
            # Verify cache has content initially
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty

            # Act
            Reset-WorkItemRelationDescriptorsList

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }

        It 'Should clear the cache when called with -Default switch' {
            # Arrange
            # Verify cache has content initially
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty

            # Act
            Reset-WorkItemRelationDescriptorsList -Default

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }

        It 'Should clear the cache when called with -Permanent alias' {
            # Arrange
            # Verify cache has content initially
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty

            # Act
            Reset-WorkItemRelationDescriptorsList -Permanent

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }

        It 'Should clear the cache when called with -Persistent alias' {
            # Arrange
            # Verify cache has content initially
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -Not -BeNullOrEmpty

            # Act
            Reset-WorkItemRelationDescriptorsList -Persistent

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }
    }

    Context 'File Operations Without -Default Switch' {

        It 'Should not remove config file when called without -Default' {
            # Arrange
            # Create a test config file
            Set-Content -Path $MockConfigPath -Value '[]'
            Test-Path -Path $MockConfigPath | Should -Be $true

            # Mock the path resolution to use our test path
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }

            # Act
            Reset-WorkItemRelationDescriptorsList

            # Assert
            # File should still exist
            Test-Path -Path $MockConfigPath | Should -Be $true
        }
    }

    Context 'File Operations With -Default Switch' {

        It 'Should remove config file when -Default is specified and file exists' {
            # Arrange
            # Create a test config file
            Set-Content -Path $MockConfigPath -Value '[]'
            Test-Path -Path $MockConfigPath | Should -Be $true

            # Mock the path resolution to use our test path
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }

            # Act
            Reset-WorkItemRelationDescriptorsList -Default

            # Assert
            # File should be removed (mocked Remove-Item will be called)
            Test-Path -Path $MockConfigPath | Should -Be $false
        }

        It 'Should handle non-existent config file gracefully with -Default' {
            # Arrange
            # Ensure no config file exists
            if (Test-Path -Path $MockConfigPath) {
                Remove-Item -Path $MockConfigPath -Force
            }

            # Mock the path resolution
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }

            # Act & Assert
            { Reset-WorkItemRelationDescriptorsList -Default } | Should -Not -Throw
        }

        It 'Should use ErrorAction SilentlyContinue when removing file' {
            # Arrange
            # Mock the path resolution
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }
            Mock -ModuleName $ModuleName -CommandName Remove-Item -MockWith { }

            # Act
            Reset-WorkItemRelationDescriptorsList -Default

            # Assert
            Should -Invoke -ModuleName $ModuleName Remove-Item -ParameterFilter {
                $ErrorAction -eq 'SilentlyContinue'
            } -Exactly 1
        }
    }

    Context 'Switch Parameter Behavior' {

        It 'Should handle -Default:$false correctly' {
            # Arrange
            # Create a test config file
            Set-Content -Path $MockConfigPath -Value '[]'

            # Mock the path resolution
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }
            Mock -ModuleName $ModuleName -CommandName Remove-Item -MockWith { }

            # Act
            Reset-WorkItemRelationDescriptorsList -Default:$false

            # Assert
            # Remove-Item should not be called when -Default:$false
            Should -Invoke -ModuleName $ModuleName Remove-Item -Exactly 0
        }

        It 'Should handle -Default:$true correctly' {
            # Arrange
            # Mock the path resolution
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }
            Mock -ModuleName $ModuleName -CommandName Remove-Item -MockWith { }

            # Act
            Reset-WorkItemRelationDescriptorsList -Default:$true

            # Assert
            Should -Invoke -ModuleName $ModuleName Remove-Item -Exactly 1
        }
    }

    Context 'Edge Cases' {

        It 'Should handle multiple consecutive calls' {
            # Arrange
            # Start with a non-empty cache
            Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1)

            # Mock to prevent actual file operations
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }
            Mock -ModuleName $ModuleName -CommandName Remove-Item -MockWith { }

            # Act - Call multiple times
            Reset-WorkItemRelationDescriptorsList
            Reset-WorkItemRelationDescriptorsList
            Reset-WorkItemRelationDescriptorsList -Default

            # Assert
            # Cache should remain null after multiple calls
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }

        It 'Should not throw when cache is already null' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value $null

            # Act
            { Reset-WorkItemRelationDescriptorsList } | Should -Not -Throw

            # Assert
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }

        It 'Should handle file system errors gracefully' {
            # Arrange
            # Mock Join-Path to return a path that will cause Remove-Item to fail
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { 'C:\InvalidPath\That\Does\Not\Exist\file.json' }

            # Act
            # This should not throw because Remove-Item uses -ErrorAction SilentlyContinue
            { Reset-WorkItemRelationDescriptorsList -Default } | Should -Not -Throw

            # Assert
            # Cache should still be cleared
            $cache = Get-WorkItemRelationDescriptorsCache
            $cache | Should -BeNullOrEmpty
        }
    }

    Context 'Parameter Aliases' {

        It 'Should accept Permanent as alias for Default' {
            # Assert
            { Reset-WorkItemRelationDescriptorsList -Permanent } | Should -Not -Throw
        }

        It 'Should accept Persistent as alias for Default' {
            # Assert
            { Reset-WorkItemRelationDescriptorsList -Persistent } | Should -Not -Throw
        }

        It 'Should treat aliases the same as Default parameter' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }
            Mock -ModuleName $ModuleName -CommandName Remove-Item -MockWith { }

            # Act
            Reset-WorkItemRelationDescriptorsList -Permanent
            # Assert
            Should -Invoke -ModuleName $ModuleName Remove-Item -Exactly 1

            # Act
            Reset-WorkItemRelationDescriptorsList -Persistent
            # Assert
            Should -Invoke -ModuleName $ModuleName Remove-Item -Exactly 2
        }
    }
}
