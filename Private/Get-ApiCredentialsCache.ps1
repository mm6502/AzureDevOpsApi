function Get-ApiCredentialsCache {

    <#
        .SYNOPSIS
            Gets the global ApiCredentialsCache.
    #>

    process {
        return $global:ApiCredentialsCache
    }
}