function New-ApiCredential {

    <#
        .SYNOPSIS
            Creates an object that contains credentials for the Azure DevOps API.

        .DESCRIPTION
            This function is used to create an object that contains credentials for the Azure DevOps API.

        .PARAMETER Token
            The token used to authenticate to the Azure DevOps API.

        .PARAMETER Credential
            The credential used to authenticate to the Azure DevOps API.

        .PARAMETER Authorization
            The authorization used to authenticate to the Azure DevOps API.
            Possible values are:
            - $null or '' - autodetect the type of authorization, based on the value of the $Token and $Credential parameters.
            - 'Default' - Use the default network credentials.
            - 'Basic' - Use given $Credential.
            - 'PAT' - Use a Personal Access Token.
            - 'Bearer' - Use a Bearer token.
            - 'OAuth' - Use a OAuth token.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCredential')]
    param(
        [ValidateSet($null, '', 'Default', 'Basic', 'PersonalAccessToken', 'PAT', 'Bearer', 'OAuth')]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Authorization,

        [AllowNull()]
        $Token,

        [AllowNull()]
        [PSCredential] $Credential
    )

    process {

        # If both Token and Credential are specified, throw an error
        if ($Token -and $Credential) {
            throw [System.ArgumentException]::new('Token and Credential cannot be specified at the same time.')
        }

        # If Token is specified
        if ($Token) {

            if (!$Authorization) {
                # Authorization must be specified when using Token
                throw [System.ArgumentException]::new(
                    'Authorization must be specified when using Token.'
                )
            }

            # If Token is given as plain text, convert it to SecureString
            if ($Token -is [string]) {
                $Token = ConvertTo-SecureString -String $Token -Force -AsPlainText
            }

            return [PSCustomObject] @{
                PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCredential
                Authorization = $Authorization
                Token         = $Token
            }
        }

        # Tokens are not supported for Basic authorization
        if ($Authorization -in @('PAT', 'PersonalAccessToken', 'Bearer', 'OAuth')) {
            throw [System.ArgumentException]::new(
                "Token must be specified when using authorization '$($Authorization)'."
            )
        }

        # If Authorization is not specified, autodetect it
        if (!$Authorization) {
            if (!$Credential) {
                $Authorization = 'Default'
            } else {
                $Authorization = 'Basic'
            }
        }

        # Basic authorization requires a credential
        if ($Authorization -eq 'Basic' -and !$Credential) {
            throw 'Credential must be specified when using Basic authorization.'
        }

        # Use Default network credentials
        if ($Authorization -eq 'Default') {
            return [PSCustomObject] @{
                PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCredential
                Authorization = $Authorization
            }
        }

        # Use given credential with Basic authorization
        return [PSCustomObject] @{
            PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCredential
            Authorization = $Authorization
            Credential    = $Credential
        }
    }
}
