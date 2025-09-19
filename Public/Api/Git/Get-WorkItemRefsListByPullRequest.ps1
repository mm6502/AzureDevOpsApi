function Get-WorkItemRefsListByPullRequest {

    <#
        .SYNOPSIS
            Return the list of work item ids referenced in given pull requests.

        .DESCRIPTION
            Return the list of work item ids referenced in given pull requests.
            Combines consecutive calls to Get-PullRequestsList and Get-PullRequestAssociatedWorkItemIds.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER PullRequest
            List of pull requests to process.

        .PARAMETER DateFrom
            Starting date & time of the time period we want to search.
            If not specified, $global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateTo
            Ending date & time of the time period we want to search.
            If not specified, [DateTime]::UTCNow is used.

        .PARAMETER TargetRepository
            List of target repositories.
            Can be passed as a name or identifier.
            If not specified, all repositories will be used.

        .PARAMETER TargetBranch
            Target branch in the target repository.

        .PARAMETER CreatedBy
            Only pull requests created by given users will be returned.
            API searches for partial match on system name and display name.
            For '*Mra*' will find 'Michal Mracka' (system name 'DITEC\mracka')
            For 'M*a' will find 'Michal Mracka' (system name 'DITEC\mracka')

        .PARAMETER FromCommits
            If specified, work items associated with commits in the pull request will be also returned.

        .PARAMETER ActivityParentId
            ID of the parent activity.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Parameters')]
    param(
        [Parameter(ParameterSetName = 'Pipeline', ValueFromPipeline)]
        [Alias('InputObject')]
        $PullRequest,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('FromDate', 'From')]
        $DateFrom,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('ToDate', 'To')]
        $DateTo,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('Repository')]
        $TargetRepository,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('Branch')]
        [string] $TargetBranch,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('Author')]
        $CreatedBy,

        [Alias('IncludeFromCommits')]
        [switch] $FromCommits,

        [int] $ActivityParentId
    )

    begin {
        # Prepare progress reporting
        $Activity = "Getting PullRequest associated WorkItemRefs"
        $ActivityId = $ActivityParentId + 1

        # Collect the urls in a hashset to avoid duplicates
        $workItemUris = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        # If invoked via Parameters, get the PullRequests
        if ($PSCmdlet.ParameterSetName -ne 'Pipeline') {

            # Get the PullRequests
            $PullRequest = @(Get-PullRequestsList `
                -Project $Project `
                -CollectionUri $CollectionUri `
                -TargetRepository $TargetRepository `
                -TargetBranch $TargetBranch `
                -DateFrom $DateFrom `
                -DateTo $DateTo `
                -CreatedBy $CreatedBy
            )

            if (!$PullRequest) {
                return
            }
        }
    }

    process {

        if (!$PullRequest) {
            return
        }

        $PullRequest | ForEach-Object {

            $current = $_

            # Ensure we actually have a pull request object, not just ID for example...
            $current = Get-PullRequest `
                -CollectionUri $CollectionUri `
                -Project $Project `
                -PullRequest $current

            # If we don't have a pull request, skip it...
            if (!$current) {
                return
            }

            # Get WorkItemRefs from PullRequests

            # Report progress
            Write-CustomProgress `
                -Activity $Activity `
                -Status "PullRequest $($current.pullRequestId)" `
                -AllItems $PullRequest `
                -Current $_ `
                -Id $ActivityId `
                -ParentId $ActivityParentId

            # Return the list of work items associated with the pull request
            Get-WorkItemRefsListByPullRequest_PullRequest_Internal `
                -CollectionUri $CollectionUri `
                -Project $Project `
                -PullRequest $current

            # Requested work item refs associated with commits Pull Request commits
            if (!$FromCommits.IsPresent -or ($true -ne $FromCommits)) {
                return
            }

            # Get WorkItemRefs from PullRequest's commits

            # Report progress
            Write-CustomProgress `
                -Activity $Activity `
                -Status "Commits for PullRequest $($current.pullRequestId)" `
                -AllItems $PullRequest `
                -Current $_ `
                -Id $ActivityId `
                -ParentId $ActivityParentId

            # Return the list of work items associated with the pull request's commits
            Get-WorkItemRefsListByPullRequest_Commit_Internal `
                -CollectionUri $CollectionUri `
                -Project $Project `
                -PullRequest $current
        } `
        | ForEach-Object {
            # Add the WorkItemRefs to the result
            if (![string]::IsNullOrWhiteSpace($_.url)) {
                if (!$workItemUris.Contains($_.url)) {
                    $null = $workItemUris.Add($_.url)
                    $_ | Write-Output
                }
            }
        }
    }

   end {
        Write-Progress `
            -Activity $Activity `
            -Id $ActivityId `
            -ParentId $ActivityParentId `
            -Completed
   }
}
