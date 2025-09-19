function Get-CommitsList {

    <#
        .SYNOPSIS
            Gets list of all commits meeting given criteria.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Author
            Author of the commits.
            API searches for partial match on system name and display name.
            For 'Mra' will find 'Michal Mracka'   (system name 'DITEC\mracka')
            For '*Mra*' will find 'Michal Mracka' (system name 'DITEC\mracka')
            For 'M*a' will find 'Michal Mracka'   (system name 'DITEC\mracka')

        .PARAMETER Repository
            Name of the git repository to search.
            Can use '*' as wildcard.
            For '*POD' will find 'POD','EPOD'.
            For 'P*D' will find 'PAD','POD'.

        .PARAMETER Branch
            Name of a branch to search.

        .PARAMETER DateFrom
            Lists commits created on or after specified date time.

        .PARAMETER DateTo
            Lists commits created on or before specified date time.

        .PARAMETER Simple
            Flag, whether return raw data as returned from the server (when $false) or
            adjusted for output to console (when $true).

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/git/commits/get-commits?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        $Author,
        $Repository,
        $Branch,

        [Alias('From', 'FromDate')]
        $DateFrom,

        [Alias('To', 'ToDate')]
        $DateTo,

        [switch] $Simple
    )

    process {

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # Find repositories
        $repos = @(
            Get-RepositoriesList `
                -CollectionUri $connection.CollectionUri `
                -Project $connection.ProjectBaseUri `
                -Repository $Repository
        )

        # Correct inputs
        $DateFrom = Use-FromDateTime -Value $DateFrom
        $DateTo = Use-ToDateTime -Value $DateTo

        $Author = @($Author)
        $APIAuthor = @()
        if ($Author.Length -eq 1) {
            # Adjust Author parameter for API
            # API will match system name for partial match
            # API does not support wild cards
            if ($Author -notmatch '[*?]') {
                $APIAuthor = $Author
            }
        }

        # Find commits for each repository
        foreach ($repo in $repos) {

            # Build the uri for querying
            $uri = Join-Uri -Base $repo.url -Relative 'commits' -NoTrailingSlash

            if ($APIAuthor.Length -eq 1) {
                $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'author' = $APIAuthor }
            }
            if ($Branch) {
                $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'itemVersion.version' = $Branch }
            }
            if ($DateFrom) {
                $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'fromDate' = (Format-Date $DateFrom) }
            }
            if ($DateTo) {
                $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'toDate' = (Format-Date $DateTo) }
            }

            # Get the data
            $response = Invoke-ApiListPaged `
                -ApiVersion $connection.ApiVersion `
                -ApiCredential $connection.ApiCredential `
                -Uri $uri

            $commits = @($response)

            # Filter the authors if specified more than one or contained wildcards
            if ($Author -and ($APIAuthor.Length -eq 0)) {
                # Build patterns for author names
                $authorPatterns = @($Author | ForEach-Object {
                    $tmpPattern = $_.Trim()
                    if ($tmpPattern -notmatch '[*?]') {
                        $tmpPattern = '*' + $tmpPattern + '*'
                    }
                    $tmpPattern
                })

                $commits = @($commits `
                    | Select-ByObjectProperty -Property 'author.name' -Pattern $authorPatterns
                )
            }

            # If no data, skip this repo
            if (!$commits) {
                continue
            }

            # Add project and repo name to each commit
            foreach ($commit in $commits) {
                $commit | Add-Member -MemberType NoteProperty -Name "collectionUri" -Value $connection.CollectionUri
                $commit | Add-Member -MemberType NoteProperty -Name "project" -Value ([PSCustomObject] @{
                    id   = $connection.ProjectId
                    name = $connection.ProjectName
                    url  = $connection.ProjectUri
                })
                $commit | Add-Member -MemberType NoteProperty -Name "repository" -Value ([PSCustomObject] @{
                    id   = $repo.id
                    name = $repo.name
                    url  = $repo.url
                })
            }

            # Send data down the pipeline
            if (!$Simple.IsPresent -or $Simple -ne $true) {
                $commits | Write-Output
                continue;
            }

            # Adjust data for output to console
            $commits `
            | Select-Object `
                @{ Name = 'project' ; Expression = { $_.project.name } }, `
                @{ Name = 'repo' ; Expression = { $_.repository.name } }, `
                commitId, `
                @{ Name = 'commit' ; Expression = { $_.commitId.SubString(0, 8) } }, `
                @{ Name = 'author' ; Expression = { $_.author.name } }, `
                @{ Name = 'dateTime'; Expression = { [datetime]$_.author.date } }, `
                comment `
            | Write-Output
        }
    }
}
