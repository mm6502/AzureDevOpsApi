function Select-WorkItemRelationDescriptor {

    <#
        .SYNOPSIS
            Return the link descriptor between work items -
            object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.
            For information, see the New-WorkItemRelationDescriptor function.

        .PARAMETER RelationDescriptors
            List of descriptors of relationships between work items.
            Defacto configuration of how work items are crawled when adding data to release notes.

        .PARAMETER WorkItem
            Work item whose bindings we are evaluating (source).

        .PARAMETER Relation
            One of the bindings on the given work item object.
            Eg: $WorkItem.relations[0]

        .OUTPUTS
            Object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.
            For information, see the New-Work Item Relation Descriptor function.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor')]
    [CmdletBinding()]
    param(
        $RelationDescriptors,
        $WorkItem,
        $Relation
    )

    process {
        # Sanity check
        if (!$WorkItem -or !$Relation) {
            return
        }

        # Select the relevant descriptor
        $relevant = $RelationDescriptors `
        | Where-Object { (Use-Value -A $Relation.rel -B $Relation) -ilike $_.Relation } `
        | Where-Object { (Get-WorkItemType $WorkItem) -iin $_.FollowFrom } `
        | Select-Object -First 1

        if ($relevant) {
            $relevant
        }
    }
}
