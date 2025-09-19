function Invoke-WorkItemsQuery {

    <#
        .SYNOPSIS
            Query work items.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.

        .PARAMETER Query
            WIQL query.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/wiql/query-by-wiql?view=azure-devops-rest-5.1&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Parameter()]
        $Query
    )

    process {

        # Get Project Connection
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # POST https://dev.azure.com/fabrikam/_apis/wit/wiql?api-version=7.2-preview.2
        # POST https://dev.azure.com/{organization}/{project}/{team}/_apis/wit/wiql?api-version=5.0
        # {
        #    "query": "select [System.Id], [System.Title], [System.State]"
        #    +" from WorkItems"
        #    +" where"
        #    +" [System.WorkItemType] = 'Task' AND [State] <> 'Closed' AND [State] <> 'Removed'"
        #    +" order by [Microsoft.VSTS.Common.Priority] asc, [System.CreatedDate] desc"
        # }
        $uri = Join-Uri `
            -Base $connection.ProjectBaseUri `
            -Relative "_apis/wit/wiql" `
            -NoTrailingSlash

        $uri = Add-QueryParameter `
            -Uri $uri `
            -Parameters @{ 'timePrecision' = 'true' }

        # WIQL query has to be POSTed as object with query property
        $requestMessage = [PSCustomObject] @{
            query = $Query
        } | ConvertTo-JsonCustom

        Write-Debug "Query: $Query"

        Invoke-Api `
            -ApiVersion $connection.ApiVersion `
            -ApiCredential $connection.ApiCredential `
            -Uri $uri `
            -Body $requestMessage
    }
}
