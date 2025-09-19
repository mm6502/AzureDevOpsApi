[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ExportDataWorkItemsProcessTestsRelations' {

    BeforeAll {

        $mockWorkItem1 = [PSCustomObject] @{
            id        = 1
            rev       = 1
            url       = 'https://dev.azure.com/org/proj/_apis/wit/workitems/1'
            fields    = [PSCustomObject] @{
                'System.WorkItemType' = 'Requirement'
                'System.State'        = 'Resolved'
            }
            relations = @(
                [PSCustomObject] @{
                    rel        = 'System.LinkTypes.Hierarchy-Forward'
                    url        = 'https://dev.azure.com/org/proj/_apis/wit/workitems/2'
                    attributes = [PSCustomObject] @{
                        name = 'Child'
                    }
                }
                [PSCustomObject] @{
                    rel        = 'Microsoft.VSTS.Common.TestedBy-Forward'
                    url        = 'https://dev.azure.com/org/proj/_apis/wit/workitems/3'
                    attributes = [PSCustomObject] @{
                        name = 'Tested By'
                    }
                }
            )
        }

        $mockWorkItem2 = [PSCustomObject] @{
            id        = 2
            rev       = 1
            url       = 'https://dev.azure.com/org/proj/_apis/wit/workitems/2'
            fields    = [PSCustomObject] @{
                'System.WorkItemType' = 'Task'
                'System.State'        = 'Closed'
            }
            relations = @(
                @{
                    rel        = 'System.LinkTypes.Hierarchy-Reverse'
                    url        = 'https://dev.azure.com/org/proj/_apis/wit/workitems/1'
                    attributes = [PSCustomObject] @{
                        name = 'Parent'
                    }
                }
            )
        }

        $mockWorkItem3 = [PSCustomObject] @{
            id        = 3
            rev       = 1
            url       = 'https://dev.azure.com/org/proj/_apis/wit/workitems/3'
            fields    = [PSCustomObject] @{
                'System.WorkItemType' = 'Test Case'
            }
            relations = @(
                [PSCustomObject] @{
                    rel        = 'Microsoft.VSTS.Common.TestedBy-Reverse'
                    url        = 'https://dev.azure.com/org/proj/_apis/wit/workitems/1'
                    attributes = [PSCustomObject] @{
                        name = 'Tests'
                    }
                }
            )
        }
    }

    It 'Should process work items correctly' {

        $ProgressPreference = 'SilentlyContinue'

        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -ParameterFilter {
            ($WorkItem -eq $mockWorkItem1.url)
        } -MockWith {
            $mockWorkItem1
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -ParameterFilter {
            ($WorkItem -eq $mockWorkItem2.url)
        } -MockWith {
            $mockWorkItem2
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItem -ParameterFilter {
            ($WorkItem -eq $mockWorkItem3.url)
        } -MockWith {
            $mockWorkItem3
        }

        $releaseNotesDataItems = @{ }

        $null = Add-WorkItemToReleaseNotesData `
            -Reason 'Test-Run' `
            -ReleaseNotesData $releaseNotesDataItems `
            -WorkItem $mockWorkItem2.url `
            -CollectionUri 'https://dev.azure.com/org/proj'

        $item = $releaseNotesDataItems.Values | Where-Object { $_.WorkItemId -eq 3 }

        # Act
        $result = ConvertTo-ExportDataWorkItemsProcessTestsRelations `
            -Item $item `
            -Items $releaseNotesDataItems

        # Assert
        $result | Should -Be "Resolved"
    }
}
