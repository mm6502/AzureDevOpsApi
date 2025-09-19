[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Add-WorkItemToReleaseNotesData' {
    BeforeAll {
        $mockWorkItem = [PSCustomObject]@{
            id     = 456
            url    = 'https://dev.azure.com/org/project/_apis/wit/workitems/456'
            fields = @{
                'System.WorkItemType' = 'Task'
                'System.Title'        = 'Test Task'
                'System.State'        = 'Done'
            }
            relations = @()
            _links = @{
                html = @{
                    href = 'https://dev.azure.com/org/project/_workitems/edit/456'
                }
            }
        }

        # Mock the required functions
        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
            $mockWorkItem
        } -ParameterFilter {
            ($WorkItem -eq $mockWorkItem) -or ($WorkItem -eq $mockWorkItem.url)
        }
    }

    It 'Should add a work item to release notes data' {
        $releaseNotesData = @{ }

        # Act
        $null = Add-WorkItemToReleaseNotesData `
            -WorkItem $mockWorkItem `
            -ReleaseNotesData $releaseNotesData

        # Assert
        $releaseNotesData.Count | Should -Be 1
        $result = $releaseNotesData[$releaseNotesData.Keys[0]]
        $result.WorkItemId | Should -Be $mockWorkItem.id
        $result.WorkItemType | Should -Be $mockWorkItem.fields.'System.WorkItemType'
        $result.Title | Should -Be $mockWorkItem.fields.'System.Title'
        $result.WorkItem.url | Should -Be $mockWorkItem.url
    }

    It 'Should not add duplicate work items' {
        # Arrange
        $releaseNotesData = @{
            $mockWorkItem.url = @{
                WorkItemId    = 123
                WorkItemType  = 'Bug'
                Title = 'Existing Bug'
                WorkItem = @{
                    url   = 'https://dev.azure.com/org/project/_workitems/edit/123'
                }
            }
        }

        # Act
        $result = Add-WorkItemToReleaseNotesData `
            -WorkItem $mockWorkItem `
            -ReleaseNotesData $releaseNotesData

        # Assert
        $result.Count | Should -Be 0
        $releaseNotesData.Count | Should -Be 1
    }

    It 'Should handle work items with relations' {
        # Arrange
        $parentWorkItem = [PSCustomObject] @{
            id        = 123
            url       = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
            fields    = @{
                'System.WorkItemType' = 'Bug'
                'System.Title'        = 'Test Bug'
                'System.State'        = 'Closed'
            }
            relations = @()
            _links    = @{
                html = @{
                    href = 'https://dev.azure.com/org/project/_workitems/edit/123'
                }
            }
        }

        # Add child item reference to parent
        $mockWorkItem.relations = @(
            @{
                rel  = 'System.LinkTypes.Hierarchy-Reverse'
                url  = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
            }
        )

        # Mock the required functions
        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
            $parentWorkItem
        } -ParameterFilter {
            ($WorkItem -eq $parentWorkItem) -or ($WorkItem -eq $parentWorkItem.url)
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -MockWith {
            $mockWorkItem
        } -ParameterFilter {
            ($WorkItem -eq $mockWorkItem) -or ($WorkItem -eq $mockWorkItem.url)
        }

        $releaseNotesData = @{ }

        # Act
        $null = Add-WorkItemToReleaseNotesData `
            -WorkItem $mockWorkItem `
            -ReleaseNotesData $releaseNotesData

        # Assert
        $releaseNotesData.Count | Should -Be 2
        $releaseNotesData.Keys | Should -Contain $mockWorkItem.url
        $releaseNotesData.Keys | Should -Contain $parentWorkItem.url
    }
}
