function New-WorkItemRelationDescriptor {

    <#
        .SYNOPSIS
            Creates a new link descriptor between work items -
            object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.

        .OUTPUTS
            PSCustomObject with PSTypeName 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.

            [PSCustomObject] @{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
                Relation     = 'System.LinkTypes.Hierarchy-Reverse'
                FollowFrom   = @('Task','Bug','Requirement')
                NameOnSource = 'Child'
                NameOnTarget = 'Parent'
            }

            Relation     - System link type as used in Azure DevOps.
            FollowFrom   - List of types of work items on which this type of link is to be tracked.
            NameOnSource - The name of the link on the source work item.
            NameOnTarget - The name of the link on the target work item.

        .PARAMETER Relation
            System link type as used in Azure DevOps.

        .PARAMETER FollowFrom
            List of types of work items on which this type of link is to be tracked.

        .PARAMETER NameOnSource
            The name of the link on the source work item.

        .PARAMETER NameOnTarget
            The name of the link on the target work item.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = ''
    )]
    [OutputType('PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor')]
    [OutputType('PSCustomObject')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Relation,

        [string[]] $FollowFrom = @(),

        [string] $NameOnSource,

        [Parameter(Mandatory)]
        [string] $NameOnTarget
    )

    process {
        [PSCustomObject] @{
            PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
            Relation     = $Relation
            FollowFrom   = $FollowFrom
            NameOnSource = $NameOnSource
            NameOnTarget = $NameOnTarget
        }
    }
}
