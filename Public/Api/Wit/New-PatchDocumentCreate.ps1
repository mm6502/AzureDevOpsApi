function New-PatchDocumentCreate {

    <#
        .SYNOPSIS
            Create a JSON Patch document for creating work item.
            The document can be used with New-WorkItem to create work item.

        .PARAMETER SourceWorkItem
            Source work item to copy properties from.

        .PARAMETER WorkItemType
            Type of work item to create.
            If specified, overrides the value set by $Properties and $Data.
            Default is 'Task'.

        .PARAMETER Properties
            Properties to copy from source work item.

            Default list is:
            - 'System.WorkItemType',
            - 'System.Title',
            - 'System.Description',
            - 'System.Tags',
            - 'System.AreaPath',
            - 'System.IterationPath',
            - 'Microsoft.VSTS.Common.Priority'

        .PARAMETER Data
            Additional data to add to the patch document. Default is empty hashtable.
            If specified, overrides the value set by $Properties.

        .PARAMETER CopyTags
            Flag, whether to copy tags from the source work item.

        .PARAMETER TagsToAdd
            Tags to add to the work item.

        .PARAMETER TagsToRemove
            Tags to remove from the work item.

        .PARAMETER AsChild
            Flag, whether to create as child of the source work item.

        .PARAMETER CopyRelations
            Flag, whether to copy relations from the source work item.

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
        $WorkItemType,

        [string[]] $Properties,
        [hashtable] $Data,

        [switch] $CopyTags,
        [string[]] $TagsToAdd,
        [string[]] $TagsToRemove,

        [switch] $AsChild,
        [switch] $CopyRelations,

        [scriptblock] $Callback
    )

    begin {
        # Set default properties to be copied, if not specified
        if (-not $PSBoundParameters.ContainsKey('Properties')) {
            $Properties = @(
                'System.WorkItemType'
                'System.Title'
                'System.Description'
                'System.Tags'
                'System.AreaPath'
                'System.IterationPath'
                'Microsoft.VSTS.Common.Priority'
                'Microsoft.VSTS.Scheduling.TargetDate'
                'Microsoft.VSTS.Scheduling.OriginalEstimate'
            )
        }
    }

    process {

        # Create a new patch document
        $document = New-PatchDocument `
            -SourceWorkItem $SourceWorkItem `
            -WorkItemType $WorkItemType `
            -CopyTags:$CopyTags `
            -TagsToAdd $TagsToAdd `
            -TagsToRemove $TagsToRemove `
            -Properties $Properties `
            -Data $Data

        # Add the parent-child relation to the patch document, if requested
        if (($AsChild -eq $true) -and $SourceWorkItem.url) {
            $relationDescriptor = Get-WorkItemRelationDescriptorsList `
            | Where-Object { $_.Relation -eq 'System.LinkTypes.Hierarchy-Reverse' }

            if ($relationDescriptor) {
                $document.Operations += New-PatchDocumentRelation `
                    -TargetUri $SourceWorkItem.url `
                    -RelationType $relationDescriptor.Relation `
                    -RelationName $relationDescriptor.NameOnTarget
            } else {
                Write-Warning "Relation descriptor for 'System.LinkTypes.Hierarchy-Reverse' not found."
            }
        }

        # Copy relations from source work item
        if ($CopyRelations.IsPresent `
                -and ($CopyRelations -eq $true) `
                -and $SourceWorkItem.relations
        ) {
            # Copy every relation
            foreach ($relation in $SourceWorkItem.relations) {

                # Skip child relations
                if ($relation.rel -like "System.LinkTypes.Hierarchy-Forward") {
                    continue
                }

                # Skip parent relation, if was set to be copied as child
                if ($AsChild -and $SourceWorkItem.url) {
                    if ($relation.rel -like "System.LinkTypes.Hierarchy-Reverse") {
                        continue
                    }
                }

                # Skip commits and changesets
                if ($relation.rel -like "ArtifactLink") {
                    continue
                }

                # Add relation to patch document
                $document.Operations += New-PatchDocumentRelation `
                    -TargetUri $relation.url `
                    -RelationType $relation.rel `
                    -RelationName $relation.attributes.name
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
