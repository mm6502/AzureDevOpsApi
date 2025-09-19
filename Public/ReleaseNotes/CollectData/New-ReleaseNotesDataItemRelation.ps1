function New-ReleaseNotesDataItemRelation {

    <#
        .SYNOPSIS
            Creates a new object for recording the session/relationship with other work items.

        .PARAMETER RelationName
            The name of the relationship from the perspective of the work item.

        .PARAMETER Relations
            List of identifiers of other work items with which this relationship has.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = ''
    )]
    [OutputType('PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItemRelation')]
    [CmdletBinding()]
    param(
        [string] $RelationName,
        [string[]] $Relations
    )

    process {

        if (!$Relations) {
            $Relations = [string[]] @()
        }

        [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItemRelation'
            Name       = $RelationName
            Relations  = [System.Collections.Generic.HashSet[string]]::new([string[]] $Relations)
        }
    }
}
