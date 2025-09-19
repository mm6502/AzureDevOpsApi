function New-ApiCollectionConnection {

    <#
        .SYNOPSIS
            Gets an API collection connection object for interacting with the Azure DevOps API.

        .DESCRIPTION
            The `Get-ApiCollectionConnection` function creates a `PSCustomObject` that represents
            an API collection connection to the Azure DevOps API. This object contains the necessary
            information to make API calls, including the collection URI, API credentials, and API version.

        .PARAMETER CollectionUri
            The URI of the Azure DevOps collection to connect to.

        .PARAMETER ApiCredential
            The API credentials to use for authentication.

        .PARAMETER ApiVersion
            The version of the Azure DevOps API to use.

        .OUTPUTS
            PSTypeNames.AzureDevOpsApi.ApiCollectionConnection
            A `PSCustomObject` representing the API collection connection.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCollectionConnection')]
    param (
        [Parameter(Mandatory)]
        $CollectionUri,

        [Parameter(Mandatory)]
        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        [Parameter()]
        $ApiVersion
    )

    process {

        $CollectionUri = Use-CollectionUri -CollectionUri $CollectionUri
        $ApiVersion = Use-ApiVersion -ApiVersion $ApiVersion

        return [PSCustomObject] @{
            PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCollectionConnection
            CollectionUri = $CollectionUri
            # For fallback from Project connection to Collection connection
            # property with the same name is used
            BaseUri       = $CollectionUri
            ApiCredential = $ApiCredential
            ApiVersion    = $ApiVersion
        }
    }
}
