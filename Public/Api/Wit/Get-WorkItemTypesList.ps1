function Get-WorkItemTypesList {

    <#
        .SYNOPSIS
            Gets list of work items types in given project.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-item-types/list?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Pipeline', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'Default', Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri
    )

    # Get connection to project
    $connection = Get-ApiProjectConnection `
        -CollectionUri $CollectionUri `
        -Project $Project

    # GET https://dev.azure.com/{organization}/{project}/_apis/wit/workitemtypes?api-version=5.0
    $uri = Join-Uri `
        -Base $connection.ProjectBaseUri `
        -Relative "_apis/wit/workitemtypes" `
        -NoTrailingSlash

    # Make the call
    Invoke-ApiListPaged `
        -ApiCredential:$connection.ApiCredential `
        -ApiVersion:$connection.ApiVersion `
        -Uri:$uri `
        -AsHashTable `
    | ForEach-Object { [PSCustomObject] $_ }
}
