function ConvertTo-ExportDataWorkItems {

    <#
        .SYNOPSIS
            Converts set of ReleaseNotesDataItems to ExportData - WorkItems subset.

        .PARAMETER WorkItems
            List of ReleaseNotesDataItems.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
    [OutputType('PSTypeNames.AzureDevOpsApi.ExportDataWorkItem')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable] $Items
    )

    begin {
        $result = [System.Collections.Generic.List[PSObject]]::new()
    }

    process {

        foreach ($item in $Items.Values) {

            # update attribute "TestedWorkItemState" if needed
            $testedWorkItemStates = $item | ConvertTo-ExportDataWorkItemsProcessTestsRelations -Items $Items

            $wif = $item.WorkItem.fields

            $resultItem = [PSCustomObject] @{
                PSTypeName            = 'PSTypeNames.AzureDevOpsApi.ExportDataWorkItem'
                WorkItemId            = $item.WorkItemId
                ApiUrl                = $item.ApiUrl
                PortalUrl             = $item.PortalUrl
                InclusionReason       = $item.ReasonsList[0]
                TestedWorkItemStates  = $testedWorkItemStates
                WorkItemType          = $item.WorkItemType
                Title                 = $wif.'System.Title'
                State                 = $wif.'System.State'
                Reason                = $wif.'System.Reason'
                AreaPath              = $wif.'System.AreaPath'
                IterationPath         = $wif.'System.IterationPath'
                AssignedToDisplayName = $wif.'System.AssignedTo'.displayName
                AssignedToUniqueName  = $wif.'System.AssignedTo'.uniqueName
                Discipline            = $wif.'Microsoft.VSTS.Common.Discipline'
                ResolvedDate          = $wif.'Microsoft.VSTS.Common.ResolvedDate'
                ResolvedByDisplayName = $wif.'Microsoft.VSTS.Common.ResolvedBy'.displayName
                ResolvedByUniqueName  = $wif.'Microsoft.VSTS.Common.ResolvedBy'.uniqueName
                ResolvedReason        = $wif.'Microsoft.VSTS.Common.ResolvedReason'
                ClosedDate            = $wif.'Microsoft.VSTS.Common.ClosedDate'
                ClosedByDisplayName   = $wif.'Microsoft.VSTS.Common.ClosedBy'.displayName
                ClosedByUniqueName    = $wif.'Microsoft.VSTS.Common.ClosedBy'.uniqueName
                RequiresTest          = $wif.'Microsoft.VSTS.Common.RequiresTest'
                CompletedWork         = $wif.'Microsoft.VSTS.Scheduling.CompletedWork'
                RemainingWork         = $wif.'Microsoft.VSTS.Scheduling.RemainingWork'
                OriginalEstimate      = $wif.'Microsoft.VSTS.Scheduling.OriginalEstimate'
                TargetDate            = $wif.'Microsoft.VSTS.Scheduling.TargetDate'
                Tags                  = $wif.'System.Tags'
                Parent                = $null
                ParentApiUrl          = $null
                ParentPortalUrl       = $null
            }

            # add parent info if needed
            $resultItem.Parent = $wif.'System.Parent'
            if ($resultItem.Parent) {
                $apiUrl = ConvertTo-ParentUrl -ChildUrl $item.ApiUrl -ParentId $resultItem.Parent
                $portalUrl = ConvertTo-ParentUrl -ChildUrl $item.PortalUrl -ParentId $resultItem.Parent
                $resultItem.ParentApiUrl = $apiUrl
                $resultItem.ParentPortalUrl = $portalUrl
            }

            $result.Add($resultItem)
        }
    }

    end {
        $result
    }
}
