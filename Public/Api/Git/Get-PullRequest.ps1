function  Get-PullRequest {
    <#
        .SYNOPSIS
            Returns a pull request.

        .DESCRIPTION
            Returns a pull request.

        .PARAMETER PullRequest
            Pull request to load. Valid inputs:
            - Pull request artifact uri
              'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357'
            - Pull request url
              'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/pullrequests/8357'
              'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/pullrequests/8357'
              'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo/pullrequests/8357'
              'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed/pullrequests/8357'
            - Pull request id, must specify CollectionUri, otherwise default will be used
              8357

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            Can be ommitted if $CollectionUri was previously accessed via this API.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            Can be ommitted if $Project was previously accessed via this API (will be extracted from the $ArtifactUri).
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .EXAMPLE
            # All items represent the same PullRequest
            # Assuming project was accessed previously
            Get-PullRequest -PullRequest @(
                'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357'
                'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/pullrequests/8357'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/pullrequests/8357'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo/pullrequests/8357'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed/pullrequests/8357'
            )

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [AllowEmptyString()]
        $PullRequest,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project
    )

    process {

        if (!$PullRequest) {
            return
        }

        # Possible values:
        # A/ PullRequest ArtifactUri
        # B/ PullRequest Uri
        # C/ PullRequestID, CollectionUri

        $PullRequest | ForEach-Object {

            # If we already have a valid pull request object
            if ($_.artifactId -like 'vstfs:///Git/PullRequestId/*') {
                # Just return it
                return $_
            }

            # A/ PullRequest ArtifactUri
            if ($_ -like 'vstfs:///Git/PullRequestId/*') {

                # We need to extract ProjectId and PullRequestId from the ArtifactUri
                if ($_ -notmatch '^vstfs:///Git/PullRequestId/(?<ProjectId>.+?)%2f.*%2f(?<PullRequestId>.+)$') {
                    return
                }

                # Get the project id and pull request id from the artifact uri
                $currentProject = $Matches['ProjectId']
                $currentPullRequestId = $Matches['PullRequestId']

                # Get the project connection
                $projectConnection = Get-ApiProjectConnection `
                    -Project $currentProject `
                    -CollectionUri $CollectionUri

                # Get the pull request uri
                $uri = Join-Uri `
                    -Base $projectConnection.CollectionUri `
                    -Relative  '_apis/git/pullRequests', $currentPullRequestId `
                    -NoTrailingSlash

                # Make the call
                $response = Invoke-Api `
                    -Uri $uri `
                    -ApiCredential $projectConnection.ApiCredential `
                    -ApiVersion $projectConnection.ApiVersion

                if ($response) {
                    $response
                }

                return
            }

            # B/ PullRequest Uri
            # {CollectionUri}/
            # _apis/git/pullRequests/{PullRequestId}
            # _apis/git/pullRequests/8636
            # _apis/git/repositories/{RepositoryId}/pullRequests/{PullRequestId}
            # _apis/git/repositories/fccd7d08-bf7c-4995-a1e5-60524f9aab20/pullRequests/8636
            # {CollectionUri}/{Project}/
            # _apis/git/pullRequests/{PullRequestId}
            # _apis/git/pullRequests/8636
            # _apis/git/repositories/{RepositoryId}/pullRequests/{PullRequestId}
            # _apis/git/repositories/fccd7d08-bf7c-4995-a1e5-60524f9aab20/pullRequests/8636

            # Try for url
            $maybeUrl = Use-Value -ValueA $_.url -ValueB $_

            # If it is an url, try to load the pull request
            if ($maybeUrl | Test-WebAddress) {

                # Get the project connection
                $projectConnection = Get-ApiProjectConnection `
                    -Project $maybeUrl `
                    -CollectionUri $CollectionUri

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

            # C/ PullRequestID, CollectionUri
            # Get the project connection
            $projectConnection = Get-ApiProjectConnection `
                -Project $Project `
                -CollectionUri $CollectionUri

            # Get the pull request uri
            $uri = Join-Uri `
                -Base $projectConnection.CollectionUri `
                -Relative  '_apis/git/pullRequests', $_ `
                -NoTrailingSlash

            # Make the call
            $response = Invoke-Api `
                -Uri $uri `
                -ApiCredential $projectConnection.ApiCredential `
                -ApiVersion $projectConnection.ApiVersion

            if ($response) {
                $response
            }
        }
    }
}
