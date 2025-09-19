function Add-WorkItemToReleaseNotesData {

    <#
        .SYNOPSIS
            Adds the given work items to the release notes data.

        .PARAMETER ReleaseNotesData
            List of release notes data to which loaded data should be added.
            The data type is hashtable, where the key is [string] WorkItemId and the
            value is PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            (for info see function New-ReleaseNotesDataItem)

        .PARAMETER AsOf
            Reference date and time. Takes objects in the state they were in at this date and time.
            If not specified, the current date and time will be used.
            I.e. including all changes today, up to the moment the query is run.

        .PARAMETER WorkItem
            Work item to be added. May be specified as
            - WorkItem object
            - WorkItem Ref
            - WorkItem Url
            - WorkItem ID (if also $Project is specified)

        .PARAMETER Reason
            Reason for adding the work item to the release notes data.

        .PARAMETER Recursive
            If $true, it goes through the relationships between work items and adds new ones
            according to the RelationDescriptors.
            If $false, it will only add work items given by the WorkItemId parameter.
            The default value is $true.

        .PARAMETER RelationDescriptors
            List of descriptors of relationships between work items.
            Defacto configuration of how relationships are crawled when adding data to release notes.
            The default value is the return value of the Get-DefaultWorkItemRelationDescriptorsList function.

        .PARAMETER Filter
            Filter to be used on acquired work items. Included are only passing ones.

        .PARAMETER ActivityParentId
            ID of the parent activity.
    #>

    [OutputType([object[]])]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [hashtable] $ReleaseNotesData = @{},

        $AsOf,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('WorkItems', 'Items')]
        [AllowEmptyCollection()]
        $WorkItem,

        [string] $Reason,

        [bool] $Recursive = $true,

        $RelationDescriptors = @(Get-DefaultWorkItemRelationDescriptorsList),

        [scriptblock] $Filter,

        [int] $ActivityParentId
    )

    begin {
        # Correct input parameters
        $AsOf = Use-ToDateTime -Value $AsOf

        # Initialize queue and result collection
        $queue = [System.Collections.ArrayList]::new()
        $newData = [System.Collections.ArrayList]::new()

        # Initialize progress reporting
        $Activity = 'Adding work items to release notes data'
        $ActivityId = $ActivityParentId + 1
    }

    process {

        if (!$WorkItem) {
            return
        }

        # Ensure, we have a work item objects (as it may be an Uri or Id)
        $WorkItem = @(
            Get-WorkItem `
                -CollectionUri $CollectionUri `
                -Project $Project `
                -AsOf $AsOf `
                -WorkItem $WorkItem `
                -ActivityParentId $ActivityParentId
        )

        # Add the given workitems to the queue and release notes data
        foreach ($workItemObj in $WorkItem) {

            # Add the work item to the queue
            $item = Add-WorkItemToReleaseNotesDataAddToQueue `
                -Queue $queue `
                -ReleaseNotesData $ReleaseNotesData `
                -RelationDescriptors $RelationDescriptors `
                -TargetWorkItemUrl $workItemObj.url `
                -Reason $Reason

            # TODO: Clean Up
            # Given work item may have been already added to the release notes data
            if ($item) {
                $item.WorkItem = $workItemObj
            }
        }

        # Goes through the queue, downloads work items as needed
        # and evaluates the relationships between work items
        $counter = 0
        $total = $queue.Count

        while ($queue.Count -gt 0) {

            # Get the next item to process
            $item = $queue[0]
            $null = $queue.RemoveAt(0)
            $counter++

            # If the work item is not loaded, get it
            if (!$item.WorkItem) {
                $null = $item.ApiUrl -match 'workitems/(\d+)'
                $wid = $Matches[1]

                # Report progress
                Write-CustomProgress `
                    -Activity $Activity `
                    -Status "#$($wid)" `
                    -Count $total `
                    -Index $counter `
                    -Id $ActivityId `
                    -ParentId $ActivityParentId

                # Get the data
                $item.WorkItem = Get-WorkItem `
                    -CollectionUri $CollectionUri `
                    -Project $Project `
                    -AsOf $AsOf `
                    -WorkItem $item.ApiUrl `
                    -NoProgress

                # In rare cases, the object may not load;
                # e.g. when the AsOf parameter specifies the date and time before
                # the creation of the work item
                if (!$item.WorkItem) {
                    continue
                }
            }

            # If the filter is specified and the work item does not pass the filter; skip it
            if ($Filter) {
                $filterResult = ($item.WorkItem | Where-Object $Filter)
                if ($null -eq $filterResult) {
                    $item.Exclude = $true
                    continue
                }
            }

            # Adds to the new data and release notes data
            $newData += $item
            $ReleaseNotesData[$item.ApiUrl] = $item

            # If the relations are not to be traversed,
            # continue with the next item
            if ($Recursive -ne $true) {
                continue
            }

            # Goes through all the relationships of the loaded work item
            foreach ($relation in $item.WorkItem.relations) {

                $wasAdded = Add-WorkItemToReleaseNotesDataAddToQueue `
                    -Queue $Queue `
                    -ReleaseNotesData $ReleaseNotesData `
                    -RelationDescriptors $RelationDescriptors `
                    -ReleaseNotesDataItem $item `
                    -Relation $relation

                if ($wasAdded) {
                    $total++
                }
            }
        }
    }

    end {
        Write-Progress `
            -Activity $Activity `
            -Id $ActivityId `
            -ParentId $ActivityParentId `
            -Completed

        $newData | Write-Output
    }
}
