function Get-WorkItemRefsListByPullRequest_Commit_Internal {

    <#
        .SYNOPSIS
            Returns a list of work item identifiers associated with the given pull request.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER PullRequest
            Pull request object loaded from API.

        .PARAMETER Project
            Project the pull request belongs to.

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

        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        $PullRequest
    )

    process {

        # Return the list of work item refs associated with the commits in the pull request
        $PullRequest | ForEach-Object {

            $item = $_

            # Skip empty items
            if (!$item) {
                return
            }

            # Get connection
            $connection = Get-ApiProjectConnection `
                -CollectionUri $CollectionUri `
                -Project $Project

            # enumerate the commits in the pull request
            # if we have a url we can make a shortcut - the link to
            # the list of linked work items in the '_links' section
            # is a link to the pull request + '/workitems'
            # link is absolute, we don't need the collection
            $commits = Invoke-ApiListPaged `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri "$($item.url)/commits" `
                -Top 10000  # this api does not support paging

            if (!$commits.url) {
                return
            }

            # make artifact uris
            $artifactObjects = $commits.url `
            | ConvertTo-CommitArtifactUriObject

            # get work item ids associated with the commits
            $workItemRefs = $artifactObjects.ArtifactUri `
            | Get-WorkItemRefsListByArtifactUri `
                -CollectionUri $connection.CollectionUri `
                -Project $connection.ProjectId

            if ($workItemRefs) {
                $workItemRefs
            }
        }
    }
}
