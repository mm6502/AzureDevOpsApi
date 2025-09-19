function Get-ApiCollectionConnection {

    <#
        .SYNOPSIS
            Returns new connection object.

            Used to determine the correct url for the collection and the correct api version to use
            for given Url.

            Properties of the returned object are:
            - CollectionUri: Url for project collection on Azure DevOps server instance.
            - ApiCredential: Default ApiCredential object to use for authentication on given CollectionUri.
            - ApiVersion: Version of Azure DevOps API to use.

        .PARAMETER Uri
            Uri to Rest Api endpoint on Azure DevOps server instance.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER ApiCredential
            ApiCredential object to use for authentication on given CollectionUri.
            If not specified, $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

        .PARAMETER ApiVersion
            Version of Azure DevOps API to use.
            If not specified, $global:AzureDevOpsApi_ApiVersion (set by Set-AzureDevopsVariables) is used.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCollectionConnection')]
    [CmdletBinding()]
    param(
        $Uri,
        $CollectionUri,

        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        $ApiVersion
    )

    process {

        # If $Uri is not specified, use empty string
        if (!$Uri) {
            $Uri = [string]::Empty
        }

        # If $Uri is specified, and an absolute one, use it as $CollectionUri
        if (([Uri]::new($Uri, [UriKind]::RelativeOrAbsolute)).IsAbsoluteUri) {
            $CollectionUri = Format-Uri -Uri $Uri
        } else {
            $CollectionUri = Format-Uri -Uri $CollectionUri
        }

        # Try to find the collection in the cache
        $apiCollection = Find-ApiCollection -Uri $CollectionUri

        if ($apiCollection) {
            $CollectionUri = $apiCollection.CollectionUri
            $ApiVersion = $apiCollection.ApiVersion
        } else {
            # Get CollectionUri to use
            $CollectionUri = Use-CollectionUri `
                -CollectionUri $CollectionUri

            # Get ApiVersion to use
            $ApiVersion = Use-ApiVersion `
                -CollectionUri $CollectionUri

            $apiCollection = New-ApiCollection `
                -CollectionUri $CollectionUri `
                -ApiVersion $ApiVersion
        }

        # Get ApiCredential to use
        $ApiCredential = Use-ApiCredential `
            -CollectionUri $CollectionUri `
            -ApiCredential $ApiCredential

        # Create new connection object
        return New-ApiCollectionConnection `
            -CollectionUri $CollectionUri `
            -ApiCredential $ApiCredential `
            -ApiVersion    $ApiVersion
    }
}
