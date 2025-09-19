function Get-CommitDiffsCount {

    <#
        .SYNOPSIS
            Find the closest common commit (the merge base) between base and target commits,
            and get the diff count between either the base and target commits or common and target commits.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Repository
            Name, ID or Uri of the git repository to search.
            No wildcards allowed

        .PARAMETER SourceBranch
            Name of the base branch

        .PARAMETER TargetBranch
            Name of the target branch

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/git/diffs/get?view=azure-devops-rest-7.1&tabs=HTTP
    #>

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
        [Alias('Base', 'BaseBranch')]
        $SourceBranch,

        [Parameter(Mandatory)]
        [Alias('Target')]
        $TargetBranch
    )

    process {

        # Get connection to project
        if ($Repository | Test-WebAddress) {
            # If $Repository is an Uri, use it for project connection
            $connection = Get-ApiProjectConnection `
                -CollectionUri $CollectionUri `
                -Project $Repository

            # If the repository is a full Uri, extract the name of the repository
            if ($Repository -match '_apis/git/repositories/(.+)') {
                $Repository = $Matches[1]
            }
        } else {
            $connection = Get-ApiProjectConnection `
                -CollectionUri $CollectionUri `
                -Project $Project
        }

        # Make the final uri
        $uri = Join-Uri `
            -Base $connection.ProjectBaseUri `
            -Relative '_apis/git/repositories', $Repository, 'diffs/commits' `
            -NoTrailingSlash `
            -Parameters @{
                baseVersion   = $SourceBranch
                targetVersion = $TargetBranch
                # To get the count of changes between the common and target commits,
                # changes must be returned, so limit to 1
                '$top'        = 1
            }

        # Make the call
        $response = Invoke-Api `
            -ApiVersion $connection.ApiVersion `
            -ApiCredential $connection.ApiCredential `
            -Uri $uri

        if (!$response) {
            $message = (
                "Eihter the repository ('$($Repository)') or one of the branches" `
                + " ('$($SourceBranch)','$($TargetBranch)') does not exist."
            )
            Write-Warning -Message $message
        }

        # Return the response
        $response
    }
}
