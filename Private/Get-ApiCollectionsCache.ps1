function Get-ApiCollectionsCache {

    <#
        .SYNOPSIS
            Gets the global ApiCollectionsCache.
    #>

    process {
        return $global:ApiCollectionsCache
    }
}