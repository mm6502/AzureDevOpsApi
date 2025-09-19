function New-PatchDocumentUpdate {

    <#
        .SYNOPSIS
            Create a JSON Patch document for updating work item.
            The document can be used with Update-WorkItem to update work item.

        .PARAMETER SourceWorkItem
            Source work item to update.

        .PARAMETER Properties
            Properties to copy to update document.
            Default is empty array.

        .PARAMETER Data
            Additional data to add to the patch document.

        .PARAMETER TagsToAdd
            Tags to add to the work item.

        .PARAMETER TagsToRemove
            Tags to remove from the work item.

        .PARAMETER Callback
            Callback function to process the patch document before it is sent to the server.
            Takes single parameter - the patch document.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/create?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingAllowUnencryptedAuthentication', '',
        Justification = ''
    )]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = ''
    )]
    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument')]
    param(
        [Parameter(ValueFromPipeline)]
        [Alias('Source')]
        $SourceWorkItem,
        [string[]] $Properties,
        [hashtable] $Data,
        [string[]] $TagsToAdd,
        [string[]] $TagsToRemove,
        [scriptblock] $Callback
    )

    process {

        # Create a new patch document
        $document = New-PatchDocument `
            -SourceWorkItem $SourceWorkItem `
            -WorkItemType $SourceWorkItem.fields.'System.WorkItemType' `
            -TagsToAdd $TagsToAdd `
            -TagsToRemove $TagsToRemove `
            -Properties $Properties `
            -Data $Data

        # Add test for current revision
        if ($null -ne $SourceWorkItem) {
            $document.Operations += [PSCustomObject] @{
                op    = 'test'
                path  = "/rev"
                value = "$($SourceWorkItem.rev)"
            }
        }

        # Apply callback function if specified
        if ($Callback) {
            $document = & $Callback $document
        }

        # Return the patch document
        if ($document) {
            $document
        }
    }
}
