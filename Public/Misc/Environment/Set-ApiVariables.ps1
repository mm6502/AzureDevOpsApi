function Set-ApiVariables {

    <#
        .SYNOPSIS
            Set commonly used parameters for Azure DevOps API calls:
            $global:AzureDevOpsApi_DefaultFromDate
            $global:AzureDevOpsApi_ApiVersion
            $global:AzureDevOpsApi_CollectionUri
            $global:AzureDevOpsApi_Project
            $global:AzureDevOpsApi_Token

        .PARAMETER ApiVersion
            Version of API to use. Default is ''5.0''.

        .PARAMETER CollectionUri
            Azure DevOps Project collection URI.

        .PARAMETER Project
            The name or identifier of a project in given $CollectionUri.

        .PARAMETER ApiCredential
            The credential to use for Azure DevOps API calls. If not provided, the
            result of New-ApiCredential will be used (default netowrk credentials on Windows).

        .PARAMETER Authorization
            Obsolete. Only for compatibility with v0.0.*.
            Authorization type to use.

            Possible Values are:
            - `Default` - Default authorization (uses -UseDefaultCredentials)
            - `PersonalAccessToken` - Personal Access Token
            - `PAT` - Personal Access Token (alias for PersonalAccessToken)
            - `Bearer` - Bearer Token
            - `Basic` - Basic authorization type

        .PARAMETER Token
            Obsolete. Only for compatibility with v0.0.*.
            The authorization token for calling API in given $Collection,
            when Authorization is set to `Bearer`, `PAT` or `PersonalAccessToken`.

        .PARAMETER Credential
            Obsolete. Only for compatibility with v0.0.*.
            The credential to use for calling API in given $Collection,
            when Authorization is set to `Basic`.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        $ApiVersion = '5.0',

        [Alias('Collection')]
        $CollectionUri,
        $Project,

        [Parameter(ParameterSetName = 'Default')]
        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        [Parameter(ParameterSetName = 'OldStyleToken')]
        [Parameter(ParameterSetName = 'OldStyleCredential')]
        [ValidateSet('', 'Default', 'PersonalAccessToken', 'PAT', 'Basic', 'Bearer', 'OAuth')]
        [AllowNull()]
        [AllowEmptyString()]
        $Authorization = 'Default',

        [Parameter(ParameterSetName = 'OldStyleToken')]
        $Token,

        [Parameter(ParameterSetName = 'OldStyleCredential')]
        [PSCredential] $Credential
    )

    process {

        Set-Variable `
            -Scope Global `
            -Name 'AzureDevOpsApi_DefaultFromDate' `
            -Value ([DateTime]'2000-01-01Z') `
            -Description 'Default value for FromDate in various functions.'

        if ($ApiVersion) {
            Set-Variable `
                -Scope Global `
                -Name 'AzureDevOpsApi_ApiVersion' `
                -Value $ApiVersion `
                -Description 'Version of API to use. Default is ''5.0''.'
        }

        if ($CollectionUri) {
            $CollectionUri = Format-Uri -Uri $CollectionUri
            Set-Variable -Scope Global `
                -Name 'AzureDevOpsApi_CollectionUri' `
                -Value $CollectionUri `
                -Description 'Azure DevOps Project collection URI.'
        }

        if ($Project) {
            Set-Variable `
                -Scope Global `
                -Name 'AzureDevOpsApi_Project' `
                -Value $Project `
                -Description 'Project name or identifier in given CollectionUri.'
        }

        # Credentials are optional, but if they are provided,
        # CollectionUri must be provided as well
        if (!$CollectionUri) {
            $badinput = (
                ($ApiCredential -or $Token -or $Credential) `
                -or ($Authorization -and ($Authorization -ne 'Default'))
            )
            if ($badinput) {
                $msg = 'CollectionUri was not provided, but Credential, Authorization, ' `
                    + 'or Token was. These will be ignored.'
                Write-Warning $msg
            }
        }

        # If CollectionUri was provided, register it
        if ($CollectionUri) {
            $null = Add-ApiCollection `
                -CollectionUri:$CollectionUri `
                -ApiVersion:$ApiVersion

            # Handle Old Style Authorization
            if ($PSCmdlet.ParameterSetName -ne 'Default') {
                $ApiCredential = New-ApiCredential `
                    -Authorization:$Authorization `
                    -Token:$Token `
                    -Credential:$Credential
            }

            # If ApiCredential was provided, register it with given CollectionUri
            # and Project, if provided
            if ($ApiCredential) {
                $params_Add_ApiCredential = @{
                    CollectionUri = $CollectionUri
                    ApiCredential = $ApiCredential
                }
                if ($Project) {
                    $params_Add_ApiCredential['Project'] = $Project
                    $params_Add_ApiCredential['ForCollection'] = $true
                }
                $null = Add-ApiCredential @params_Add_ApiCredential
            }
        }
    }
}
