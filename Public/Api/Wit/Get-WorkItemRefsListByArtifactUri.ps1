function Get-WorkItemRefsListByArtifactUri {

    <#
        .SYNOPSIS
            Gets list of work item references associated with given artifacts.

        .DESCRIPTION
            Gets list of work item references associated with given artifacts.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            Can be ommitted if $CollectionUri was previously accessed via this API.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            Can be ommitted if $Project was previously accessed via this API (will be extracted from the $ArtifactUri).
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER ArtifactUri
            List of Artifact Uris to query work items for.
            All Artifact Uris must be from the same project collection.

        .OUTPUTS
            WorkItemRef object, deduplicated by url.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/artifact-uri-query/query?view=azure-devops-rest-6.0&tabs=HTTP

        .EXAMPLE
            Get-WorkItemRefsListByArtifactUri `
                -ArtifactUri 'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357' `
                -CollectionUri 'https://dev-tfs/tfs/internal_projects'

            id     url
            --     ---
            405200 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/405200

        .EXAMPLE
            # Assuming both projects are in the same collection and were accessed previously
            Get-WorkItemRefsListByArtifactUri `
                -ArtifactUri `
                'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357',
                'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2fc5538a9c-ad60-426a-8898-b50a44ee9e72%2f7179',
                'vstfs:///Git/PullRequestId/5e62fde7-1b9d-40d1-b69c-787f9b7aaadb%2ffccd7d08-bf7c-4995-a1e5-60524f9aab20%2f8636'

            id     url
            --     ---
            405200 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/405200
            422660 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/422660
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        $ArtifactUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri
    )

    begin {
        # Collect the urls in a hashset to avoid duplicates
        $workItemUris = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    process {

        # If no artifacts are specified, exit
        if (!$ArtifactUri) {
            return
        }

        ## Artifact Uris
        ## Commit:
        ## vstfs:///Git/Commit/{projectId}%2f{repositoryId}%2f{commitId}
        ## vstfs:///Git/Commit/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f56e74acbbd9a5d5ef5a34f4eb086cb1a0b2140d0
        ## Pull Request:
        ## vstfs:///Git/PullRequestId/{projectId}%2f{repositoryId}%2f{pullRequestId}
        ## vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357

        # TODO: Add support for other artifact types

        # Group the ArtifactUris by Project
        $regex = '^vstfs:///Git/(Commit|PullRequestId)/(?<projectId>.+)%2f(?<repositoryId>.+)%2f(?<artifactId>.+)$'

        $artifactUrisByProjectGroups = $ArtifactUri `
        | ForEach-Object {
            # Get the project
            if ($_ -match $regex) {
                # Extract project id from artifact uri
                $currentProject = $Matches['projectId']
            } else {
                # Use the specified $Project
                $currentProject = $Project
            }

            # Make the object to allow for grouping
            [PSCustomObject] @{
                ArtifactUri   = $_
                Project       = $currentProject
                CollectionUri = $null
            }
        } `
        | Group-Object -Property 'Project'

        # Query work items for each project
        $artifactUrisByProjectGroups `
        | ForEach-Object {
            $group = $_

            # Determine $CollectionUri from $Project
            $projectObj = Resolve-ApiProject `
                -Project $group.Name `
                -CollectionUri $CollectionUri

            # If project was found, use the cached data
            if ($projectObj -and $projectObj.Verified) {
                $currentCollectionUri = $projectObj.CollectionUri
                $currentProject = $projectObj.ProjectId
            } elseif (!$group.CollectionUri) {
                $currentCollectionUri = $CollectionUri
                $currentProject = $group.Name
            }

            # Get the project connection
            $connection = Get-ApiProjectConnection `
                -CollectionUri $currentCollectionUri `
                -Project $currentProject

            # POST https://dev.azure.com/{organization}/{project}/_apis/wit/artifacturiquery?api-version=6.0-preview.1
            # {
            #     "artifactUris": [
            #        "vstfs:///Git/Commit/3065bb47-8344-4370-982a-5183abf197fa%2F649107bd-ab35-4192-8584-601f64172f80%2F4800cfa0be564b1e606d6811e99e0380f765a9c4"
            #     ]
            # }
            $uri = Join-Uri `
                -BaseUri $connection.ProjectBaseUri `
                -RelativeUri "_apis/wit/artifacturiquery"

            # API is avaliable only in *-preview.1
            if ($connection.ApiVersion -notlike '*-preview*') {
                $connection.ApiVersion += '-preview.1'
            }

            $body = [PSCustomObject] @{
                artifactUris = @($group.Group.ArtifactUri)
            } | ConvertTo-JsonCustom

            # Make the call
            $response = Invoke-Api `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri `
                -Body $body `
                -AsHashtable

            # response
            # {
            #     "artifactUrisQueryResult": {
            #         "vstfs:///Git/Commit/890669f3...00000001": [
            #             {
            #                 "id": 373878,
            #                 "url": "https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/373878"
            #             },
            #             {
            #                 "id": 373877,
            #                 "url": "https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/373877"
            #             }
            #         ]
            #         "vstfs:///Git/Commit/890669f3...00000002": [
            #             {
            #                 "id": 373878,
            #                 "url": "https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/373878"
            #             },
            #             {
            #                 "id": 373877,
            #                 "url": "https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/373877"
            #             }
            #         ]
            #     }
            # }

            # If no results, exit
            if (!$response.artifactUrisQueryResult) {
                continue
            }

            if ($response.artifactUrisQueryResult.Values.Count -lt 1) {
                continue
            }

            # Return results
            $response.artifactUrisQueryResult.GetEnumerator() `
            | ForEach-Object {
                # There may be no WorkItem associated with the artifact uri
                if (!$_.Value) {
                    return
                }

                $_.Value | ForEach-Object {
                    if (![string]::IsNullOrWhiteSpace($_.url)) {
                        if (!$workItemUris.Contains($_.url)) {
                            $null = $workItemUris.Add($_.url)

                            # The WorkItem URL does not contain the project id;
                            # add it
                            $url = Get-WorkItemApiUrl `
                                -CollectionUri $currentCollectionUri `
                                -Project $currentProject `
                                -WorkItem $_.id

                            [PSCustomObject] @{
                                id  = $_.id
                                url = $url
                            } | Write-Output
                        }
                    }
                }
            }
        }
    }
}
