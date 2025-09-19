function Get-CurrentUserProfile {

    <#
        .SYNOPSIS
            Gets Profile of the current user (based on the provided authorization).

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER ApiCredential
            Credentials to use when connecting to Azure DevOps.
            If not specified, $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.
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
        # Get connection object from Collection URI
        $connection = Get-ApiCollectionConnection `
            -Uri $CollectionUri `

        # Get URI for the request
        $uri = Join-Uri `
            -Base $connection.CollectionUri `
            -Relative '_api/_common/GetUserProfile' `
            -NoTrailingSlash

        # Make the call
        Invoke-Api `
            -ApiVersion $connection.ApiVersion `
            -ApiCredential $connection.ApiCredential `
            -Uri $uri
    }
}
