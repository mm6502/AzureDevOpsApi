function Remove-WorkItemRelationDescriptor {

    <#
        .SYNOPSIS
            Removes a single work item relationship descriptor from the cached list.

        .PARAMETER Relation
            The Relation property of the descriptor to remove.

        .NOTES
            Removes the descriptor matching the specified Relation from the cached list.
            If no such descriptor exists, a warning is issued and no changes are made.
            Changes are only made in the cache; to persist the changes,
            call Save-WorkItemRelationDescriptorsList.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Relation
    )

    # Get the current descriptors
    $currentDescriptors = @(Get-WorkItemRelationDescriptorsList)

    # Filter out the descriptor to remove
    $updatedDescriptors = @(
        $currentDescriptors `
        | Where-Object { $_.Relation -ne $Relation }
    )

    # Check if any descriptor was actually removed
    if ($currentDescriptors.Count -eq $updatedDescriptors.Count) {
        Write-Warning "No descriptor found with Relation: $($Relation)"
        return
    }

    # Save the updated descriptors in the cache
    if ($null -eq $updatedDescriptors) {
        Set-WorkItemRelationDescriptorsCache -Value @()
    } else {
        Set-WorkItemRelationDescriptorsCache -Value $updatedDescriptors
    }
}
