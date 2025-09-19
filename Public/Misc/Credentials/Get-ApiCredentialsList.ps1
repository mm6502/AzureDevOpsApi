function Get-ApiCredentialsList {

    <#
        .SYNOPSIS
            Returns a list of known API credentials registered by Add-ApiCredential or Set-ApiVariables.

        .DESCRIPTION
            The Get-ApiCredentialsList function returns a list of API credentials registered by Add-ApiCredential or
            Set-ApiVariables.
    #>

    [CmdletBinding()]
    param()

    process {

        # Enumerate all Collections in $global:ApiCredentialsCache
        $global:ApiCredentialsCache.GetEnumerator() | ForEach-Object {
            $CollectionUri = $_.Key
            $CollectionCredentials = $_.Value
            # Enumerate all Credentials for given Collection
            $CollectionCredentials.GetEnumerator() | ForEach-Object {
                $Project = $_.Key
                $ApiCredential = $_.Value
                $ApiCredential `
                | Select-Object -Property @(
                    @{ Name = 'CollectionUri'; Expression = { $CollectionUri } }
                    @{ Name = 'Project'; Expression = { $Project } }
                    'Authorization'
                    @{ Name = 'UserName'; Expression = { $_.Credential.UserName } }
                    @{ Name = 'ApiCredential'; Expression = { $ApiCredential } }
                )
            }
        }

    }
}

Set-Alias -Name Get-ApiCredential -Value Get-ApiCredentialsList
