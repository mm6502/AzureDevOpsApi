BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-CachedApiProjectsList' {

    Context 'When cache is empty or null' {

        It 'Should return nothing when cache is null' {

            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -MockWith {
                return $null
            }

            # Act
            $result = Get-CachedApiProjectsList

            # Assert
            $result | Should -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -Exactly 1
        }

        It 'Should return nothing when cache is empty hashtable' {

            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -MockWith {
                return @{}
            }

            # Act
            $result = Get-CachedApiProjectsList

            # Assert
            $result | Should -BeNullOrEmpty
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -Exactly 1
        }
    }

    Context 'When cache contains project data' {

        It 'Should return projects with correct properties' {

            # Arrange
            $mockCache = @{
                'project1' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectName   = 'TestProject1'
                    ProjectId     = '12345-67890-abcdef'
                    ProjectUri    = 'https://dev.azure.com/org1/_apis/projects/12345-67890-abcdef'
                }
                'project2' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectName   = 'TestProject2'
                    ProjectId     = '98765-43210-fedcba'
                    ProjectUri    = 'https://dev.azure.com/org1/_apis/projects/98765-43210-fedcba'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -MockWith {
                return $mockCache
            }

            # Act
            $result = Get-CachedApiProjectsList

            # Assert
            $result | Should -HaveCount 2
            $result[0].CollectionUri | Should -Be 'https://dev.azure.com/org1'
            $result[0].ProjectName | Should -Be 'TestProject1'
            $result[0].ProjectId | Should -Be '12345-67890-abcdef'
            $result[0].ProjectUri | Should -Be 'https://dev.azure.com/org1/_apis/projects/12345-67890-abcdef'

            $result[1].CollectionUri | Should -Be 'https://dev.azure.com/org1'
            $result[1].ProjectName | Should -Be 'TestProject2'
            $result[1].ProjectId | Should -Be '98765-43210-fedcba'
            $result[1].ProjectUri | Should -Be 'https://dev.azure.com/org1/_apis/projects/98765-43210-fedcba'
        }

        It 'Should filter out invalid entries without ProjectName or ProjectId' {

            # Arrange
            $mockCache = @{
                'validProject' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectName   = 'ValidProject'
                    ProjectId     = '12345-67890-abcdef'
                    ProjectUri    = 'https://dev.azure.com/org1/_apis/projects/12345-67890-abcdef'
                }
                'invalidProject1' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectId     = '98765-43210-fedcba'
                    # Missing ProjectName
                }
                'invalidProject2' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectName   = 'InvalidProject'
                    # Missing ProjectId
                }
                'invalidProject3' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    # Missing both ProjectName and ProjectId
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -MockWith {
                return $mockCache
            }

            # Act
            $result = Get-CachedApiProjectsList

            # Assert
            $result | Should -HaveCount 1
            $result[0].ProjectName | Should -Be 'ValidProject'
            $result[0].ProjectId | Should -Be '12345-67890-abcdef'
        }

        It 'Should remove duplicate projects based on ProjectId' {

            # Arrange
            $mockCache = @{
                'project1' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectName   = 'TestProject'
                    ProjectId     = '12345-67890-abcdef'
                    ProjectUri    = 'https://dev.azure.com/org1/_apis/projects/12345-67890-abcdef'
                }
                'project2' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectName   = 'TestProject'
                    ProjectId     = '12345-67890-abcdef'
                    ProjectUri    = 'https://dev.azure.com/org1/_apis/projects/12345-67890-abcdef'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -MockWith {
                return $mockCache
            }

            # Act
            $result = Get-CachedApiProjectsList

            # Assert
            $result | Should -HaveCount 1
            $result[0].ProjectId | Should -Be '12345-67890-abcdef'
            $result[0].ProjectName | Should -Be 'TestProject'
        }

        It 'Should return PSCustomObject with expected properties' {

            # Arrange
            $mockCache = @{
                'project1' = [PSCustomObject]@{
                    CollectionUri = 'https://dev.azure.com/org1'
                    ProjectName   = 'TestProject'
                    ProjectId     = '12345-67890-abcdef'
                    ProjectUri    = 'https://dev.azure.com/org1/_apis/projects/12345-67890-abcdef'
                    ExtraProperty = 'ShouldNotBeIncluded'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -MockWith {
                return $mockCache
            }

            # Act
            $result = Get-CachedApiProjectsList

            # Assert
            $result | Should -HaveCount 1
            $result[0] | Should -BeOfType [PSCustomObject]

            # Should have exactly these properties
            $result[0].PSObject.Properties.Name | Should -Contain 'CollectionUri'
            $result[0].PSObject.Properties.Name | Should -Contain 'ProjectName'
            $result[0].PSObject.Properties.Name | Should -Contain 'ProjectId'
            $result[0].PSObject.Properties.Name | Should -Contain 'ProjectUri'
            $result[0].PSObject.Properties.Name | Should -HaveCount 4
        }
    }
}