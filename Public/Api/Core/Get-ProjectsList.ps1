function Get-ProjectsList {

    <#
        .SYNOPSIS
            Returns list of projects from given project collection.

        .DESCRIPTION
            Returns list of projects from given project collection.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Top
            Count of records per page.

        .PARAMETER Skip
            Count of records to skip before returning the $Top count of records.
            If not specified, iterates the request with increasing $Skip by $Top,
            while records are being returned.
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        $Top,
        $Skip
    )

    process {

        # Get connection object from Collection URI
        $connection = Get-ApiCollectionConnection `
            -Uri $CollectionUri

        $uri = Join-Uri `
            -Base $connection.CollectionUri `
            -Relative "_apis/projects" `
            -NoTrailingSlash

        # To list projects, use:
        # GET https://dev-tfs/tfs/internal_projects/_apis/projects?api-version=5.0-preview
        # | Update the ApiCredential object for the Project Name and Project ID in the cache
        Invoke-ApiListPaged `
            -ApiCredential:$connection.ApiCredential `
            -ApiVersion:$connection.ApiVersion `
            -Uri:$uri `
            -Top:$Top `
            -Skip:$Skip `
        | Add-ApiProject `
            -CollectionUri $connection.CollectionUri `
        | Sync-ApiCredentialForProject `
            -CollectionUri $connection.CollectionUri

    }
}
