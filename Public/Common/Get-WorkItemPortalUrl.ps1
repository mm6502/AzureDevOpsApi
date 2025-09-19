function Get-WorkItemPortalUrl {

    <#
        .SYNOPSIS
            Work items loaded as revision (e.g. due to the AsOf parameter)
            do not contain a link for editing on the portal. For these we
            need to assemble the link.

        .PARAMETER Collection
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_Collection (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Name or identifier of a project in the $Collection.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER WorkItem
            Work item loaded from API or its id.
            In case of id, relies on $Collection and $Project to construct the url.
    #>

    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = 'FromId')]
    param(
        [Parameter(ParameterSetName = 'FromPipeline', Mandatory, ValueFromPipeline)]
        [AllowNull()]
        $InputObject,

        [Parameter(ParameterSetName = 'FromId')]
        [Alias('Collection', 'Uri')]
        $CollectionUri,

        [Parameter(ParameterSetName = 'FromId')]
        $Project,

        [Parameter(ParameterSetName = 'FromId', Mandatory, Position = 1)]
        [AllowNull()]
        [Alias('WorkItemUrl', 'Url', 'Id')]
        $WorkItem
    )

    begin {

        $CollectionUri = Use-CollectionUri -Uri $CollectionUri
        $Project = Use-Project -Project $Project

        $matchPattern = '/_apis/wit/workitems/(?<id>\d+)(?:/revisions/(?:\d+))?'
        $replacePattern = '/_workitems/edit/$1'
    }

    process {

        if ($null -ne $InputObject) {
            $WorkItem = $InputObject
        }

        if (!$WorkItem) {
            return
        }

        if ($WorkItem -is [PSObject]) {
            # it is a work item object
            if ($WorkItem._links.html.href) {
                $WorkItem._links.html.href
            } elseif ($WorkItem.url) {
                # work item revisions do not have a link to the portal edit, we have to create one
                # .../_apis/wit/workitems/372767/revisions/11
                # =>
                # .../_workitems/edit/372767
                $WorkItem.url -replace $matchPattern, $replacePattern
            }
            return
        }

        # it is a work item url
        if ($WorkItem | Test-WebAddress) {
            $WorkItem -replace $matchPattern, $replacePattern
            return
        }

        # if it is not a work item url or id
        if ($WorkItem -notmatch '^\d+$') {
            throw "Work item id or url expected, got '$WorkItem'."
        }

        # it is a work item id
        if (!$CollectionUri) {
            throw "Collection not specified."
        }

        if (!$Project) {
            throw "Project not specified."
        }

        # Construct the url
        # https://dev.azure.com/myorg/myproject/_apis/wit/workitems/12345
        # =>
        # https://dev.azure.com/myorg/myproject/_workitems/edit/12345
        if ($CollectionUri.EndsWith('/')) {
            $url = "$($CollectionUri)$($Project)/_workitems/edit/$($WorkItem)"
        } else {
            $url = "$($CollectionUri)/$($Project)/_workitems/edit/$($WorkItem)"
        }

        # Return the url
        $url
    }
}
