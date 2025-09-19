function  Get-Changeset {
    <#
        .SYNOPSIS
            Returns a changeset.

        .DESCRIPTION
            Returns a changeset.

        .PARAMETER Changeset
            Pull request to load. Valid inputs:
            - Changeset url
              'https://dev-tfs/tfs/internal_projects/_apis/tfvc/changesets/182559'
              'https://dev-tfs/tfs/internal_projects/FS_TKD-TARIC/_apis/tfvc/changesets/182559'
              'https://dev-tfs/tfs/internal_projects/c0b54941-d244-45e8-8673-1eb18fc2abc9/_apis/tfvc/changesets/182559'
            - Changeset id, must specify CollectionUri, otherwise default will be used
              182559

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            Can be ommitted if $CollectionUri was previously accessed via this API.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .EXAMPLE
            # All items represent the same Changeset
            # Assuming project was accessed previously
            Get-Changeset -Changeset @(
              'https://dev-tfs/tfs/internal_projects/_apis/tfvc/changesets/182559'
              'https://dev-tfs/tfs/internal_projects/FS_TKD-TARIC/_apis/tfvc/changesets/182559'
              'https://dev-tfs/tfs/internal_projects/c0b54941-d244-45e8-8673-1eb18fc2abc9/_apis/tfvc/changesets/182559'
            )
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [AllowEmptyString()]
        $Changeset,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project
    )

    process {

        if (!$Changeset) {
            return
        }

        # Possible values:
        # A/ Changeset Uri
        # B/ ChangesetID, CollectionUri

        $Changeset | ForEach-Object {

            # If we already have a valid changeset object
            if ($_.changesetId -and $_.url) {
                # Just return it
                return $_
            }

            # A/ Changeset Uri
            # {CollectionUri}/{Project}/
            # _apis/tfvc/changesets/{ChangesetId}
            # _apis/tfvc/changesets/182559
            #
            # Following are valid too, but we can not determine between the project from collection
            # in case of
            # 'https://dev-tfs/tfs/internal_projects/_apis/tfvc/changesets/182559'
            # {CollectionUri}/
            # _apis/tfvc/changesets/{ChangesetId}
            # _apis/tfvc/changesets/182559

            # Try for url
            $maybeUrl = Use-Value -ValueA $_.url -ValueB $_

            # If it is an url, try to load the pull request
            if ($maybeUrl | Test-WebAddress) {

                # Get the project connection
                $projectConnection = Get-ApiProjectConnection `
                    -Project $maybeUrl `
                    -CollectionUri $CollectionUri `
                    -AllowFallback

                # Make the call
                $response = Invoke-Api `
                    -Uri $maybeUrl `
                    -ApiCredential $projectConnection.ApiCredential `
                    -ApiVersion $projectConnection.ApiVersion `

                if ($response) {
                    $response
                }

                return
            }

            # B/ ChangesetID, CollectionUri
            # Get the project connection
            $projectConnection = Get-ApiProjectConnection `
                -Project $Project `
                -CollectionUri $CollectionUri

            # Get the pull request uri
            $uri = Join-Uri `
                -Base $projectConnection.CollectionUri `
                -Relative  '_apis/tfvc/changesets', $_ `
                -NoTrailingSlash

            # Make the call
            $response = Invoke-Api `
                -Uri $uri `
                -ApiCredential $projectConnection.ApiCredential `
                -ApiVersion $projectConnection.ApiVersion

            if (!$response) {
                return
            }

            $response `
            | Add-Member -MemberType NoteProperty -Name 'Project' -Value $connection.ProjectBaseUri -PassThru
        }
    }
}
