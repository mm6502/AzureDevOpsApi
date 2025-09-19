function Add-ApiProject {

    <#
        .SYNOPSIS
            Adds a project to the global cache.

        .DESCRIPTION
            Adds a project to the global cache.
            This is used to speed up the lookup of projects.

            The cache is a dictionary of project collections.
            Each project collection is a dictionary of projects.

            Project is added to the cache under keys:
            - $ProjectUri  = $Project.url
            - $ProjectId = $Project.id
            - $ProjectIdBaseUri = $CollectionUri + '/' + $Project.id
            - $ProjectName = $Project.name
            - $ProjectNameBaseUri = $CollectionUri + '/' + $Project.name

        .PARAMETER Project
            The project object to add to the cache.

        .PARAMETER CollectionUri
            The URI of the project collection to add the project to.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $Project,

        [Parameter(Mandatory)]
        $CollectionUri
    )

    begin {
        $cache = Get-ApiProjectsCache
    }

    process {

        # Set the cache item to null to indicate that we haven't found the project in the cache yet
        $cacheItem = $null

        # Construct a new cache item
        # Calculates the base Uris of the project scoped apis
        $newCacheItem = New-ApiProject `
            -CollectionUri:$CollectionUri `
            -ProjectUri:$Project.url `
            -ProjectId:$Project.id `
            -ProjectName:$Project.name `
            -Verified:$true

        # Check if the project is already in the cache at the root level (by absolute Uri)
        if (-not $cacheItem) {
            if ($newCacheItem.ProjectUri) {
                $cacheItem = $cache[$newCacheItem.ProjectUri]
            }
        }
        if (-not $cacheItem) {
            if ($newCacheItem.ProjectIdBaseUri) {
                $cacheItem = $cache[$newCacheItem.ProjectIdBaseUri]
            }
        }
        if (-not $cacheItem) {
            if ($newCacheItem.ProjectNameBaseUri) {
                $cacheItem = $cache[$newCacheItem.ProjectNameBaseUri]
            }
        }

        # Check if the collection URI exists in the cache, create it if not
        if ($CollectionUri) {
            $CollectionUri = Format-Uri -Uri $CollectionUri
            $collectionCache = $cache[$CollectionUri]
            if (-not $collectionCache) {
                $collectionCache = $cache[$CollectionUri] = @{ }
            }
        }

        # Check if the project exists in the cache at the project collection level
        if (-not $cacheItem) {
            if ($newCacheItem.ProjectIdBaseUri) {
                $cacheItem = $collectionCache[$newCacheItem.ProjectIdBaseUri]
            }
        }
        if (-not $cacheItem) {
            if ($newCacheItem.ProjectNameBaseUri) {
                $cacheItem = $collectionCache[$newCacheItem.ProjectNameBaseUri]
            }
        }
        if (-not $cacheItem) {
            if ($newCacheItem.ProjectUri) {
                $cacheItem = $collectionCache[$newCacheItem.ProjectUri]
            }
        }
        if (-not $cacheItem) {
            if ($newCacheItem.ProjectId) {
                $cacheItem = $collectionCache[$newCacheItem.ProjectId]
            }
        }

        if (-not $cacheItem) {
            $cacheItem = $newCacheItem
        }

        # Add the project details to the cache at the root level
        if ($newCacheItem.ProjectIdBaseUri) {
            if (-not $cache[$newCacheItem.ProjectIdBaseUri]) {
                $cache[$newCacheItem.ProjectIdBaseUri] = $cacheItem
            }
        }
        if ($newCacheItem.ProjectNameBaseUri) {
            if (-not $cache[$newCacheItem.ProjectNameBaseUri]) {
                $cache[$newCacheItem.ProjectNameBaseUri] = $cacheItem
            }
        }
        if ($newCacheItem.ProjectUri) {
            if (-not $cache[$newCacheItem.ProjectUri]) {
                $cache[$newCacheItem.ProjectUri] = $cacheItem
            }
        }

        # Add the project details to the cache at the collection level
        if ($newCacheItem.ProjectIdBaseUri) {
            if (-not $collectionCache[$newCacheItem.ProjectIdBaseUri]) {
                $collectionCache[$newCacheItem.ProjectIdBaseUri] = $cacheItem
            }
        }
        if ($newCacheItem.ProjectNameBaseUri) {
            if (-not $collectionCache[$newCacheItem.ProjectNameBaseUri]) {
                $collectionCache[$newCacheItem.ProjectNameBaseUri] = $cacheItem
            }
        }
        if ($newCacheItem.ProjectUri) {
            if (-not $collectionCache[$newCacheItem.ProjectUri]) {
                $collectionCache[$newCacheItem.ProjectUri] = $cacheItem
            }
        }
        if ($newCacheItem.ProjectId) {
            if (-not $collectionCache[$newCacheItem.ProjectId]) {
                $collectionCache[$newCacheItem.ProjectId] = $cacheItem
            }
        }

        # Return the project
        return $Project
    }
}
