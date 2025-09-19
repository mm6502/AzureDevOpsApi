function ConvertTo-ParentUrl {

    <#
    .SYNOPSIS
        Converts work item url to parent's url using parent's id.

    .DESCRIPTION
        Converts work item url to parent's url using parent's id.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [Alias('Url')]
        $ChildUrl,

        [Parameter(Mandatory)]
        [Alias('Parent','ID')]
        $ParentId
    )

    process {
        $parentUrl = $ChildUrl
        # replace workitem id in url

        # example: https://dev.azure.com/org/project/_apis/wit/workitems/1
        # to:      https://dev.azure.com/org/project/_apis/wit/workitems/2
        $parentUrl = $parentUrl -replace 'workitems/([0-9]+)', "workitems/$($ParentId)"

        # example: https://dev.azure.com/org/project/_workitems/edit/1
        # to:      https://dev.azure.com/org/project/_workitems/edit/2
        $parentUrl = $parentUrl -replace '_workitems/edit/([0-9]+)', "_workitems/edit/$($ParentId)"

        return $parentUrl
    }
}