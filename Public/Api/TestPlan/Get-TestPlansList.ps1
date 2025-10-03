function Get-TestPlansList {

    <#
        .SYNOPSIS
            Gets list of test plans in a given project.

        .DESCRIPTION
            Gets list of test plans in a given project using Azure DevOps Test Plans API.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Owner
            Filter for test plan by owner ID or name.

        .PARAMETER FilterActivePlans
            Get just the active plans.

        .PARAMETER Top
            Count of records per page.

        .PARAMETER Skip
            Count of records to skip before returning the $Top count of records.
            If not specified, iterates the request with increasing $Skip by $Top,
            while records are being returned.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/testplan/test-plans/list?view=azure-devops-rest-7.1
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Pipeline', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'Default', Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [string] $Owner,

        [Alias('Active')]
        [switch] $FilterActivePlans,

        $Top,

        $Skip
    )

    process {

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # GET https://dev.azure.com/{organization}/{project}/_apis/testplan/plans?api-version=7.1
        $uri = Join-Uri `
            -Base $connection.ProjectBaseUri `
            -Relative "_apis/testplan/plans" `
            -NoTrailingSlash

        # Add optional query parameters
        $queryParams = @{}

        $queryParams['includePlanDetails'] = $true

        if ($Owner) {
            $queryParams['owner'] = $Owner
        }

        if ($FilterActivePlans) {
            $queryParams['filterActivePlans'] = $true
        }

        if ($queryParams.Count -gt 0) {
            $uri = Add-QueryParameter `
                -Uri $uri `
                -Parameters $queryParams
        }

        # Make the call
        Invoke-ApiListPaged `
            -ApiCredential:$connection.ApiCredential `
            -ApiVersion:$connection.ApiVersion `
            -Uri:$uri `
            -Top:$Top `
            -Skip:$Skip
    }
}
