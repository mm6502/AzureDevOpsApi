function Add-ApiCollection {

    <#
        .SYNOPSIS
            Creates an object that describes Azure DevOps project collection.

        .DESCRIPTION
            Creates an object that describes Azure DevOps project collection.

        .PARAMETER CollectionUri
            The URI of the Azure DevOps collection.

        .PARAMETER ApiVersion
            The version of the Azure DevOps API.

        .PARAMETER PassThru
            If specified, the created object will be passed through the pipeline.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCollection')]
    param(
        [Parameter(ParameterSetName = 'ByObject')]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCollection')]
        [PSCustomObject] $ApiCollection,

        [Parameter(ParameterSetName = 'ByParams')]
        $CollectionUri,

        [Parameter(ParameterSetName = 'ByParams')]
        $ApiVersion,

        [switch] $PassThru
    )

    begin {
        $cache = Get-ApiCollectionsCache
    }

    process {

        # Create the api collection
        if (!$ApiCollection) {
            $ApiCollection = New-ApiCollection `
                -CollectionUri $CollectionUri `
                -ApiVersion $ApiVersion
        }

        # Add to cache
        $cache[$ApiCollection.CollectionUri] = $ApiCollection

        # Return the added credential
        if ($PassThru.IsPresent -and ($true -eq $PassThru)) {
            return $ApiCollection
        }
    }
}
