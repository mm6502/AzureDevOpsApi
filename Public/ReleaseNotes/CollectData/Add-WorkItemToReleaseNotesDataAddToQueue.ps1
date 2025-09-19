function Add-WorkItemToReleaseNotesDataAddToQueue {

    <#
        .SYNOPSIS
            Adds a new item to the download list as well as data for the Release Notes.

        .PARAMETER Queue
            List of data to download.

        .PARAMETER ReleaseNotesData
            List of release notes data to which loaded data should be added.
            The data type is hashtable, where the key is [string] WorkItemId and the
            value is PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            (for info see function New-ReleaseNotesDataItem)

        .PARAMETER SourceWorkItemUrl
            Url of the work item from which we start tracking the relationship.

        .PARAMETER TargetWorkItemUrl
            Url of the work item to which the tracked relationship points.

        .PARAMETER RelationDescriptors
            List of descriptors of relationships between work items.
            Defacto configuration of how relationships are crawled when adding data to release notes.
            The default value is the return value of the Get-DefaultWorkItemRelationDescriptorsList function.

        .PARAMETER Reason
            The reason for including the target work item in the data for Release Notes.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList] $Queue,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [HashTable] $ReleaseNotesData,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        $RelationDescriptors,

        [PSTypeName('PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem')]
        [Parameter(Mandatory, ParameterSetName = 'Relation')]
        $ReleaseNotesDataItem,

        [Parameter(Mandatory, ParameterSetName = 'Relation')]
        $Relation,

        [Parameter(Mandatory, ParameterSetName = 'Reason')]
        [string] $TargetWorkItemUrl,

        [Parameter(Mandatory, ParameterSetName = 'Reason')]
        $Reason
    )

    if ($PSCmdlet.ParameterSetName -eq 'Relation') {

        # Gets a prescription for how to deal with the current relationship
        $relationDescriptor = Select-WorkItemRelationDescriptor `
            -RelationDescriptors $RelationDescriptors `
            -WorkItem $ReleaseNotesDataItem.WorkItem `
            -Relation $Relation
        if (!$relationDescriptor) {
            return
        }

        # Extract work item id from its url
        if (-not $Relation.url) {
            return
        }
        $TargetWorkItemUrl = [string] $Relation.url
        $SourceWorkItemUrl = [string] $ReleaseNotesDataItem.ApiUrl
        if (!$Reason) {
            $Reason = $relationDescriptor.NameOnTarget
        }
    }

    # Adds relation on the source item
    $null = Add-ReleaseNotesDataItemRelation `
        -ReleaseNotesData $ReleaseNotesData `
        -SourceWorkItemUrl $SourceWorkItemUrl `
        -TargetWorkItemUrl $TargetWorkItemUrl `
        -RelationName $RelationDescriptor.NameOnSource

    # If the data for the release notes already contains the work item
    if ($ReleaseNotesData.Keys -contains $TargetWorkItemUrl) {
        $item = $ReleaseNotesData[$TargetWorkItemUrl]

        # Add reason to the list of reasons for the work item
        if ($item.ReasonsList -inotcontains $Reason) {
            $item.ReasonsList += $Reason
        }

        return
    }

    # Create a new ReleaseNotesDataItem object
    $item = New-ReleaseNotesDataItem
    $item.ApiUrl = $TargetWorkItemUrl

    # Add the first reason to the list of reasons for the work item
    if ($SourceWorkItemUrl) {
        $SourceReasonList = $ReleaseNotesData[$SourceWorkItemUrl].ReasonsList
        if ($SourceReasonList) {
            $item.ReasonsList += $SourceReasonList[0]
        }
    }
    $item.ReasonsList += $Reason

    # Add the work item to the list of work items to be downloaded
    $null = $queue.Add($item)
    # And to the release notes data
    $ReleaseNotesData[$item.ApiUrl] = $item

    # Add the reverse relation on the target item
    $null = Add-ReleaseNotesDataItemRelation `
        -ReleaseNotesData $ReleaseNotesData `
        -SourceWorkItemUrl $TargetWorkItemUrl `
        -TargetWorkItemUrl $SourceWorkItemUrl `
        -RelationName $RelationDescriptor.NameOnTarget

    # And return the new item
    return $item
}
