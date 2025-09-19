function Get-ProjectPropertiesList {

    <#
        .SYNOPSIS
            Gets properties of given project.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Keys
            List of property keys to get.
            Wildcard characters ("?" and "*") are supported.
            If no key is specified, all properties will be returned.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/get-project-properties?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding(DefaultParameterSetName = 'Parameter')]
    param(
        [Parameter(ParameterSetName = 'Parameter', Position = 0)]
        [Parameter(ParameterSetName = 'Pipeline', Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Uri')]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Alias('Property', 'Properties')]
        $Keys = @()
    )

    process {
        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # API needs $ProjectID
        $uri = Join-Uri `
            -Base $connection.ProjectUri `
            -Relative "properties" `
            -NoTrailingSlash

        # GET https://dev.azure.com/{organization}/_apis/projects/{projectId}/properties?keys={keys}&api-version=5.1-preview.1
        if ($connection.ApiVersion -notlike '*-preview*') {
            $connection.ApiVersion += '-preview.1'
        }

        # Add keys to retrieve as query parameters
        if ($Keys) {
            $joined = if ($Keys.Count -gt 0) { $Keys -join ',' } else { '*' }
            $uri = Add-QueryParameter -Uri $uri -Parameters ([PSCustomObject] @{ "keys" = $joined })
        }

        # Make the call
        Invoke-ApiListPaged `
            -ApiCredential $connection.ApiCredential `
            -ApiVersion $connection.ApiVersion `
            -Uri $uri
    }
}
