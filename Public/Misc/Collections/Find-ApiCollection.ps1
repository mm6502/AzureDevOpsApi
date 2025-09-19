function Find-ApiCollection {

    <#
        .SYNOPSIS
            Finds an ApiCollection in the cache by given Uri.

        .DESCRIPTION
            Finds an ApiCollection in the cache by given Uri.

        .PARAMETER Uri
            Uri to get the ApiCollection for.
    #>

    [CmdletBinding()]
    param(
        [Alias('CollectionUri')]
        [string] $Uri
    )

    begin {
        $cache = Get-ApiCollectionsCache
    }

    process {

        if (!$Uri) {
            $Uri = [string]::Empty
        }

        # Try to find a cached collection the given Uri starts with;
        # usable for normal operation:
        # - $Uri          : 'https://dev-tfs/tfs/internal_projects/_apis/projects/SIZP_KSED'
        # - $CollectionUri: 'https://dev-tfs/tfs/internal_projects/'
        $candidate = $cache.Keys `
        | Where-Object { $Uri.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) } `
        | Select-Object -First 1

        if ($null -ne $candidate) {
            $item = $cache[$candidate]
            return New-ApiCollection `
                -CollectionUri $item.CollectionUri `
                -ApiVersion $item.ApiVersion
        }

        # Try to find a cached collection which starts with given Uri;
        # usable for defaulting to registered collections:
        # - $Uri          : 'https://dev-tfs'
        # - $CollectionUri: 'https://dev-tfs/tfs/internal_projects/'
        $candidate = $cache.Keys `
        | Where-Object { $_.StartsWith($Uri, [System.StringComparison]::OrdinalIgnoreCase) } `
        | Select-Object -First 1

        if ($null -ne $candidate) {
            $item = $cache[$candidate]
            return New-ApiCollection `
                -CollectionUri $item.CollectionUri `
                -ApiVersion $item.ApiVersion
        }

        # Try the defaults set in global variables
        $collectionUri = Use-CollectionUri -Uri $Uri

        # Try the defaults set in global variables
        $apiVersion = Use-ApiVersion

        # Just return the given Uri
        Write-Verbose "Could not find collection for given Uri: $($Uri)"

        return New-ApiCollection `
            -CollectionUri $collectionUri `
            -ApiVersion $apiVersion
    }
}
