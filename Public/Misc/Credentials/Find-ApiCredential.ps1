function Find-ApiCredential {

    <#
        .SYNOPSIS
            Finds an API credential in the cache.

        .DESCRIPTION
            Finds an API credential in the cache.

            If the credential is not found, the function will try to find the default credentials, if any.
            If the credential is not found, the function will return $null.

        .PARAMETER CollectionUri
            The URI of the Azure DevOps collection.

        .PARAMETER Project
            The name of the Azure DevOps project.

        .PARAMETER PreventFallback
            If set, the function will not try to find the default credentials, if any.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCredential')]
    param(
        [Parameter(Mandatory)]
        [string] $CollectionUri,
        [string] $Project,
        [switch] $PreventFallback
    )

    begin {
        $cache = Get-ApiCredentialsCache
    }

    process {

        $CollectionCredentials = $null
        $ApiCredential = $null

        # Correct the Collection
        $CollectionUri = Format-Uri -Uri $CollectionUri

        # Try to find the collection uri credentials
        $CollectionCredentials = $cache[$CollectionUri]
        if ($PreventFallback.IsPresent -and ($false -eq $PreventFallback)) {
            if (!$CollectionCredentials) {
                # If not found, try the default credentials, if any
                $CollectionUri = [string]::Empty
                # If not found either, stop
                $CollectionCredentials = $cache[$CollectionUri]
                if (!$CollectionCredentials) {
                    return
                }
            }
        }

        # Correct the Project
        if (!$Project) {
            $Project = [string]::Empty
        }
        $Project = $Project.Trim()

        # Try to find the project credentials
        if ($CollectionCredentials) {
            $ApiCredential = $CollectionCredentials[$Project]
            if (!$ApiCredential) {
                # If not found, try the default credentials, if any
                # If not prevented by the PreventFallback switch
                if (!$PreventFallback.IsPresent -and ($PreventFallback -ne $true)) {
                    $Project = [string]::Empty
                    $ApiCredential = $CollectionCredentials[$Project]
                    # If not found either, stop
                    if (!$ApiCredential) {
                        return
                    }
                }
            }
        }

        if ($ApiCredential) {
            $ApiCredential
        }
    }
}
