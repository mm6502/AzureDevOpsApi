function Add-WorkItemRelationDescriptor {

    <#
        .SYNOPSIS
            Adds a single work item relationship descriptor to the cache.

        .PARAMETER Descriptor
            The descriptor object to add. It should include Relation, FollowFrom, NameOnSource,
            and NameOnTarget.

        .NOTES
            Appends the descriptor to the current cached list.
            If a descriptor with the same Relation already exists, an error is thrown and no changes are made.
            Changes are only made in the cache; to persist the changes,
            call Save-WorkItemRelationDescriptorsList.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor')]
        $Descriptor
    )

    # Validate the descriptor has required properties
    foreach ($prop in @('Relation', 'FollowFrom', 'NameOnSource', 'NameOnTarget')) {
        if (-Not ($Descriptor.PSObject.Properties.Name -contains $prop)) {
            throw "Descriptor is missing required property: $($prop)"
        }
    }

    # Get the current descriptors
    $currentDescriptors = @(Get-WorkItemRelationDescriptorsList)

    # Check for duplicates based on Relation
    if ($currentDescriptors.Relation -contains $Descriptor.Relation) {
        Write-Error "Descriptor with Relation: $($Descriptor.Relation) already exists."
        return
    }

    # Add the new descriptor
    $currentDescriptors += $Descriptor

    # Save the updated list in the cache
    Set-WorkItemRelationDescriptorsCache -Value $currentDescriptors
}
