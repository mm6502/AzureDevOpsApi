function Get-WorkItemRefsListByPullRequest_PullRequest_Internal {

    <#
        .SYNOPSIS
            Returns a list of work item ref objects associated with the given pull request.

        .DESCRIPTION
            Returns a list of work item ref objects associated with the given pull request.

        .PARAMETER PullRequest
            Pull request to resolve work item refs for.
            Valid inputs:
            - Pull request Object as loaded by Get-PullRequest
            - Pull request Object as loaded by Get-PullRequestsList
            - Pull request artifact uri
              'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357'
            - Pull request url
              'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/pullrequests/8357'
              'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/pullrequests/8357'
              'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo/pullrequests/8357'
              'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed/pullrequests/8357'
            - Pull request id, CollectionUri must be specified, otherwise default will be used
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

        .OUTPUTS
            WorkItemRef object, deduplicated by url.

        .EXAMPLE
            # All items represent the same PullRequest
            # Assuming project was accessed previously
            Get-WorkItemRefsListByPullRequest_PullRequest_Internal -PullRequest @(
                # PullRequest Object, ArtifactUri in property artifactId
                @{ artifactId = 'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357' }
                'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357'
                'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/pullrequests/8357'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/pullrequests/8357'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo/pullrequests/8357'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed/pullrequests/8357'
            )

            id     url
            --     ---
            422660 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/422660
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        $PullRequest,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project
    )

    # "List" variant - object loaded from:
    # GET {Collection}/_apis/git/pullrequests/{PullRequestId}
    # GET {Collection}/{Project}/_apis/git/pullrequests/{PullRequestId}
    # does not contain 'workItemRefs' or '_links' sections

    # "Detail" variant - object loaded from:
    # GET {Collection}/{Project}/_apis/git/repositories/{RepositoryId}/pullrequests/{PullRequestId}
    #     ?maxCommentLength={maxCommentLength}&$skip={$skip}&$top={$top}&includeCommits={includeCommits}
    #     &includeWorkItemRefs={includeWorkItemRefs}&api-version=5.0
    # contains '_links' section;
    # If loaded with includeWorkItemRefs=true parameter, contains also 'workItemRefs' section

    # "ID" variant - identifier of a pull request:
    # (infering from content of '_links' section in "Detail" variant)
    # The list of linked work items is on the relative path to the url from the "Detail" variant:
    # GET ./workitems

    begin {
        # Collect the urls in a hashset to avoid duplicates
        $workItemUris = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    process {

        if (!$PullRequest) {
            return
        }

        $PullRequest | ForEach-Object {

            # Possible values:
            # A/ PullRequest ArtifactUri
            # B/ PullRequest object without artifactId property
            # C/ PullRequest Uri
            # D/ PullRequestID, CollectionUri
            # E/ PullRequest object with artifactId property

            # A/ PullRequest ArtifactUri
            if ($_ -like 'vstfs:///Git/PullRequestId/*') {

                if ($_ -match '^vstfs:///Git/PullRequestId/(?<ProjectId>.+?)%2f.*$') {
                    $currentProject = $Matches['ProjectId']
                } else {
                    $currentProject = $Project
                }

                $projectConnection = Get-ApiProjectConnection `
                    -Project $currentProject `
                    -CollectionUri $CollectionUri

                $response = Get-WorkItemRefsListByArtifactUri `
                    -ArtifactUri $_ `
                    -CollectionUri $projectConnection.CollectionUri

                if (!$response) {
                    return
                }

                $response | ForEach-Object {
                    if (![string]::IsNullOrWhiteSpace($_.url)) {
                        if (!$workItemUris.Contains($_.url)) {
                            $null = $workItemUris.Add($_.url)
                            $_ | Write-Output
                        }
                    }
                }
                return
            }

            # B/ PullRequest object without artifactId property
            # PullRequest object loaded from Get-PullRequestsList does not have artifactId property
            # Construct it from available properties
            if (!$_.artifactId -and $_.repository -and $_.pullRequestId -and $_.url) {
                $artifactUri = "vstfs:///Git/PullRequestId/$($_.repository.project.id)%2f$($_.repository.id)%2f$($_.pullRequestId)"

                $projectConnection = Get-ApiProjectConnection `
                    -Project $_.url

                $response = Get-WorkItemRefsListByArtifactUri `
                    -ArtifactUri $artifactUri `
                    -CollectionUri $projectConnection.CollectionUri

                if (!$response) {
                    return
                }

                $response | ForEach-Object {
                    if (![string]::IsNullOrWhiteSpace($_.url)) {
                        if (!$workItemUris.Contains($_.url)) {
                            $null = $workItemUris.Add($_.url)
                            $_ | Write-Output
                        }
                    }
                }
                return
            }

            # C/ PullRequest Uri
            # D/ PullRequestID, CollectionUri
            # Read the PullRequest first
            $pullRequestObj = $_

            if (!$pullRequestObj.artifactId) {

                $projectConnection = Get-ApiProjectConnection `
                    -Project $Project `
                    -CollectionUri $CollectionUri

                $pullRequestObj = Get-PullRequest `
                    -PullRequest $pullRequestObj `
                    -CollectionUri $projectConnection.CollectionUri `
                    -Project $projectConnection.ProjectBaseUri

                if (!$pullRequestObj) {
                    return
                }
            }

            # E/ PullRequest object with artifactId property
            if ($pullRequestObj.artifactId) {
                $projectConnection = Get-ApiProjectConnection `
                    -Project $pullRequestObj.repository.project.url `
                    -CollectionUri $CollectionUri

                $response = Get-WorkItemRefsListByArtifactUri `
                    -ArtifactUri $pullRequestObj.artifactId `
                    -CollectionUri $projectConnection.CollectionUri

                if (!$response) {
                    return
                }

                $response | ForEach-Object {
                    if (![string]::IsNullOrWhiteSpace($_.url)) {
                        if (!$workItemUris.Contains($_.url)) {
                            $null = $workItemUris.Add($_.url)
                            $_ | Write-Output
                        }
                    }
                }
                return
            }
        }
    }
}
