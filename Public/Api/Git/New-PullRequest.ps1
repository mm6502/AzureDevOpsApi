function New-PullRequest {

    <#
        .SYNOPSIS
            Creates a new pull request for given repo branches, if they differ.
            Returns a pull request object if successful,

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Repository
            Name of the git repository to search.
            No wildcards allowed

        .PARAMETER SourceBranch
            Name of the base branch

        .PARAMETER TargetBranch
            Name of the target branch

        .PARAMETER AutoComplete
            Whether the pull request should be autocompleted

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/git/diffs/get?view=azure-devops-rest-7.1&tabs=HTTP
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Does not change state, generates a new object.'
    )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Parameter(Mandatory)]
        $Repository,

        [Parameter(Mandatory)]
        [Alias('Source', 'BaseBranch')]
        $SourceBranch,

        [Parameter(Mandatory)]
        [Alias('Target')]
        $TargetBranch,

        [switch] $AutoComplete
    )

    process {

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # Get the commit diffs
        $behindCount = (
            Get-CommitDiffsCount `
                -CollectionUri $connection.CollectionUri `
                -Project $connection.ProjectBaseUri `
                -Repository $Repository `
                -SourceBranch $SourceBranch `
                -TargetBranch $TargetBranch `
        ).behindCount

        # If there are no commits, there is nothing to do
        if (!$behindCount -or ($behindCount -eq 0)) {
            Show-Host -Object (
                "Repository $($Repository): no changes between target branch ($($TargetBranch))" `
                + " and source branch ($($SourceBranch))."
            )
            return
        }

        # Create the pull request

        # Make the final uri
        $uri = Join-Uri `
            -Base $connection.ProjectBaseUri `
            -Relative '_apis/git/repositories', $Repository, 'pullrequests' `
            -NoTrailingSlash

        # Create the payload
        $body = @{
            title         = "$($SourceBranch)->$($TargetBranch)"
            description   = "$($SourceBranch)->$($TargetBranch)"
            sourceRefName = "refs/heads/$($SourceBranch)"
            targetRefName = "refs/heads/$($TargetBranch)"
        }

        # Send the request
        try {
            $response = Invoke-Api `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri `
                -Body ($body | ConvertTo-JsonCustom)
        } catch {
            # pending merge request for the same source and target branch
            if ($_.Exception.StatusCode -eq 409) {
                # https://dev-tfs/tfs/internal_projects/DITEC_TestovaciaSablona_CMMI-v4/_git/Heracles/pullrequests?_a=active
                $portalUri = Join-Uri `
                    -Base $connection.ProjectBaseUri `
                    -Relative '_git', $Repository, 'pullrequests' `
                    -Parameters @{ _a = 'active' } `
                    -NoTrailingSlash
                throw (
                    "Unable to create pull request in repository $($Repository)." `
                        + " An active pull request for the source ($($SourceBranch)) and target" `
                        + " ($($TargetBranch)) already exists. Resolve pending pull requests and try again." `
                        + " You can view pending pull requests here:`n$($portalUri)"
                )
            }
            throw
        }

        # If AutoComplete is not requested, just return the pull request
        if (!$AutoComplete.IsPresent -or ($AutoComplete -ne $true)) {
            return $response
        }

        # If AutoComplete is requested, create the AutoComplete request
        $pullRequestID = $response.pullRequestId

        # Make the pullrequest uri
        $uri = Join-Uri `
            -Base $connection.ProjectBaseUri `
            -Relative '_apis/git/repositories', $Repository, 'pullrequests', $pullRequestID `
            -NoTrailingSlash

        # Create the payload
        $body = @{
            autoCompleteSetBy = @{
                id = (
                    Get-CurrentUser `
                        -CollectionUri $connection.CollectionUri `
                        -ApiCredential $connection.ApiCredential `
                ).id
            }
            completionOptions = @{
                deleteSourceBranch = "false"
                mergeCommitMessage = "$($SourceBranch)->$($TargetBranch)"
                squashMerge        = "false"
            }
        }

        # Modify the pull request by
        # Sending the autocomplete patch request
        $response = Invoke-Api `
            -ApiCredential $connection.ApiCredential `
            -ApiVersion $connection.ApiVersion `
            -Uri $uri `
            -Body ($body | ConvertTo-JsonCustom) `
            -Method "PATCH"

        # Wait for the pull request's merge to be processed
        $SleepTime = 0.25
        $SleepCount = 0
        $TotalSleepTime = 0

        while ($response.mergeStatus -eq 'queued') {

            Start-Sleep -Seconds $SleepTime
            $TotalSleepTime += $SleepTime
            $SleepCount += 1
            $SleepTime *= 2

            # If we've waited too long, give up
            if ($SleepCount -gt 10) {
                $formattedTime = "$('{0:mm} minutes and {0:ss} seconds' -f [timespan]::FromSeconds($TotalSleepTime))"
                Write-Warning (
                    "Repository $($Repository): Merge request '$($response.title)' still queued after $($formattedTime)."
                )
                break;
            }

            # Get the pull request again
            $response = Invoke-Api `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri
        }

        # If the merge failed, throw an error
        if ($response.mergeStatus -eq 'conflicts') {
            # "https://dev-tfs/tfs/internal_projects/DITEC_TestovaciaSablona_CMMI-v4/_git/Heracles/pullrequest/4219"
            $portalUri = Join-Uri `
                -Base $connection.ProjectBaseUri `
                -Relative '_git', $Repository, 'pullrequests', $response.pullRequestId `
                -NoTrailingSlash

            Write-Warning (
                "Merge conflict in repository $($Repository) for pull request '$($response.title)'." `
                    + " Please resolve conflicts and try again." `
                    + " You can view the pull request here:`n$($portalUri)"
            )
        }

        # Return the pull request
        $response
    }
}
