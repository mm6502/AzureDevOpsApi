function Add-ApiCredential {

    <#
        .SYNOPSIS
            Creates an object that contains credentials for the Azure DevOps API calls
            and stores it in the global cache associated with the collection URI and project.

        .DESCRIPTION
            This function is used to create an object that contains credentials for the Azure DevOps API.

        .PARAMETER ApiCredential
            Adds ApiCredentials previously created via New-ApiCredential.

        .PARAMETER SkipValidation
            Skips validation of the ApiCredential.

        .PARAMETER CollectionUri
            The URI of the Azure DevOps collection.

        .PARAMETER Project
            The name of the Azure DevOps project.

        .PARAMETER Token
            The token used to authenticate to the Azure DevOps API.

        .PARAMETER Credential
            The [PSCredential] used to authenticate to the Azure DevOps API.

        .PARAMETER Authorization
            The authorization used to authenticate to the Azure DevOps API.
            Possible values are:
            - $null or '' - autodetect the type of authorization, based on the value of
               the $Token and $Credential parameters.
            - 'Default' - Use the default network credentials.
            - 'Basic' - Use given $apiCredential.
            - 'PAT' or 'PersonalAccessToken' - Use a Personal Access Token.
            - 'Bearer' - Use a Bearer token.

        .PARAMETER PassThru
            If specified, returns the ApiCredential object.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Credential')]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCredential')]
    param(
        [Parameter(ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'Credential')]
        [Parameter(ParameterSetName = 'ApiCredential')]
        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Parameter(ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'Credential')]
        [Parameter(ParameterSetName = 'ApiCredential')]
        [AllowNull()]
        [AllowEmptyString()]
        $Project = $null,

        [Alias('ForCollection')]
        [switch] $AlsoUseForCollection,

        [Parameter(ParameterSetName = 'Token')]
        [Parameter(ParameterSetName = 'Credential')]
        [Parameter(ParameterSetName = 'ApiCredential')]
        [ValidateSet($null, '', 'Default', 'Basic', 'PersonalAccessToken', 'PAT', 'Bearer', 'OAuth')]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Authorization,

        [Parameter(ParameterSetName = 'Token')]
        $Token,

        [Parameter(ParameterSetName = 'Credential')]
        [AllowNull()]
        [PSCredential] $Credential,

        [Parameter(ParameterSetName = 'ApiCredential', Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        [switch] $SkipValidation,

        [switch] $PassThru
    )

    begin {
        $cache = Get-ApiCredentialsCache
    }

    process {

        # Create the api credential
        if (-not ($PSCmdlet.ParameterSetName -eq 'ApiCredential')) {
            $ApiCredential = New-ApiCredential `
                -Authorization:$Authorization `
                -Token:$Token `
                -Credential:$Credential
        }

        # Determine the target collection
        $CollectionUri = Use-CollectionUri `
            -CollectionUri $CollectionUri

        # Determine validity of the credential;
        # calling Get-ConnectionData verifies the credential on collection
        # calling Get-Project verifies the credential on project

        if (((-not $SkipValidation.IsPresent) -or ($SkipValidation -eq $false))) {

            if (!$CollectionUri) {
                Write-Warning 'No CollectionUri was provided, skipping validation of the credential.'
            } else {
                try {
                    $null = Get-ConnectionData `
                        -ErrorAction Stop `
                        -ApiCredential $ApiCredential `
                        -CollectionUri $CollectionUri
                } catch {
                    $errMsg = $_.ErrorDetails.Message
                    if (!$errMsg) {
                        $errMsg = $_.Exception.Message
                    }
                    $errMsg = "Given credential was not validated. $($errMsg)"
                    switch ($ErrorActionPreference) {
                        'Continue' { Write-Error $errMsg; return; }
                        'SilentlyContinue' { return; }
                        'Stop' { throw $errMsg }
                        default { throw $errMsg }
                    }
                }
            }
        }

        # Fix up the collection uri for use in dictionary keys
        $CollectionUri = Format-Uri -Uri $CollectionUri

        # Fix up the project for use in dictionary keys
        if ([string]::IsNullOrWhiteSpace($Project)) {
            $Project = [string]::Empty
        }

        # Retrieve the project object for later use
        if (((-not $SkipValidation.IsPresent) -or ($SkipValidation -eq $false))) {
            if ($Project) {
                $projectObject = Get-Project `
                    -CollectionUri $CollectionUri `
                    -ApiCredential $ApiCredential `
                    -Project $Project

                if (!$projectObject) {
                    throw "Provided credentials are not valid for project '$($Project)'"`
                        + " on collection '$($CollectionUri)'."
                }
            }
        }

        # Add the api credential to the global cache

        # Prepare variable for the collection credentials
        [hashtable] $CollectionCredentials = $cache[$CollectionUri]

        # Retrieve the collection credentials
        if (!$CollectionCredentials) {
            # Create the collection credentials if needed
            $CollectionCredentials = @{ }
            $cache[$CollectionUri] = $CollectionCredentials
        }

        # Add the api credential to the collection credentials

        # If Project was provided
        if ($Project) {
            if ($projectObject) {
                # Add for both Project Name and ID
                $CollectionCredentials[$projectObject.id] = $ApiCredential
                $CollectionCredentials[$projectObject.name] = $ApiCredential
            } else {
                # Add for the Project Name only
                $CollectionCredentials[$Project] = $ApiCredential
            }
        }

        # If Project was not provided
        if (!$Project -or $AlsoUseForCollection) {
            # Add as default for Collection
            $CollectionCredentials[[string]::Empty] = $ApiCredential
        }

        # Return the added credential
        if ($PassThru.IsPresent -and ($true -eq $PassThru)) {
            return $ApiCredential
        }
    }
}
