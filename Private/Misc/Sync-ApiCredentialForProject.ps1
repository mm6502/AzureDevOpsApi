if ($PSVersionTable.PSVersion.Major -le 5) {
    Add-Type -AssemblyName System.Web
}

filter Sync-ApiCredentialForProject {

    <#
        .SYNOPSIS
            Syncs the cached ApiCredential object for Project Name and Project ID.

        .DESCRIPTION
            Syncs the cached ApiCredential object for Project Name and Project ID.
            Used by Get-Project and Get-PeojectsList to update the cached ApiCredential
            object for the Project Name and Project ID.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.

        .PARAMETER Project
            Project object read from Azure DevOps REST Api.

        .PARAMETER ApiCredential
            Credentials to use when connecting to Azure DevOps.
            Expects an PSCustomObject of type 'PSTypeNames.AzureDevOpsApi.ApiCredential'.
            If not specified, $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

        .OUTPUTS
            Project PSCustomObject as returned by the Azure DevOps REST Api.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingPlainTextForPassword', '',
        Justification = 'Expects custom object'
    )]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $Project,
        $CollectionUri,
        $ApiCredential
    )

    process {
        # Find the Project Name and Project ID
        $projectId = $Project.id
        $projectName = $Project.name
        $projectApiCredential = $null

        # Flags whether to update cache or not
        $shouldUpdateApiCredentialByName = $false
        $shouldUpdateApiCredentialById = $false

        # Find the ApiCredential for the Project Name
        $apiCredentialByName = Find-ApiCredential `
            -CollectionUri $CollectionUri `
            -Project $projectName `
            -PreventFallback

        if (!$apiCredentialByName) {
            $shouldUpdateApiCredentialByName = $true
        } else {
            $projectApiCredential = $apiCredentialByName
        }

        # Find the ApiCredential for the Project ID
        $apiCredentialById = Find-ApiCredential `
            -CollectionUri $CollectionUri `
            -Project $projectId `
            -PreventFallback

        if (!$apiCredentialById) {
            $shouldUpdateApiCredentialById = $true
        } else {
            $projectApiCredential = $apiCredentialById
        }

        # If no ApiCredential object was found for the Project Name or Project ID, just return
        if (!$projectApiCredential) {
            $projectApiCredential = $ApiCredential
        }
        if (!$projectApiCredential) {
            # Nothing to do
            return $Project
        }

        # Update the ApiCredential object for the Project Name
        if ($shouldUpdateApiCredentialByName) {
            $null = Add-ApiCredential `
                -CollectionUri $CollectionUri `
                -Project $projectName `
                -ApiCredential $projectApiCredential `
                -SkipValidation
        }

        # Update the ApiCredential object for the Project ID
        if ($shouldUpdateApiCredentialById) {
            $null = Add-ApiCredential `
                -CollectionUri $CollectionUri `
                -Project $projectId `
                -ApiCredential $projectApiCredential `
                -SkipValidation
        }

        # Return the Project object
        return $Project
    }
}
