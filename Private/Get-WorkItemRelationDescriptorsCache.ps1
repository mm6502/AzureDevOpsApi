function Get-WorkItemRelationDescriptorsCache {

    <#
        .SYNOPSIS
            Gets the WorkItemRelationDescriptorsCache.
    #>

    [CmdletBinding()]
    [OutputType('CustomTypes.AzureDevOpsApi.WorkItemRelationDescriptor')]
    param()

    process {
        return $script:WorkItemRelationDescriptorsCache
    }
}
