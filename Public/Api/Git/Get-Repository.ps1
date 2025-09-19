function Get-Repository {
    <#
        .SYNOPSIS
            Returns a repository.

        .DESCRIPTION
            Returns a repository.

        .PARAMETER Rpository
            Rpository to load. Valid inputs:
            - Rpository Api url
              'https://dev-tfs/tfs/internal_projects/ZVJS/_apis/git/repositories/zvjs_feoo'
            - Rpository Web/Remote url
              'https://dev-tfs/tfs/internal_projects/ZVJS/_git/zvjs_feoo'
            - Pull request id or name. CollectionUri and Project must also be specified,
              otherwise defaults will be used.
              zvjs_feoo
              96e0832a-94a2-4c0c-887e-48b8f3d2e7ed

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            Can be ommitted if $CollectionUri was previously accessed via this API.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            Can be ommitted if $Project was previously accessed via this API (will be extracted from the $ArtifactUri).
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .EXAMPLE
            # All items represent the same repository
            # Assuming project was accessed previously
            Get-Repository -Repository @(
                'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/repositories/zvjs_feoo'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo'
                'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed'
                'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed'
            )

        .EXAMPLE
            In case the project was not accessed previously, ApiCredentials must be specified:
            Get-Repository `
                -CollectionUri 'https://dev-tfs/tfs/internal_projects/' `
                -Project 'zvjs' `
                -Repository 'zvjs_feoo' `
                -ApiCredential $credential
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [AllowEmptyString()]
        $Repository,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project
    )

    process {

        $Repository | ForEach-Object {

            if (!$Repository) {
                return
            }

            # If repository is already an object, just return it
            if ($Repository.id -and $Repository.project.id -and $Repository.defaultBranch) {
                return $Repository
            }

            # Possible values:
            # A/ Repository Uri
            # B/ Repository name or ID, CollectionUri

            # A/ Repository Uri
            # {CollectionUri}/{Project}/
            # _apis/git/repositories/{Repository}
            # _apis/git/repositories/fccd7d08-bf7c-4995-a1e5-60524f9aab20

            # Try for url
            $maybeUrl = Use-Value -ValueA $_.url -ValueB $_

            # If it is an url, try to load the repository
            if ($maybeUrl | Test-WebAddress) {

                # Convert the remote/web url to an api url
                $maybeUrl = $maybeUrl -replace '/_git/','/_apis/git/repositories/'

                # Get the project connection
                $projectConnection = Get-ApiProjectConnection `
                    -Project $maybeUrl `
                    -CollectionUri $CollectionUri

                # Make the call
                $response = Invoke-Api `
                    -Uri $maybeUrl `
                    -ApiCredential $projectConnection.ApiCredential `
                    -ApiVersion $projectConnection.ApiVersion `

                if ($response) {
                    $response
                }

                return
            }

            # B/ Repository Name or ID, CollectionUri
            # Get the project connection
            $projectConnection = Get-ApiProjectConnection `
                -Project $Project `
                -CollectionUri $CollectionUri

            # Get the repository uri
            $uri = Join-Uri `
                -Base $projectConnection.ProjectBaseUri `
                -Relative  '_apis/git/repositories', $_ `
                -NoTrailingSlash

            # Make the call
            $response = Invoke-Api `
                -Uri $uri `
                -ApiCredential $projectConnection.ApiCredential `
                -ApiVersion $projectConnection.ApiVersion

            if ($response) {
                $response
            }
        }
    }
}
