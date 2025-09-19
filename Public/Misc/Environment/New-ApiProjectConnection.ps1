function New-ApiProjectConnection {

    <#
        .SYNOPSIS
            Creates a new API project connection object.

        .DESCRIPTION
            The `New-ApiProjectConnection` function creates a new API project connection object that
            represents a connection to an Azure DevOps project.

        .PARAMETER ApiCollectionConnection
            The API collection connection object that provides the base connection details.

        .PARAMETER ProjectName
            The name of the Azure DevOps project.

        .PARAMETER ProjectId
            The ID of the Azure DevOps project.

        .PARAMETER ProjectUri
            The URI of the Azure DevOps project.

        .PARAMETER ProjectBaseUri
            The base URI of the Azure DevOps project.

        .PARAMETER Verified
            Indicates whether the project connection has been verified.

        .OUTPUTS
            A `PSCustomObject` representing the API project connection.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('Connection')]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCollectionConnection')]
        $ApiCollectionConnection,

        [Parameter()]
        [Alias('Name')]
        [string] $ProjectName,

        [Parameter()]
        [Alias('Id')]
        [string] $ProjectId,

        [Parameter()]
        [Alias('Uri')]
        [string] $ProjectUri,

        [Parameter()]
        [Alias('BaseUri')]
        [string] $ProjectBaseUri,

        [Parameter()]
        [bool] $Verified = $false
    )

    process {

        if ($ProjectId -and $ApiCollectionConnection.CollectionUri) {
            if (!$ProjectUri) {
                $ProjectUri = Join-Uri `
                    -Base $ApiCollectionConnection.CollectionUri `
                    -Relative "_apis/projects/$($ProjectId)" `
                    -NoTrailingSlash
            }
            if (!$ProjectBaseUri) {
                $ProjectBaseUri = Join-Uri `
                    -Base $ApiCollectionConnection.CollectionUri `
                    -Relative $ProjectId
            }
        }

        if ($ProjectName -and $ApiCollectionConnection.CollectionUri) {
            $ProjectNameBaseUri = Join-Uri `
                -Base $ApiCollectionConnection.CollectionUri `
                -Relative $ProjectName
        }

        # Determine the base URI
        $baseUri = $ApiCollectionConnection.CollectionUri
        if ($ProjectNameBaseUri) {
            $baseUri = $ProjectNameBaseUri
        }
        if ($ProjectBaseUri) {
            $baseUri = $ProjectBaseUri
        }

        return [PSCustomObject] @{
            PSTypeName         = $global:PSTypeNames.AzureDevOpsApi.ApiProjectConnection
            Verified           = $Verified
            CollectionUri      = $ApiCollectionConnection.CollectionUri
            ApiVersion         = $ApiCollectionConnection.ApiVersion
            ApiCredential      = $ApiCollectionConnection.ApiCredential
            BaseUri            = $baseUri
            ProjectUri         = $ProjectUri
            ProjectBaseUri     = $ProjectBaseUri
            ProjectId          = $ProjectId
            ProjectIdBaseUri   = $ProjectBaseUri
            ProjectName        = $ProjectName
            ProjectNameBaseUri = $ProjectNameBaseUri
        }
    }
}
