function Join-Uri {

    <#
        .SYNOPSIS
            Joins the given base Uri with the given relative Uri.

        .PARAMETER BaseUri
            Base Uri to append to.
            Example: https://dev.azure.com/MyOrganization/
            Example: https://dev.azure.com/MyOrganization

        .PARAMETER RelativeUri
            Relative Uri to append to the base Uri. May be a collection of relative Uris.
            Example: _apis/projects
            Example: /_apis/projects
            Example: _apis, projects

        .PARAMETER NoTrailingSlash
            If specified, the trailing slash is removed from the Uri.

        .PARAMETER Parameters
            An optional hashtable or PSCustomObject of key-value pairs representing the query parameters to add or set.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('CollectionUri')]
        $BaseUri,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        $RelativeUri,

        [Alias('RemoveTrailingSlash', 'LastSegment')]
        [switch] $NoTrailingSlash,

        [AllowNull()]
        $Parameters
    )

    process {
        # If no relative Uri is given, return the base Uri
        if (!$RelativeUri) {
            return Format-Uri -Uri $BaseUri -Parameters $Parameters -NoTrailingSlash:$NoTrailingSlash
        }

        # If RelativeUri is actually absolute, just return it
        # Reasoning:
        # Given Collection Uri
        # https://dev-tfs/tfs/internal_projects/
        # and Project Uri
        # https://dev-tfs/tfs/internal_projects/_apis/projects/SIZP_KSED
        # It makes more sense to just return the Project Uri
        if ([Uri]::IsWellFormedUriString($RelativeUri, [UriKind]::Absolute)) {
            return Format-Uri -Uri $RelativeUri -Parameters $Parameters -NoTrailingSlash:$NoTrailingSlash
        }

        # Format the base
        $BaseUri = Format-Uri -Uri $BaseUri

        # Agregate the result Uri
        $Uri = $BaseUri
        foreach ($item in $RelativeUri) {
            $Uri = [Uri]::new([Uri]::new($Uri), $item, $true)
            $Uri = Format-Uri -Uri $Uri
        }

        # Return the formatted joined Uri
        return Format-Uri -Uri $Uri -Parameters $Parameters -NoTrailingSlash:$NoTrailingSlash
    }
}
