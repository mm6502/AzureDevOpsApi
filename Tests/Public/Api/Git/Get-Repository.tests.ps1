BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-Repository' {
    BeforeAll {
        $expected = [PSCustomObject] @{
            CollectionUri     = 'https://dev.azure.com/myorg'
            Project           = 'TestProject'
            ApiCredential     = New-ApiCredential -Token 'token' -Authorization 'PAT'
            ProjectConnection = $null
            Repository        = [PSCustomObject] @{
                id            = 'repo-id'
                name          = 'repo-name'
                project       = @{
                    id = 'project-id'
                }
                defaultBranch = 'main'
                url           = 'https://dev.azure.com/myorg/TestProject/_apis/git/repositories/repo-id'
                webUrl        = 'https://dev.azure.com/myorg/TestProject/_git/repo-id'
            }
        }

        $expected.ProjectConnection = [PSCustomObject] @{
            PSTypeName     = 'PSTypeNames.AzureDevOpsApi.ApiProjectConnection'
            ProjectBaseUri = 'https://dev.azure.com/myorg/TestProject'
            ApiVersion     = '6.0'
            ApiCredential  = $expected.ApiCredential
        }
    }

    Context 'When repository object is already complete' {
        It 'Should return the repository object without making API calls' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith { }

            # Act
            $result = Get-Repository -Repository $expected.Repository

            # Assert
            $result | Should -Be $expected.Repository
            Should -Not -Invoke -ModuleName $ModuleName -CommandName Invoke-Api
        }
    }

    Context 'When repository is specified by URL' {
        It 'Should fetch repository using an API URL' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
                return $expected.ProjectConnection
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
                return $expected.Repository
            }

            # Act
            $result = Get-Repository -Repository $expected.Repository.url

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $expected.Repository.id
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
                $Uri -eq $expected.Repository.url
            }
        }

        It 'Should fetch repository using a WEB URL' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
                return $expected.ProjectConnection
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
                return $expected.Repository
            }

            # Act
            $result = Get-Repository -Repository $expected.Repository.webUrl

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $expected.Repository.id
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
                $Uri -eq $expected.Repository.url
            }
        }
    }

    Context 'When repository is specified by name with collection URI and project' {
        It 'Should fetch repository using constructed URL' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
                return $expected.ProjectConnection
            }
            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
                return $expected.Repository
            }

            # Act
            $result = Get-Repository `
                -CollectionUri $expected.ProjectConnection.CollectionUri `
                -Project $expected.Project `
                -Repository $expected.Repository.name

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $expected.Repository.id
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
                $Uri -like "*/_apis/git/repositories/repo-name*"
            }
        }
    }

    Context 'When repository is not found' {
        It 'Should return null when API returns no results' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
                return $expected.ProjectConnection
            }
            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
                return $null
            }

            # Act
            $result = Get-Repository `
                -CollectionUri $expected.CollectionUri `
                -Project $expected.Project `
                -Repository 'non-existent-repo'

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'When repository parameter is null' {
        It 'Should return null without making API calls' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith { }

            # Act
            $result = Get-Repository -Repository $null

            # Assert
            $result | Should -BeNullOrEmpty
            Should -Not -Invoke -ModuleName $ModuleName -CommandName Invoke-Api
        }
    }
}
