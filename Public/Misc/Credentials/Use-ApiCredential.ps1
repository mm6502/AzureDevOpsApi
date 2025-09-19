function Use-ApiCredential {

    <#
        .SYNOPSIS
            Determines the API credential to use for given CollectionUri.
            If none is provided, tries to find usable credentials
            in cached credentials (added by Add-ApiCredential) or default
            credential by Set-ApiVariables.

        .DESCRIPTION
            Determines the API credential to use for given CollectionUri.
            If none is provided, tries to find usable credentials
            in cached credentials (added by Add-ApiCredential) or default
            credential by Set-ApiVariables.

        .PARAMETER ApiCredential
            The API credential to use. If not provided, will try to find one
            in cache or default credential.

        .PARAMETER CollectionUri
            The collection Uri of target API endpoint. Determined by lookup in registered
            collections (added by Add-ApiCollection or by Set-ApiVariables).

        .PARAMETER Project
            The target project from given CollectionUri to use. Used to lookup
            ApiCredential if not given.

    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCredential')]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project = $null
    )

    process {

        # Use given credential, if any.
        if ($ApiCredential) {
            return $ApiCredential
        }

        # Or the one in the cache.
        # Try to resolve CollectionUri first.
        $collectionUri = Use-CollectionUri `
            -CollectionUri $CollectionUri

        # Find appropriate credential for given collection.
        if ($collectionUri) {
            $candidate = Find-ApiCredential `
                -CollectionUri $collectionUri `
                -Project $Project
        }

        # Or the one in the global variable.
        if (!$candidate) {
            $candidate = $global:AzureDevOpsApi_ApiCredential
        }

        if ($candidate) {
            return $candidate
        }
    }
}
