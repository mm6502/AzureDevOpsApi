function Resolve-ApiProject {
    <#
        .SYNOPSIS
            Finds a project in the global cache.

        .DESCRIPTION
            Finds a project in the global cache based on the provided parameters.
            The function supports finding a project by any combination of the following parameters:
            - ProjectUri
            - CollectionUri + ProjectUri
            - CollectionUri + ProjectId
            - CollectionUri + ProjectName

        .PARAMETER CollectionUri
            The URI of the project collection.

        .PARAMETER Project
            The project can be an actual Project object, a string that contains the URI of the project,
            Name or Identifier of the project.

        .PARAMETER Patterns
            A list of additional patterns to use to extract the Project and CollectionUri
            when the Project parameter is an Uri.

        .EXAMPLE
            Resolve-ApiProject -CollectionUri 'https://dev.azure.com/myorg' -Project 'MyProject'
            Finds a project with the name 'MyProject' in the collection 'https://dev.azure.com/myorg'.

        .EXAMPLE
            Resolve-ApiProject -CollectionUri 'https://dev.azure.com/myorg' -Project 'ab1c2d3e-4f56-7890-abcd-ef0123456789'
            Finds a project with the ID 'ab1c2d3e-4f56-7890-abcd-ef0123456789' in the collection 'https://dev.azure.com/myorg'.

        .EXAMPLE
            Resolve-ApiProject -ProjectUri 'https://dev.azure.com/myorg/MyProject'
            Finds a project with the URI 'https://dev.azure.com/myorg/MyProject'.
    #>

    [CmdletBinding()]
    param(
        $Project,
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Patterns
    )

    begin {
        $cache = Get-ApiProjectsCache
    }

    process {

        # Convert $Project to a Project object
        $candidate = ConvertTo-ApiProject `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -Patterns $Patterns

        # Try to find it in cache ba various properties
        $cacheItem = $null
        do {
            # If $Project is an Uri, try to find it in the ApiProjectsCache
            if ($candidate.ProjectUri) {
                # If it was actual ProjectUri, return it
                $cacheItem = $cache[$candidate.ProjectUri]
                if ($cacheItem) {
                    continue
                }
            }

            # If $CollectionUri is not known at this point, fail
            if (!$candidate.CollectionUri) {
                $candidate.CollectionUri = [string]::Empty
            }

            # Get the collection cache
            # If the collection cache does not exist, fail
            if ($null -ne $candidate.CollectionUri) {
                $collectionCache = $cache[$candidate.CollectionUri]
            }

            if (!$collectionCache) {
                # fail, return the unverified project object
                continue
            }

            # Get the project from cache
            if ($candidate.ProjectUri) {
                $cacheItem = $collectionCache[$candidate.ProjectUri]
                if ($cacheItem) {
                    continue
                }
            }

            if ($candidate.ProjectBaseUri) {
                $cacheItem = $collectionCache[$candidate.ProjectBaseUri]
                if ($cacheItem) {
                    continue
                }
            }

            if ($candidate.ProjectNameBaseUri) {
                $cacheItem = $collectionCache[$candidate.ProjectNameBaseUri]
                if ($cacheItem) {
                    continue
                }
            }

            if ($candidate.ProjectId) {
                $cacheItem = $collectionCache[$candidate.ProjectId]
                if ($cacheItem) {
                    continue
                }
            }

            if ($candidate.ProjectName) {
                $cacheItem = $collectionCache[$candidate.ProjectName]
                if ($cacheItem) {
                    continue
                }
            }
        } while ($false)

        # If we found it, return it
        if ($cacheItem) {
            return $cacheItem
        }

        # fail, return the unverified project object
        return $candidate
    }
}
