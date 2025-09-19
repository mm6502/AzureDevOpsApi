function Split-ApiUri {

    <#
        .SYNOPSIS
            Splits the given URI of an Azure DevOps collection into the collection URI and the project name.

        .PARAMETER Uri
            The Uri of some Azure DevOps collection related object.
            The Uri is formatted with Format-Uri. before being processed.

        .PARAMETER Patterns
            The regex patterns to use for splitting the URI.
            Captured groups are returned as properties of the output object.

        .PARAMETER AsHashTable
            If set, the output will be a HashTable instead of a PSCustomObject.

        .PARAMETER UseOnlyProvidedPatterns
            If set, only the provided patterns will be used for splitting the URI.

        .OUTPUTS
            A hashtable or PSCustomObject with the captured groups as keys.
    #>

    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Uri,

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Patterns,

        [switch] $AsHashTable,

        [Alias('Only','OnlyProvided','OnlyPatterns','OnlyProvidedPatterns')]
        [switch] $UseOnlyProvidedPatterns
    )

    begin {

        if (!$Patterns) {
            $Patterns = @()
        }

        # Add the default patterns if none were given.
        # Order from more specific to least specific.
        if (!$UseOnlyProvidedPatterns.IsPresent -or ($true -ne $UseOnlyProvidedPatterns)) {
            $Patterns = $Patterns + @(
                # VALID https://dev-tfs/tfs/internal_projects/_apis/tfvc/changesets/182559
                # VALID https://dev-tfs/tfs/internal_projects/FS_TKD-TARIC/_apis/tfvc/changesets/182559

                # VALID https://dev-tfs/tfs/internal_projects/_apis/tfvc/changesets/182559/workitems
                # INVALID https://dev-tfs/tfs/internal_projects/FS_TKD-TARIC/_apis/tfvc/changesets/182559/workitems
                '^(?<collection>.*)/_apis/tfvc/changesets/(?:\d+)/workitems[?]?(?:.*)?$'

                # https://dev.azure.com/{organization}/{project}/{team}/_apis/work/boards/{board}/charts/{name}?api-version=5.0
                '^(?<collection>.*)/(?<project>.*)/(?<team>.*)/_apis/work/boards/(?:.*)?$'

                # https://dev.azure.com/{organization}/_apis/projects/{project}?api-version=5.0
                '^(?<collection>.*)/_apis/projects/(?<project>[^/\?]+)(?:.*)?$'

                # https://dev-tfs/tfs/internal_projects/{project}/_apis/...
                '^(?<collection>.*)/(?<project>.*)/_apis/.*$'

                # https://dev.azure.com/{organization}/{project}/_git/...
                '^(?<collection>.*)/(?<project>.*)/_git/.*$'

                # https://dev.azure.com/{organization}/{project}/
                '^(?<collection>.*)/(?<project>.*)/(?:_.*)?$'
            )
        }
    }

    process {

        # Format the Uri to ensure it alwasys has a trailing slash
        $Uri = Format-Uri -Uri $Uri

        # Loop through the patterns to find a match
        foreach ($pattern in $Patterns) {

            # Match the Uri against the pattern
            if ($Uri -notmatch $pattern) {
                # No match, try the next pattern
                continue
            }

            # Match found, return the captured groups
            Write-Verbose "Split-ApiUri: Found using pattern:`n  $($pattern)`n  $($Uri)"

            # Construct the hashtable for result
            $result = @{}
            foreach ($key in $Matches.Keys) {

                # The 0 key is the entire match, so add id as the Uri
                if ($key -eq '0') {
                    $result['Uri'] = $Matches[$key]
                    continue
                }

                # Add the captured group as key
                $result[$key] = $Matches[$key]
            }

            # Return as a hashtable or PSCustomObject
            if ($AsHashTable.IsPresent -and ($true -eq $AsHashTable)) {
                return $result
            } else {
                return [PSCustomObject] $result
            }
        }
    }
}
