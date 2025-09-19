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

Describe 'Save-WorkItemRelationDescriptorsList' {

    BeforeEach {
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

        # Set up cache with test data
        Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1, $TestDescriptor2)

        # Mock the config file path
        $script:MockConfigPath = 'TestDrive:\Config\WorkItemRelationDescriptors.json'
        $script:MockConfigDir = Split-Path -Path $MockConfigPath

        # Mock the path resolution
        Mock -ModuleName $ModuleName -CommandName Join-Path -MockWith { $MockConfigPath }
    }

    Context 'Parameter Handling' {

        It 'Should save current cache when no Descriptors parameter provided' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '["mocked json"]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList

            # Assert
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -ParameterFilter {
                $Value.Count -eq 2 -and
                $Value[0].Relation -eq $TestDescriptor1.Relation -and
                $Value[1].Relation -eq $TestDescriptor2.Relation
            } -Exactly 1
        }

        It 'Should save provided descriptors when Descriptors parameter is specified' {
            # Arrange
            $customDescriptors = @($TestDescriptor1)

            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '["mocked json"]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors $customDescriptors

            # Assert
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -ParameterFilter {
                $Value.Count -eq 1 -and
                $Value[0].Relation -eq $TestDescriptor1.Relation
            } -Exactly 1
        }

        It 'Should handle empty array of descriptors' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '[]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors @()

            # Assert
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -ParameterFilter {
                $Value.Count -eq 0
            } -Exactly 1
        }
    }

    Context 'Null Parameter Handling' {

        It 'Should delete config file when Descriptors is null and file exists' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName Remove-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors $null

            # Assert
            Should -Invoke -ModuleName $ModuleName Remove-Item -ParameterFilter {
                $Path -eq $MockConfigPath -and $Force -eq $true
            } -Exactly 1
        }

        It 'Should not attempt to delete when Descriptors is null and file does not exist' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }
            Mock -ModuleName $ModuleName -CommandName Remove-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors $null

            # Assert
            Should -Invoke -ModuleName $ModuleName Remove-Item -Exactly 0
        }

        It 'Should return early when Descriptors is null' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { 'should not be called' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors $null

            # Assert
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -Exactly 0
            Should -Invoke -ModuleName $ModuleName Set-Content -Exactly 0
        }
    }

    Context 'File Operations' {

        It 'Should create directory if it does not exist' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '[]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }  # Directory doesn't exist
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Split-Path -MockWith { $MockConfigDir }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors @()

            # Assert
            Should -Invoke -ModuleName $ModuleName New-Item -ParameterFilter {
                $Path -eq $MockConfigDir -and
                $ItemType -eq 'Directory' -and
                $Force -eq $true
            } -Exactly 1
        }

        It 'Should not create directory if it already exists' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '[]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }  # Directory exists
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Split-Path -MockWith { $MockConfigDir }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors @()

            # Assert
            Should -Invoke -ModuleName $ModuleName New-Item -Exactly 0
        }

        It 'Should save JSON content to the correct file path' {
            # Arrange
            $mockJsonContent = '{"test": "content"}'
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { $mockJsonContent }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors @($TestDescriptor1)

            # Assert
            Should -Invoke -ModuleName $ModuleName Set-Content -ParameterFilter {
                $Path -eq $MockConfigPath -and $Value -eq $mockJsonContent
            } -Exactly 1
        }
    }

    Context 'JSON Conversion' {

        It 'Should call ConvertTo-JsonCustom with correct depth' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '[]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors @($TestDescriptor1)

            # Assert
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -ParameterFilter {
                $Depth -eq 5
            } -Exactly 1
        }

        It 'Should pass descriptors to ConvertTo-JsonCustom as Value parameter' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '[]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors @($TestDescriptor1, $TestDescriptor2)

            # Assert
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -ParameterFilter {
                $Value.Count -eq 2 -and
                $Value[0].Relation -eq $TestDescriptor1.Relation -and
                $Value[1].Relation -eq $TestDescriptor2.Relation
            } -Exactly 1
        }
    }

    Context 'Cache vs Parameter Precedence' {

        It 'Should use provided descriptors over cache when parameter is explicitly provided' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor2)

            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '[]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList -Descriptors @($TestDescriptor1)

            # Assert
            # Should use the provided descriptor, not the cache
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -ParameterFilter {
                $Value.Count -eq 1 -and
                $Value[0].Relation -eq $TestDescriptor1.Relation
            } -Exactly 1
        }

        It 'Should use cache when no parameter is provided' {
            # Arrange
            Set-WorkItemRelationDescriptorsCache -Value @($TestDescriptor1)

            Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith { '[]' }
            Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-Item -MockWith { }

            # Act
            Save-WorkItemRelationDescriptorsList  # No -Descriptors parameter

            # Assert
            Should -Invoke -ModuleName $ModuleName ConvertTo-JsonCustom -ParameterFilter {
                $Value.Count -eq 1 -and
                $Value[0].Relation -eq $TestDescriptor1.Relation
            } -Exactly 1
        }
    }
}
