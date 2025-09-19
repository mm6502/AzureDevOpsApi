function ConvertTo-ApiProject {

    <#
        .SYNOPSIS
            Gets Project and CollectionUri and creates from an ApiProject object.
            Fills as many properties as possible.

        .PARAMETER Project
            The project to create a connection for.

        .PARAMETER CollectionUri
            The URI of the collection the project belongs to.

        .PARAMETER Patterns
            A list of regex patterns to use to extract the Project and CollectionUri
            in case the Project parameter is an Uri or an actual Project object.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        $Project,

        [AllowNull()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Patterns
    )

    process {

        # Scenarios:
        # 1A: No CollectionUri, No Project
        # 1B: No CollectionUri,    Project is Object
        # 1C: No CollectionUri,    Project is Uri
        # 1D: No CollectionUri,    Project is ID
        # 1E: No CollectionUri,    Project is Name
        # 2A: CollectionUri   , No Project
        # 2B: CollectionUri   ,    Project is Object
        # 2C: CollectionUri   ,    Project is Uri
        # 2D: CollectionUri   ,    Project is ID
        # 2E: CollectionUri   ,    Project is Name
        # When Project is an Object or Uri, we can ignore the CollectionUri parameter,
        # because Project is more specific.

        # 1A,2A: If $Project is null, try to get it from $global:AzureDevOpsApi_Project
        if (!$Project) {
            $Project = Use-Project -Value $Project
        }

        # Now we have something in $Project, determine what we have
        $ProjectUri = $ProjectUriCandidate = $ProjectId = $ProjectName = $null

        if ((($Project -is [string]) -or ($Project -is [Uri])) -and ($Project | Test-WebAddress)) {
            # 1C,2C: If $Project is an Uri
            $ProjectUriCandidate = $Project
        } elseif ($Project -is [PSCustomObject]) {
            # 1B,2B: If $Project is an object, get an Uri, ID, and Name from it
            $null = switch ($Project) {
                { $_._links.self.href } { $ProjectUriCandidate = $_._links.self.href; }
                { $_.url } { $ProjectUriCandidate = $_.url; }
                { $_.id } { $ProjectId = $_.id; }
                { $_.name } { $ProjectName = $_.name; }
            }
        }

        # Determine the CollectionUri (and Project) from the ProjectUriCandidate
        if ($ProjectUriCandidate) {
            # 1C,2C: If $Project is an Uri
            # It may or may not be an Uri to a project, but we don't know.
            $splittedUri = Split-ApiUri -Uri $ProjectUriCandidate -Patterns $Patterns
            if ($splittedUri) {
                $CollectionUri = Format-Uri -Uri $splittedUri.collection
                $Project = $splittedUri.project
            }
        } elseif (!$CollectionUri) {
            # 1*: If No CollectionUri, try to get it from $global:AzureDevOpsApi_CollectionUri
            $CollectionUri = Use-CollectionUri
        }

        if (!$ProjectId) {
            # 1D,2D: If $Project is an ID
            $id = [Guid]::Empty
            if ([Guid]::TryParse([string] $Project, [ref] $id)) {
                $ProjectId = $id

                # If $ProjectUri is null at this point, try to construct it
                # from $CollectionUri and $ProjectId
                if ($CollectionUri) {
                    $ProjectUri = Join-Uri `
                        -Base $CollectionUri `
                        -Relative '_apis/projects', $ProjectId `
                        -NoTrailingSlash
                }
            }

            # 1E,2E: If $Project is a Name
            if ($null -eq $ProjectId) {
                $ProjectName = $Project
            }
        }

        # Construct the object
        $result = New-ApiProject `
            -CollectionUri $CollectionUri `
            -ProjectUri $ProjectUri `
            -ProjectId $ProjectId `
            -ProjectName $ProjectName

        # Return the result
        return $result
    }
}