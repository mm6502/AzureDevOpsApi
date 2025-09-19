function ConvertTo-ExportDataRelations {

    <#
        .SYNOPSIS
            Converts set of ReleaseNotesDataItems to ExportData - Relations subset.

        .PARAMETER WorkItems
            List of ReleaseNotesDataItems.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
    [OutputType('PSTypeNames.AzureDevOpsApi.ExportDataRelationItem')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Parameter', Position = 1)]
        [hashtable] $Items
    )

    begin {
        $result = [System.Collections.Generic.List[PSObject]]::new()
    }

    process {

        foreach ($item in $Items.Values) {
            foreach ($relation in $item.RelationsList) {
                foreach ($relatedWorkItemUrl in $relation.Relations) {
                    $relatedWorkItem = $Items[$relatedWorkItemUrl]

                    $result += [PSCustomObject] @{
                        PSTypeName       = 'PSTypeNames.AzureDevOpsApi.ExportDataRelationItem'
                        'A.WorkItemId'   = $item.WorkItemId
                        'A.WorkItemType' = $item.WorkItemType
                        'A.RelationName' = $relation.Name
                        'A.ApiUrl'       = $item.ApiUrl
                        'A.PortalUrl'    = $item.PortalUrl
                        'B.WorkItemId'   = $relatedWorkItem.WorkItemId
                        'B.WorkItemType' = $relatedWorkItem.WorkItemType
                        'B.ApiUrl'       = $relatedWorkItem.ApiUrl
                        'B.PortalUrl'    = $relatedWorkItem.PortalUrl
                    }
                }
            }
        }
    }

    end {
        $result
    }
}
