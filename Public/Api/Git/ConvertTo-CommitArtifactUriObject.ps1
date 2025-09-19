function ConvertTo-CommitArtifactUriObject {

    <#
        .SYNOPSIS
            Converts commit's uri to Artifact Uri usable for ArtifactUriQuery.
            Returns CollectionUri and ArtifactUri tuples.

        .PARAMETER CommitUri
            Uri of the commit from the API.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('Uri','InputObject')]
        $CommitUri
    )

    begin {
        $regex = '^(?<collection>.+)\/(?<project>.+)\/_apis\/git\/repositories\/(?<repository>.+)\/commits\/(?<commit>[^\/]+)\/(?:.*)?$'
    }

    # Example:
    # Commit URI is:
    # ```
    # https://dev-tfs/tfs/internal_projects/890669f3-5144-4962-a81f-a96feb160a10/_apis/git/repositories/c2b7419e-9006-4d2c-9f7e-e9f29a89adce/commits/548ded02bb9b602833ddefe26347e99e71ef434d
    # collection ------------------------->/
    # project -----------------------------/<---------------------------------->/
    # repository --------------------------------------------------------------------------------------/<---------------------------------->/
    # commit ---------------------------------------------------------------------------------------------------------------------------------------/<-------------------------------------->
    # ```
    # Artifact URI is:
    # ```
    # vstfs:///Git/Commit/3065bb47-8344-4370-982a-5183abf197fa%2F649107bd-ab35-4192-8584-601f64172f80%2F548ded02bb9b602833ddefe26347e99e71ef434d
    # project ------------<---------------------------------->%2F
    # repository ---------------------------------------------%2F<---------------------------------->%2F
    # commit ----------------------------------------------------------------------------------------%2F<-------------------------------------->
    # ```

    process {

        $CommitUri | ForEach-Object {

            $item = $_

            # Skip empty items
            if (!$item) {
                return
            }

            # Match the Uri to the regex
            $parts = Split-ApiUri -Uri $item -Pattern $regex -UseOnlyProvidedPatterns

            # If not matched, skip
            if (!$parts) {
                return
            }

            # Construct the Artifact Uri object:
            $result = [PSCustomObject] @{
                CollectionUri = $parts.collection
                ProjectId     = $parts.project
                RepositoryId  = $parts.repository
                CommitId      = $parts.commit
                ArtifactUri   = "vstfs:///Git/Commit/$($parts.project)%2F$($parts.repository)%2F$($parts.commit)"
                Uri           = $CommitUri
            }

            return $result
        }
    }
}
