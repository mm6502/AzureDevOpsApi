function Get-PullRequestsList {

    <#
        .SYNOPSIS
            Gets successfully merged pull requests matching given criteria.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateFrom
            Starting date & time of the time period we want to search.
            If not specified, $global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateTo
            Ending date & time of the time period we want to search.
            If not specified, [DateTime]::UTCNow is used.

        .PARAMETER Opened
            Only pull requests opened in given time period will be returned.
            Default value is $false.

        .PARAMETER Closed
            Only pull requests closed in given time period will be returned.
            Default value is $true.

        .PARAMETER TargetBranch
            Target branch in the target repository.

        .PARAMETER TargetRepository
            List of target repositories.
            Can be passed as a name or identifier.
            If not specified, all repositories will be used.

        .PARAMETER CreatedBy
            List of users who created the pull requests.
            Can be passed as a name or identifier.
            If not specified, all users will be used.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-requests/get-pull-requests-by-project?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Alias('FromDate','From')]
        $DateFrom,

        [Alias('ToDate','To')]
        $DateTo,

        [bool] $Opened = $false,
        [bool] $Closed = $true,

        [Alias('Repository')]
        $TargetRepository,

        [Alias('Branch')]
        [string] $TargetBranch,

        [Alias('Author')]
        $CreatedBy
    )

    process {

        $activity = "Getting the PullRequests"

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -AllowFallback:$false

        # Official URI:
        # GET https://dev.azure.com/{organization}/{project}/_apis/git/pullrequests?api-version=5.0
        # GET https://dev.azure.com/{organization}/{project}/_apis/git/pullrequests?
        # searchCriteria.includeLinks={searchCriteria.includeLinks}
        # &searchCriteria.sourceRefName={searchCriteria.sourceRefName}
        # &searchCriteria.sourceRepositoryId={searchCriteria.sourceRepositoryId}
        # &searchCriteria.targetRefName={searchCriteria.targetRefName}
        # &searchCriteria.status={searchCriteria.status}
        # &searchCriteria.reviewerId={searchCriteria.reviewerId}
        # &searchCriteria.creatorId={searchCriteria.creatorId}
        # &searchCriteria.repositoryId={searchCriteria.repositoryId}
        # &maxCommentLength={maxCommentLength}
        # &$skip={$skip}&$top={$top}&api-version=5.1
        # ... but also works without {project}:
        # GET https://dev.azure.com/{organization}/_apis/git/pullrequests?
        $uri = Join-Uri `
            -Base $connection.BaseUri `
            -Relative '_apis/git/pullrequests' `
            -NoTrailingSlash

        $uri = Add-QueryParameter -Uri $uri -Parameters @{
            # only completed
            'searchCriteria.status' = 'completed'
        }

        # only targeting the given branch
        if ($TargetBranch) {
            $uri = Add-QueryParameter -Uri $uri -Parameters @{
                'searchCriteria.targetRefName' = "refs/heads/$($TargetBranch)"
            }
        }

        if ($CreatedBy) {
            # Filtering by creator if only one user is passed
            # is more efficient on server side
            if ($CreatedBy.Count -eq 1) {
                # resolve the user name to identity id
                $identityId = (Get-Identity `
                    -CollectionUri $connection.CollectionUri `
                    -User $CreatedBy `
                ).id
            }

            # Create a pattern for each user
            # The patterns will be used to post filter the pull requests
            $CreatedByPatterns = $CreatedBy | ForEach-Object {
                $temp = [string] $_
                if ($temp.IndexOfAny('*?') -lt 0) {
                    $temp = "*$($temp)*"
                }
                $temp
            }
        }

        # Resolve the repository names to ids
        if ($TargetRepository) {
            # Filtering by creator if only one repository is passed
            # is more efficient on server side
            if ($TargetRepository.Count -eq 1) {
                $repositoryId = (Get-RepositoriesList `
                    -CollectionUri $connection.CollectionUri `
                    -Project $connection.ProjectName `
                    -Repository $TargetRepository
                ).id
            }

            # Create a pattern for each repository
            # The patterns will be used to post filter the pull requests
            $TargetRepositoryPatterns = $TargetRepository | ForEach-Object {
                $temp = [string] $_
                if ($temp.IndexOfAny('*?') -lt 0) {
                    $temp = "*$($temp)*"
                }
                $temp
            }
        }

        # Construct the uri for the request
        $tempUri = $uri

        # Only created by given user
        if ($null -ne $identityId) {
            $tempUri = Add-QueryParameter -Uri $tempUri -Parameters @{
                'searchCriteria.creatorId' = $identityId
            }
        }

        # Only in given repository
        if ($null -ne $repositoryId) {
            $tempUri = Add-QueryParameter -Uri $tempUri -Parameters @{
                'searchCriteria.repositoryId' = $repositoryId
            }
        }

        # List all pull requests for a project;
        # API does not filter by date time, do the filter ourselves
        Invoke-ApiListPaged `
            -ApiCredential $connection.ApiCredential `
            -ApiVersion $connection.ApiVersion `
            -Uri $tempUri `
            -Activity $activity `
        | Where-Object {
            # filter by closedDate
            (!$Closed) -or (Test-DateTimeRange -Value $_.closedDate -From $DateFrom -To $DateTo)
        } `
        | Where-Object {
            # filter by creationDate
            (!$Opened) -or (Test-DateTimeRange -Value $_.creationDate -From $DateFrom -To $DateTo)
        } `
        | Where-Object {
            # filter by createdBy
            (!$CreatedBy) -or ($_.createdBy `
                | Test-ObjectProperty -Property 'displayName', 'id', 'uniqueName' -Pattern $CreatedByPatterns
            )
        } `
        | Where-Object {
            # filter by repository
            (!$TargetRepository) -or ($_.repository `
                | Test-ObjectProperty -Property 'id', 'name' -Pattern $TargetRepositoryPatterns
            )
        }
    }
}
