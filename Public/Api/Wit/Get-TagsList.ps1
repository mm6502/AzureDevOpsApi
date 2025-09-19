function Get-TagsList {

    <#
        .SYNOPSIS
            Gets list of tags used on the work items in given project.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Include
            The strings to include. Default is to include all.

        .PARAMETER Exclude
            The strings to exclude. Default is to exclude none.

        .PARAMETER CaseSensitive
            Switch to control case sensitivity of the filters. Default is to be case insensitive.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/tags/list?view=azure-devops-rest-6.0&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [string[]] $Include = @('*'),

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Exclude = @(),

        [switch] $CaseSensitive
    )

    process {

        # Get the project connection
        $connection = Get-ApiProjectConnection `
            -Project $Project `
            -CollectionUri $CollectionUri

        # API is avaliable only in 6.0-preview
        # https://dev-tfs/tfs/internal_projects/SIZP_KSED/_apis/wit/tags?api-version=6.0-preview
        if ($connection.ApiVersion -lt '6.0') {
            $connection.ApiVersion = '6.0'
        }
        if ($connection.ApiVersion -notlike '*-preview*') {
            $connection.ApiVersion += '-preview'
        }

        # Build the URI
        $uri = Join-Uri `
            -BaseUri $connection.CollectionUri `
            -RelativeUri $connection.ProjectId, '_apis/wit/tags' `
            -NoTrailingSlash

        # Invoke the API
        Invoke-ApiListPaged `
            -ApiVersion $connection.ApiVersion `
            -ApiCredential $connection.ApiCredential `
            -Uri $uri `
        | Where-Object {
            # Filter the results
            $_.name | Test-StringMasks -Include $Include -Exclude $Exclude -CaseSensitive:$CaseSensitive
        }
    }
}
