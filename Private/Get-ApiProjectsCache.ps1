function Get-ApiProjectsCache {

    <#
        .SYNOPSIS
            Gets the global ApiProjectsCache.
    #>

    process {
        return $global:ApiProjectsCache
    }
}