function New-ApiCollection {

    <#
        .SYNOPSIS
            Creates an object that describes Azure DevOps project collection.

        .DESCRIPTION
            Creates an object that describes Azure DevOps project collection.

        .PARAMETER CollectionUri
            The URI of the Azure DevOps collection.

        .PARAMETER ApiVersion
            The version of the Azure DevOps API.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCollection')]
    param(
        $CollectionUri,
        $ApiVersion
    )

    process {
        $CollectionUri = Use-CollectionUri -CollectionUri $CollectionUri
        $ApiVersion = Use-ApiVersion -ApiVersion $ApiVersion
        return [PSCustomObject] @{
            PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCollection
            CollectionUri = $CollectionUri
            ApiVersion    = $ApiVersion
        }
    }
}
