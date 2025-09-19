function Get-CurrentUser {

    <#
        .SYNOPSIS
            Returns detail of current user connecting to the Azure DevOps server instance.

        .DESCRIPTION
            Returns detail of current connection.

            Properties of interest:
            - `authenticatedUser`
            - `authorizedUser`

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

        $connectionData = Get-ConnectionData `
            -CollectionUri $CollectionUri `
            -ApiCredential $ApiCredential

        $connectionData.authenticatedUser
    }
}
