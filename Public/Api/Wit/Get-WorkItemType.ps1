function Get-WorkItemType {

    <#
        .SYNOPSIS
            Extracts work item type from the given work item.

        .PARAMETER WorkItem
            Work item detail object.
    #>

    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $WorkItem
    )

    process {
        $WorkItem.fields.'System.WorkItemType'
    }
}
