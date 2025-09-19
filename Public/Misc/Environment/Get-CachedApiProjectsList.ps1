function Get-CachedApiProjectsList {
    <#
        .SYNOPSIS
            Returns a list of projects currently cached in memory.

        .DESCRIPTION
            This function returns a list of projects that have been cached.
            Projects are cached when you call functions like Get-Project or Get-ProjectsList.
    #>

    process {

        $cache = Get-ApiProjectsCache

        if (!$cache) {
            return
        }

        $cache.GetEnumerator() `
        | ForEach-Object {
            $project = $_.Value

            # Only return actual project objects (not collection entries)
            if ($project.ProjectName -and $project.ProjectId) {
                [PSCustomObject] @{
                    CollectionUri = $project.CollectionUri
                    ProjectName   = $project.ProjectName
                    ProjectId     = $project.ProjectId
                    ProjectUri    = $project.ProjectUri
                }
            }
        } `
        | Sort-Object CollectionUri, ProjectName `
        | Select-Object -Unique ProjectId, ProjectName, CollectionUri, ProjectUri
    }
}
