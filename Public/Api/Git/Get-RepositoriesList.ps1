function Get-RepositoriesList {

    <#
        .SYNOPSIS
            Gets list of all commits meeting given criteria.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get repositories for. Can be passed as a name, identifier, full project URI,
            or object with any one these properties.

            If not specified and there is no default in $global:AzureDevOpsApi_Project,
            all repositories in collection will be returned.

        .PARAMETER Repository
            Names of the git repositories to search.
            Can use '*' as wildcard.
            For '*POD' will find 'POD','EPOD'.
            For 'P*D' will find 'PAD','POD'.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/git/repositories/list?view=azure-devops-rest-5.1&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]] $Repository = @('*'),

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri
    )

    begin {
        Write-Verbose ($MyInvocation.MyCommand.Name)
    }

    process {

        $Repository | ForEach-Object {

            $current = $_

            # If Repository is a URL, use it as project determining connection;
            # And expand list of properties used to filter results
            $properties = @('name', 'id')
            if ($current | Test-WebAddress) {
                $Project = $current
                $properties += 'url', 'remoteUrl', 'webUrl'
            }

            # Get connection to collection od project
            # If project is not specified,
            # We do not want to allow fallback to collection connection,
            # we would need to enumerate project connections to use the right credentials.
            $connection = Get-ApiProjectConnection `
                -CollectionUri $CollectionUri `
                -Project $Project `
                -AllowFallback:$false

            # official uri:
            # GET https://dev.azure.com/{organization}/{project}/_apis/git/repositories
            # ?includeLinks={includeLinks}&includeAllUrls={includeAllUrls}&includeHidden={includeHidden}&api-version=5.1
            # but also works without project:
            # GET https://dev.azure.com/{organization}/_apis/git/repositories
            $uri = Join-Uri `
                -Base $connection.BaseUri `
                -Relative '_apis/git/repositories' `
                -NoTrailingSlash

            # Make the call
            # and filter out repositories without matching name or id
            Invoke-ApiListPaged `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri `
            | Select-ByObjectProperty -Property $properties -Pattern $current
        }
    }
}
