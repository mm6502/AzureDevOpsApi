function Set-WorkItemRelationDescriptorsCache {

    <#
        .SYNOPSIS
            Sets the WorkItemRelationDescriptorsCache.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [PSTypeNameAttribute('PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor')]
        $Value
    )

    process {
        $script:WorkItemRelationDescriptorsCache = $Value
    }
}
