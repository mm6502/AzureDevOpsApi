function Show-ApiCredentialsList {

    <#
        .SYNOPSIS
            Displays a list of API credentials.

        .DESCRIPTION
            The Show-ApiCredentialsList function displays a list of registered API credentials by calling
            Add-ApiCredential or Set-ApiVariables.
    #>

    [CmdletBinding()]
    param()

    process {
        Get-ApiCredentialsList `
        | Sort-Object -Property CollectionUri, Project, Authorization, UserName `
        | Format-Table -AutoSize -Property CollectionUri, Project, Authorization, UserName
    }
}

Set-Alias -Name Show-ApiCredential -Value Show-ApiCredentialsList
