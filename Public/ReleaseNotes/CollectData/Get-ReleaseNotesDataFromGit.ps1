function Get-ReleaseNotesDataFromGit {

    <#
        .SYNOPSIS
            Gets release notes data from Git based project.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            Can be ommitted if $CollectionUri was previously accessed via this API.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            Can be ommitted if $Project was previously accessed via this API (will be extracted from the $ArtifactUri).
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateFrom
            Starting date for the considered PullRequests.

        .PARAMETER DateTo
            Ending date for the considered PullRequests.

        .PARAMETER AsOf
            Gets the Work Items as they were at this date and time.

        .PARAMETER ByUser
            User(s) whose PullRequests will be used.

        .PARAMETER TargetRepository
            List of target repositories.
            Can be passed as a name or identifier.
            If not specified, all repositories will be used.

        .PARAMETER TargetBranch
            Target branch for PullRequests.

        .PARAMETER FromCommits
            If specified, work items associated with commits in the pull request will be also returned.
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [Alias('FromDate', 'From')]
        [Nullable[DateTime]] $DateFrom,

        [Alias('ToDate', 'To')]
        [Nullable[DateTime]] $DateTo,

        [Nullable[DateTime]] $AsOf,

        $ByUser,

        [Alias('Repository')]
        $TargetRepository,

        [Alias('Branch')]
        $TargetBranch = 'main',

        [Alias('IncludeFromCommits')]
        [switch] $FromCommits
    )

    # Correct paramater values
    $DateFrom = Use-FromDateTime -Value $DateFrom
    $DateTo = Use-ToDateTime -Value $DateTo
    $AsOf = Use-AsOfDateTime -Value $AsOf -DateTo $DateTo

    # Gather the release notes data from Pull Requests
    $data = @{ }

    # # Get Work Item Ref's from Pull Requests
    Show-Host -ForegroundColor Magenta -Object 'Gathering WorkItemRefs from PullRequests'
    $workItemRefs = @(
        Get-WorkItemRefsListByPullRequest `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -TargetRepository $TargetRepository `
            -TargetBranch $TargetBranch `
            -DateFrom $DateFrom `
            -DateTo $DateTo `
            -CreatedBy $ByUser `
            -FromCommits:$FromCommits
    )

    # Gather the release notes data from Pull Requests
    Show-Host -ForegroundColor Magenta -Object 'Gathering WorkItem data from PullRequests'
    $null = Add-WorkItemToReleaseNotesData `
        -CollectionUri $CollectionUri `
        -Project $Project `
        -ReleaseNotesData $data `
        -Reason 'PullRequest' `
        -AsOf $AsOf `
        -WorkItem $workItemRefs

    # Gather the release notes data from Work Item Query

    # Get Work Item Ref's from Time Period
    Show-Host -ForegroundColor Magenta -Object 'Gathering WorkItemRefs from TimePeriod'
    $workItemRefs = @(
        Get-WorkItemRefsListByTimePeriod `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -DateFrom $DateFrom `
            -DateTo $DateTo `
            -AsOf $AsOf `
            -DateAttribute 'Microsoft.VSTS.Common.StateChangeDate'
    )

    # Gather the release notes data from Time Period
    Show-Host -ForegroundColor Magenta -Object 'Gathering WorkItem data from TimePeriod'
    $null = Add-WorkItemToReleaseNotesData `
        -CollectionUri $CollectionUri `
        -Project $Project `
        -ReleaseNotesData $data `
        -Reason 'TimePeriod' `
        -AsOf $AsOf `
        -WorkItem $workItemRefs

    return $data
}
