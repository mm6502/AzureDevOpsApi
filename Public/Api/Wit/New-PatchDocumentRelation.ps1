function New-PatchDocumentRelation {

    <#
        .SYNOPSIS
            Adds a relation to a patch document.

        .PARAMETER TargetWorkItem
            Target work item of the relation,
            Or Uri of the target work item of the relation.

        .PARAMETER RelationType
            Relation type to add (from point of view of the PatchDocument).
            Fully qualified name of the relation type.
            For example:
            'System.LinkTypes.Hierarchy-Reverse' for 'Parent' end of the Parent-Child relation.

        .PARAMETER RelationName
            Relation name to add (from point of view of the PatchDocument).
            User friendly name of the relation.
            For example:
            'Parent' for 'Parent' end of the Parent-Child relation.

            Read as "I (work item being updated) have 'Parent' TargetWorkItem".
            Read as "I (work item being updated) am 'Affected By' TargetWorkItem".
            Read as "I (work item being updated) 'Tests' TargetWorkItem".

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/update?view=azure-devops-rest-5.0&tabs=HTTP#add-a-link
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
    param(
        [Parameter(ValueFromPipeline)]
        [Alias('Target', 'Uri', 'TargetUri')]
        $TargetWorkItem,
        $RelationType,
        $RelationName
    )

    begin {

        # At least one of RelationType or RelationName must be specified
        if (!$RelationType -and !$RelationName) {
            throw 'Either RelationType or RelationName must be specified.'
        }

        # If RelationType is not specified, try to find it by Name
        if (!$RelationType) {
            $RelationType = Get-WorkItemRelationDescriptorsList `
            | Where-Object { $_.NameOnSource -eq $RelationName } `
            | Select-Object -First 1 -ExpandProperty 'Relation'
        }

        # If RelationName is not specified, try to find it by Type
        if (!$RelationName) {
            $RelationName = Get-WorkItemRelationDescriptorsList `
            | Where-Object { $_.Relation -eq $RelationType } `
            | Select-Object -First 1 -ExpandProperty 'NameOnSource'
        }
    }

    process {

        $TargetWorkItem | ForEach-Object {

            $currentItem = $_

            if (!$currentItem) {
                return
            }

            $TargetWorkItemUri = $null
            if ($currentItem -is [string]) {
                # target work item is a string
                $TargetWorkItemUri = $currentItem
            } else {
                # target work item is an object
                $TargetWorkItemUri = $currentItem.url
            }

            [PSCustomObject] @{
                "op"    = "add"
                "path"  = "/relations/-"
                "from"  = $null
                "value" = [PSCustomObject] @{
                    "rel"        = $RelationType
                    "url"        = $TargetWorkItemUri
                    "attributes" = [PSCustomObject] @{
                        "isLocked" = $false
                        "name"     = $RelationName
                    }
                }
            }
        }
    }
}
