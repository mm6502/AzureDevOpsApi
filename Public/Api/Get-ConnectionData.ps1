function Get-ConnectionData {

    <#
        .SYNOPSIS
            Returns detail of current connection.

        .DESCRIPTION
            Returns detail of current connection.

            Properties of interest:
            - `authenticatedUser`
            - `authorizedUser`

        .PARAMETER Collection
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Uri')]
        $CollectionUri,

        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential
    )

    process {

        # Get connection object
        $connection = Get-ApiCollectionConnection `
            -Uri $CollectionUri `
            -ApiCredential $ApiCredential

        # Rest method is available only in preview
        if ($connection.ApiVersion -notlike '*-preview*') {
            $connection.ApiVersion += '-preview'
        }

        $uri = Join-Uri `
            -Base $connection.CollectionUri `
            -Relative '_apis/connectionData' `
            -NoTrailingSlash

        # GET https://dev-tfs/tfs/internal_projects/_apis/connectionData?api-version=5.0-preview
        Invoke-Api `
            -ApiCredential $connection.ApiCredential `
            -ApiVersion $connection.ApiVersion `
            -Uri $uri

    }
}
