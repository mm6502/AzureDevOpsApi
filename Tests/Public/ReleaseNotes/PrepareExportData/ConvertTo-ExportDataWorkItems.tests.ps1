[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ExportDataWorkItems' {
    BeforeAll {

        $mockWorkItem1Url = 'https://dev.azure.com/org/project/_apis/wit/workitems/1'
        $mockWorkItem2Url = 'https://dev.azure.com/org/project/_apis/wit/workitems/2'

        $mockWorkItem1 = [PSCustomObject] @{
            PSTypeName   = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            WorkItemId   = 1
            ApiUrl       = $mockWorkItem1Url
            PortalUrl    = 'https://dev.azure.com/org/project/_workitems/edit/1'
            ReasonsList  = @('Included')
            WorkItemType = 'Bug'
            WorkItem     = [PSCustomObject] @{
                fields = [PSCustomObject] @{
                    'System.Title'                               = 'Test Bug'
                    'System.State'                               = 'Active'
                    'System.Reason'                              = 'New'
                    'System.AreaPath'                            = 'Project\Area'
                    'System.IterationPath'                       = 'Project\Iteration'
                    'System.AssignedTo'                          = [PSCustomObject] @{
                        displayName = 'John Doe'
                        uniqueName  = 'john.doe@example.com'
                    }
                    'Microsoft.VSTS.Common.Discipline'           = 'Development'
                    'Microsoft.VSTS.Common.ResolvedDate'         = '2023-05-01'
                    'Microsoft.VSTS.Common.ResolvedBy'           = [PSCustomObject] @{
                        displayName = 'Jane Smith'
                        uniqueName  = 'jane.smith@example.com'
                    }
                    'Microsoft.VSTS.Common.ResolvedReason'       = 'Fixed'
                    'Microsoft.VSTS.Common.ClosedDate'           = '2023-05-02'
                    'Microsoft.VSTS.Common.ClosedBy'             = [PSCustomObject] @{
                        displayName = 'Bob Johnson'
                        uniqueName  = 'bob.johnson@example.com'
                    }
                    'Microsoft.VSTS.Common.RequiresTest'         = $true
                    'Microsoft.VSTS.Scheduling.CompletedWork'    = 8
                    'Microsoft.VSTS.Scheduling.RemainingWork'    = 0
                    'Microsoft.VSTS.Scheduling.OriginalEstimate' = 10
                    'Microsoft.VSTS.Scheduling.TargetDate'       = '2023-05-15'
                    'System.Tags'                                = 'Tag1; Tag2'
                    'System.Parent'                              = 2
                }
            }
        }

        $mockWorkItem2 = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            ApiUrl     = $mockWorkItem2Url
            PortalUrl  = 'https://dev.azure.com/org/project/_workitems/edit/2'
            ReasonsList = @('Commit')
        }

        $mockItems = @{
            $mockWorkItem1Url = $mockWorkItem1
            $mockWorkItem2Url = $mockWorkItem2
        }

        Mock `
            -ModuleName $ModuleName `
            -CommandName ConvertTo-ExportDataWorkItemsProcessTestsRelations `
            -MockWith { @('Passed', 'Failed') }
    }

    It 'Should convert work items to export data format' {
        # Act
        $result = @(ConvertTo-ExportDataWorkItems -Items $mockItems)

        # Assert
        $result | Should -HaveCount 2
        $item = $result | Where-Object -Property WorkItemId -EQ $mockWorkItem1.WorkItemId | Select-Object -First 1
        $mwf = $mockWorkItem1.WorkItem.fields
        $item.PSObject.TypeNames | Should -Contain 'PSTypeNames.AzureDevOpsApi.ExportDataWorkItem'
        $item.WorkItemId | Should -Be $mockWorkItem1.WorkItemId
        $item.ApiUrl | Should -Be $mockWorkItem1.ApiUrl
        $item.PortalUrl | Should -Be $mockWorkItem1.PortalUrl
        $item.InclusionReason | Should -Be $mockWorkItem1.ReasonsList[0]
        $item.TestedWorkItemStates | Should -Be @('Passed', 'Failed')
        $item.WorkItemType | Should -Be $mockWorkItem1.WorkItemType
        $item.Title | Should -Be $mwf.'System.Title'
        $item.State | Should -Be $mwf.'System.State'
        $item.Reason | Should -Be $mwf.'System.Reason'
        $item.AreaPath | Should -Be $mwf.'System.AreaPath'
        $item.IterationPath | Should -Be $mwf.'System.IterationPath'
        $item.AssignedToDisplayName | Should -Be $mwf.'System.AssignedTo'.displayName
        $item.AssignedToUniqueName | Should -Be $mwf.'System.AssignedTo'.uniqueName
        $item.Discipline | Should -Be $mwf.'Microsoft.VSTS.Common.Discipline'
        $item.ResolvedDate | Should -Be $mwf.'Microsoft.VSTS.Common.ResolvedDate'
        $item.ResolvedByDisplayName | Should -Be $mwf.'Microsoft.VSTS.Common.ResolvedBy'.displayName
        $item.ResolvedByUniqueName | Should -Be $mwf.'Microsoft.VSTS.Common.ResolvedBy'.uniqueName
        $item.ResolvedReason | Should -Be $mwf.'Microsoft.VSTS.Common.ResolvedReason'
        $item.ClosedDate | Should -Be $mwf.'Microsoft.VSTS.Common.ClosedDate'
        $item.ClosedByDisplayName | Should -Be $mwf.'Microsoft.VSTS.Common.ClosedBy'.displayName
        $item.ClosedByUniqueName | Should -Be $mwf.'Microsoft.VSTS.Common.ClosedBy'.uniqueName
        $item.RequiresTest | Should -Be $mwf.'Microsoft.VSTS.Common.RequiresTest'
        $item.CompletedWork | Should -Be $mwf.'Microsoft.VSTS.Scheduling.CompletedWork'
        $item.RemainingWork | Should -Be $mwf.'Microsoft.VSTS.Scheduling.RemainingWork'
        $item.OriginalEstimate | Should -Be $mwf.'Microsoft.VSTS.Scheduling.OriginalEstimate'
        $item.TargetDate | Should -Be $mwf.'Microsoft.VSTS.Scheduling.TargetDate'
        $item.Tags | Should -Be $mwf.'System.Tags'
        $item.Parent | Should -Be $mwf.'System.Parent'
        $item.ParentApiUrl | Should -Be $mockWorkItem2.ApiUrl
        $item.ParentPortalUrl | Should -Be $mockWorkItem2.PortalUrl
    }

    It 'Should handle empty input' {
        $result = ConvertTo-ExportDataWorkItems -Items @{}
        $result | Should -BeNullOrEmpty
    }
}
