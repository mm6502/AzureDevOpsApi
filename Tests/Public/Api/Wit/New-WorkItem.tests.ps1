BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-WorkItem' {

    BeforeAll {
        $expected = @{
            CollectionUri = 'https://dev.azure.com/contoso'
            Project = 'MyProject'
            ApiCredential = [PSCustomObject]@{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.ApiCredential'
                Username = 'user@contoso.com'
                Token = 'pat'
            }
            WorkItemType = 'Bug'
            Connection = New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith { }
    }

    It 'Should create work item with bypass rules' {
        # Arrange
        $patchDocument = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument'
            WorkItemType = $expected.WorkItemType
            Operations = @(
                @{
                    op = "add"
                    path = "/fields/System.Title"
                    value = "Test Bug"
                }
            )
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            return [PSCustomObject]@{
                id = 123
                url = "https://dev.azure.com/contoso/MyProject/_apis/wit/workitems/123"
            }
        }

        # Act
        $result = New-WorkItem `
            -CollectionUri $expected.CollectionUri `
            -Project $expected.Project `
            -PatchDocument $patchDocument `
            -BypassRules

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*bypassRules=true*"
        }
        $result.id | Should -Be 123
    }

    It 'Should create work item with validate only' {
        # Arrange
        $patchDocument = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument'
            WorkItemType = $expected.WorkItemType
            WorkItemUrl = "https://dev.azure.com/contoso/MyProject/_apis/wit/workitems/456"
            Operations = @()
        }

        # Act
        $result = New-WorkItem `
            -CollectionUri $expected.CollectionUri `
            -Project $expected.Project `
            -PatchDocument $patchDocument `
            -ValidateOnly

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*validateOnly=true*"
        }
        $result.id | Should -Be 456
    }

    It 'Should create work item with suppress notifications' {
        # Arrange
        $patchDocument = [PSCustomObject]@{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument'
            WorkItemType = $expected.WorkItemType
            Operations = @()
        }

        # Act
        $null = New-WorkItem `
            -CollectionUri $expected.CollectionUri `
            -Project $expected.Project `
            -PatchDocument $patchDocument `
            -SuppressNotifications

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*suppressNotifications=true*"
        }
    }

    It 'Should use project from patch document when project parameter is null' {
        # Arrange
        $patchDocument = [PSCustomObject]@{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument'
            WorkItemType = $expected.WorkItemType
            WorkItemUrl = "https://dev.azure.com/contoso/DifferentProject/_apis/wit/workitems/789"
            Operations = @()
        }

        # Act
        $null = New-WorkItem `
            -CollectionUri $expected.CollectionUri `
            -PatchDocument $patchDocument

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project -eq $patchDocument.WorkItemUrl
        }
    }
}
