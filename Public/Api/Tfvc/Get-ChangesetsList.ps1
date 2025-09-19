function Get-ChangesetsList {

    <#
        .SYNOPSIS
            Gets list of all changesets meeting given criteria.

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
            For 'M*a' will find 'Michal Mracka' (system name 'DITEC\mracka')

        .PARAMETER Branch
            Name of a branch to search.

        .PARAMETER DateFrom
            Lists commits created on or after specified date time.

        .PARAMETER DateTo
            Lists commits created on or before specified date time.

        .PARAMETER Raw
            Flag, whether return raw data as returned from the server (when $true) or
            adjusted for output to console (when $false).

        .PARAMETER OutputFile
            Saves results as CSV file with given name.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/tfvc/changesets/get-changesets?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Alias('FromDate', 'From')]
        $DateFrom,

        [Alias('ToDate', 'To')]
        $DateTo,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('TargetBranch', 'Target')]
        [string] $Branch,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('Author')]
        $CreatedBy
    )

    process {

        $activity = "Getting the Changesests"

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -AllowFallback:$false

        if ($CreatedBy) {
            # Filtering by creator if only one user is passed
            # is more efficient on server side
            if ($CreatedBy.Count -eq 1) {
                $APIAuthor = $CreatedBy
                # adjust Author parameter for API
                # API will match system name for partial match
                # API does not support wild cards
                if ($CreatedBy -imatch '\*') {
                    $APIAuthor = $null
                }
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

        # build the uri for querying
        $uri = Join-Uri `
            -Base $connection.BaseUri `
            -Relative '_apis/tfvc/changesets' `
            -NoTrailingSlash

        $uri = Add-QueryParameter -Uri $uri -Parameters @{
            # All links can be constructed from the changeset data, no need to include them
            # 'searchCriteria.includeLinks'  = 'true'
            'searchCriteria.followRenames' = 'true'
        }

        if ($APIAuthor) {
            $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'searchCriteria.author' = $APIAuthor }
        }

        if ($Branch) {
            $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'searchCriteria.itemPath' = $Branch }
        }

        if ($DateFrom) {
            $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'searchCriteria.fromDate' = (Format-Date $DateFrom) }
        }

        if ($DateTo) {
            $uri = Add-QueryParameter -Uri $uri -Parameters @{ 'searchCriteria.toDate' = (Format-Date $DateTo) }
        }

        # get the data
        # API ignores DateFrom and DateTo when Author filter is applied
        Invoke-ApiListPaged `
            -ApiCredential $connection.ApiCredential `
            -ApiVersion $connection.ApiVersion `
            -Uri $uri `
            -Activity $activity `
            -PageSize 5000 `
        | Where-Object {
            # filter by author
            (!$CreatedBy) `
            -or (
                $_.author `
                | Test-ObjectProperty `
                    -Property 'displayName', 'id', 'uniqueName' `
                    -Pattern $CreatedByPatterns
            )
        } `
        | Where-Object {
            # filter by creationDate
            (!$DateFrom -and !$DateTo) `
            -or (Test-DateTimeRange -Value $_.createdDate -From $DateFrom -To $DateTo)
        }
    }
}
