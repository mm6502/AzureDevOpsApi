[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Sync-ApiCredentialForProject' {

    BeforeAll {
        $mockCollectionUri = 'https://dev.azure.com/myorg'
        $mockProject = [PSCustomObject]@{
            id   = 'project-id'
            name = 'project-name'
        }
        $mockApiCredential = New-ApiCredential -Token 'token' -Authorization 'PAT'
    }

    Context 'When ApiCredential is not found for Project Name or ID' {

        Mock -ModuleName $ModuleName -CommandName Find-ApiCredential -MockWith { $null }

        It 'Should return the Project object without updating ApiCredential' {
            # Act
            $result = $mockProject | Sync-ApiCredentialForProject -CollectionUri $mockCollectionUri
            # Assert
            $result | Should -Be $mockProject
        }
    }

    Context 'When ApiCredential is found for Project Name and ID' {

        Mock -ModuleName $ModuleName -CommandName Find-ApiCredential -MockWith { $mockApiCredential }

        It 'Should not update ApiCredential and return the Project object' {
            # Act
            $result = $mockProject | Sync-ApiCredentialForProject -CollectionUri $mockCollectionUri
            # Assert
            $result | Should -Be $mockProject
        }
    }

    Context 'When ApiCredential is found for Project Name but not ID' {

        It 'Should update ApiCredential for Project ID and return the Project object' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Find-ApiCredential `
                -ParameterFilter { $Project -eq $mockProject.name } `
                -MockWith { $mockApiCredential }
            Mock -ModuleName $ModuleName -CommandName Find-ApiCredential `
                -ParameterFilter { $Project -eq $mockProject.id } `
                -MockWith { $null }
            Mock -ModuleName $ModuleName -CommandName Add-ApiCredential -Verifiable

            # Act
            $result = $mockProject | Sync-ApiCredentialForProject -CollectionUri $mockCollectionUri

            # Assert
            $result | Should -Be $mockProject
            Should -Invoke -ModuleName $ModuleName -CommandName Add-ApiCredential -ParameterFilter {
                $CollectionUri -eq $mockCollectionUri -and
                $Project -eq $mockProject.id -and
                $ApiCredential -eq $mockApiCredential
            }
        }
    }

    Context 'When ApiCredential is found for Project ID but not Name' {

        It 'Should update ApiCredential for Project Name and return the Project object' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Find-ApiCredential `
                -ParameterFilter { $Project -eq $mockProject.name } `
                -MockWith { $null }
            Mock -ModuleName $ModuleName -CommandName Find-ApiCredential `
                -ParameterFilter { $Project -eq $mockProject.id } `
                -MockWith { $mockApiCredential }
            Mock -ModuleName $ModuleName -CommandName Add-ApiCredential -Verifiable

            # Act
            $result = $mockProject | Sync-ApiCredentialForProject -CollectionUri $mockCollectionUri

            # Assert
            $result | Should -Be $mockProject
            Should -Invoke -ModuleName $ModuleName -CommandName Add-ApiCredential -ParameterFilter {
                $CollectionUri -eq $mockCollectionUri -and
                $Project -eq $mockProject.name -and
                $ApiCredential -eq $mockApiCredential
            }
        }
    }
}
