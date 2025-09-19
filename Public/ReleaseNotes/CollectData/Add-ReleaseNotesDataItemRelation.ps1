function Add-ReleaseNotesDataItemRelation {

    <#
        .SYNOPSIS
            Add a link between two given Work Items.

        .PARAMETER ReleaseNotesData
            Data for release notes.
            The data type is hashtable, where the key is [string] WorkItemId and the
            value is PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            (for info see function New-ReleaseNotesDataItem)

        .PARAMETER SourceWorkItemUrl
            Url of the work item from which the link originates.

        .PARAMETER TargetWorkItemUrl
            Url of the work item the link targets.

        .PARAMETER RelationName
            The name of the link. (e.g. Parent)
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItemRelation')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable] $ReleaseNotesData,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $SourceWorkItemUrl,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $TargetWorkItemUrl,

        $RelationName
    )

    process {

        # Check if all parameters are given
        if (!$SourceWorkItemUrl -or !$TargetWorkItemUrl -or !$RelationName) {
            return
        }

        # If the item does not exist yet, return
        $item = $ReleaseNotesData[$SourceWorkItemUrl]
        if (!$item) {
            return
        }

        # Find a relation with the given name
        $relationsListItem = $item.RelationsList `
        | Where-Object { $_.Name -ilike $RelationName } `
        | Select-Object -First 1

        # If this item does not exist yet, create and add it
        if (!$relationsListItem) {
            $relationsListItem = New-ReleaseNotesDataItemRelation -RelationName $RelationName
            $item.RelationsList += $relationsListItem
        }

        # Add another link target
        $relationsListItem.Relations.Add($TargetWorkItemUrl)

        # Return the changed record
        $relationsListItem
    }
}
