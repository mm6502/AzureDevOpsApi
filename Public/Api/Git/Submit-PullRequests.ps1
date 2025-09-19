function Submit-PullRequests {

    <#
        .SYNOPSIS
            Submits pull requests for the specified repositories and branches.

        .DESCRIPTION
            The Submit-PullRequests function submits pull requests for the specified repositories and branches.
            It gets a list of repositories, filters them, and creates a pull request for each one if needed.

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

        .PARAMETER IncludeRepository
            Names or masks of the git repositories to make the pullrequests for.

        .PARAMETER ExcludeRepository
            Names or masks of the git repositories to NOT make the pullrequests for.

        .PARAMETER SourceBranch
            Name of the base branch.

        .PARAMETER TargetBranch
            Name of the target branch.

        .PARAMETER AutoComplete
            Whether the pull request should be autocompleted.

        .PARAMETER PassThru
            Specifies whether the function should return objects to the pipeline.
            When you use the -PassThru switch, the function returns an object
            that you can work with further. Without -PassThru, the function may execute silently
            without returning any data.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Alias('Include')]
        $IncludeRepository = @('*'),

        [Alias('Exclude')]
        $ExcludeRepository = @(),

        [Parameter(Mandatory)]
        $SourceBranch,

        [Parameter(Mandatory)]
        $TargetBranch,

        [switch] $AutoComplete,
        [switch] $PassThru
    )

    process {
        # Get all repositories, filter them by include/exclude lists
        $repositories = (
            Get-RepositoriesList `
                -CollectionUri $CollectionUri `
                -Project $Project `
        ) `
        | Where-Object -FilterScript {
            $_.name | Test-StringMasks -Include $IncludeRepository -Exclude $ExcludeRepository -CaseSensitive:$CaseSensitive
        }

        # Collection of pull requests
        $result = [System.Collections.Generic.List[PSCustomObject]]::new()
        $wereErrors = $false

        # Create pull request for each repository and collect results
        foreach ($repository in $repositories) {
            try {
                $result += New-PullRequest `
                    -CollectionUri $CollectionUri `
                    -Project $Project `
                    -Repository $repository.name `
                    -SourceBranch $SourceBranch `
                    -TargetBranch $TargetBranch `
                    -AutoComplete:$AutoComplete
            } catch {
                $wereErrors = $true
                Write-Warning -Message $_
            }
        }

        # if errors occurred, throw exception
        if ($wereErrors) {
            throw "Some pull requests could not be created."
        }

        # if -AutoComplete switch is used, check if all pull requests were completed
        if ($AutoComplete.IsPresent -and ($AutoComplete -eq $true)) {
            foreach ($pullRequest in $result) {
                # check results
                if ($pullRequest.status -ne 'completed') {
                    throw "Some pull requests were not completed."
                }
            }
        }

        # if -PassThru switch is used, return result
        if ($PassThru.IsPresent -and ($PassThru -eq $true)) {
            $result
        }
    }
}
