function New-PatchDocument {

    <#
        .SYNOPSIS
            Creates a JSON Patch document.

        .DESCRIPTION
            Creates a JSON Patch document.
            The document can be used with New-WorkItem to create and Update-WorkItem to update a work item.

        .PARAMETER SourceWorkItem
            Source work item to update.

        .PARAMETER WorkItemType
            Type of work item to create.
            If specified, overrides the value set by $Properties and $Data.
            Default is 'Task'.

        .PARAMETER Properties
            Properties to copy to update document.
            Default is empty array.

        .PARAMETER Data
            Additional data to add to the patch document.

        .PARAMETER CopyTags
            Flag, whether to copy tags from the source work item.

        .PARAMETER TagsToAdd
            Tags to add to the work item.

        .PARAMETER TagsToRemove
            Tags to remove from the work item.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/create?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Does not change state, generates a new object.'
    )]
    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument')]
    param(
        [Alias('Source')]
        $SourceWorkItem,
        $WorkItemType = 'Task',

        [string[]] $Properties = @(),
        [hashtable] $Data = @{},

        [switch] $CopyTags,
        [string[]] $TagsToAdd = @(),
        [string[]] $TagsToRemove = @()
    )

    begin {
        # Set default properties to be copied, if not specified
        if (-not $PSBoundParameters.ContainsKey('Properties')) {
            $Properties = @()
        }
        if ($Properties -notcontains 'System.WorkItemType') {
            $Properties += 'System.WorkItemType'
        }

        # Determine whether tags should be processed;
        # Adjust list of properties to be copied accordingly
        $processTags = -not (-not $TagsToAdd -and -not $TagsToRemove)
        $processTags = ($processTags -and -not $CopyTags.IsPresent) `
            -or ($CopyTags.IsPresent -and $CopyTags -eq $true)
        if ($processTags -and ($Properties -notcontains 'System.Tags')) {
            $Properties += 'System.Tags'
        }
        if (!$processTags -and ($Properties -contains 'System.Tags')) {
            $Properties = $Properties | Where-Object { $_ -ne 'System.Tags' }
        }
    }

    process {

        $document = [PSCustomObject] @{
            PSTypeName   = 'PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument'
            WorkItemUrl  = $null
            WorkItemType = $null
            Operations   = [System.Collections.Generic.List[PSCustomObject]]::new()
        }

        if ($SourceWorkItem) {
            # Get work item URL
            $document.WorkItemUrl = $SourceWorkItem.url

            # Copy properties from source work item
            foreach ($property in $Properties) {

                # Skip properties without values
                if (-not $SourceWorkItem.fields."$($property)") {
                    continue
                }

                # Add property to the patch document
                $document.Operations += [PSCustomObject] @{
                    op    = 'add'
                    path  = "/fields/$($property)"
                    from  = $null
                    value = $SourceWorkItem.fields."$($property)"
                }
            }
        }

        # Add additional data to the patch document;
        # If the key already exists in the patch document,
        # it will be overwritten
        foreach ($key in $Data.Keys) {

            $patchItem = $document.Operations `
            | Where-Object { $_.path -eq "/fields/$($key)" } `
            | Select-Object -First 1

            if (!$patchItem) {
                $patchItem = [PSCustomObject] @{
                    op    = 'add'
                    path  = "/fields/$($key)"
                    from  = $null
                    value = $null
                }
                $document.Operations += $patchItem
            }

            $patchItem.value = $Data[$key]
        }

        # Process tags
        if ($processTags) {
            Update-PatchDocumentTags `
                -Document $document `
                -Add $TagsToAdd `
                -Remove $TagsToRemove `
        }

        # Add work item type to the patch document
        $workItemTypePatchItem = $document.Operations `
        | Where-Object { $_.path -eq '/fields/System.WorkItemType' } `
        | Select-Object -First 1

        if (-not $workItemTypePatchItem) {
            $workItemTypePatchItem = [PSCustomObject] @{
                op    = 'add'
                path  = '/fields/System.WorkItemType'
                from  = $null
                value = $null
            }
            $document.Operations += $workItemTypePatchItem
        }

        if (-not $WorkItemType) {
            $WorkItemType = $workItemTypePatchItem.value
            if (-not $WorkItemType) {
                $WorkItemType = 'Task'
            }
        }

        ## Adjust work item type
        $document.WorkItemType = $WorkItemType
        $workItemTypePatchItem.value = $WorkItemType

        # Return the patch document
        return $document
    }

}