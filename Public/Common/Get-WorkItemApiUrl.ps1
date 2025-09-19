function Get-WorkItemApiUrl {

    <#
        .SYNOPSIS
            Constructs the url for a work item in Azure DevOps API.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_Collection (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Name or identifier of a project in the $Collection.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER WorkItem
            Work item loaded from API or its id.
            In case of id, relies on $CollectionUri and $Project to construct the url.
    #>

    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = 'FromId')]
    param(
        [Parameter(ParameterSetName = 'FromPipeline', Mandatory, ValueFromPipeline)]
        [AllowNull()]
        $InputObject,

        $CollectionUri,

        $Project,

        [Parameter(ParameterSetName = 'FromId', Mandatory, Position = 1)]
        [AllowNull()]
        $WorkItem
    )

    process {

        if ($null -ne $InputObject) {
            $WorkItem = $InputObject
        }

        if ($null -eq $WorkItem ) {
            return
        }

        $WorkItem | ForEach-Object {

            $currentItem = $_

            # It is a work item object
            if ($currentItem.url) {
                return $currentItem.url
            }

            # It is a work item url
            if ($currentItem -like 'http?://*/_apis/wit/workitems/*') {
                return $currentItem
            }

            # Correct the input parameters
            $CollectionUri = Use-CollectionUri -CollectionUri $CollectionUri
            $Project = Use-Project -Project $Project

            # it is a work item id
            $url = Join-Uri `
                -BaseUri $CollectionUri `
                -RelativeUri $Project, '_apis/wit/workitems', $currentItem `
                -NoTrailingSlash

            return $url
        }
    }
}
