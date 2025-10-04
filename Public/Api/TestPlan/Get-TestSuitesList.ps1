function Get-TestSuitesList {

    <#
        .SYNOPSIS
            Gets list of test suites for a test plan.

        .DESCRIPTION
            Gets list of test suites for a test plan using Azure DevOps Test Plans API.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Plan
            Test plan object (with id and project properties) or test plan ID.
            When providing an object, the Project and CollectionUri are extracted from it.
            When providing an ID, relies on Project and CollectionUri parameters or global defaults.

        .PARAMETER Expand
            Include children suites and/or default testers details.
            Valid values: None, Children, DefaultTesters.
            Can be combined, e.g., "Children, DefaultTesters".

        .PARAMETER AsTreeView
            If the suites returned should be in a tree structure.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/testplan/test-suites/get-test-suites-for-plan?view=azure-devops-rest-7.1

            This API uses continuation token pagination. The function automatically iterates through
            all pages using the x-ms-continuationtoken response header.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromId')]
    param(
        [Parameter(ParameterSetName = 'FromPipeline', Mandatory, ValueFromPipeline)]
        [AllowNull()]
        $InputObject,

        [Parameter(ParameterSetName = 'FromId', Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [Parameter(ParameterSetName = 'FromId')]
        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Parameter(ParameterSetName = 'FromId', Mandatory, Position = 1)]
        [Alias('TestPlan','TestPlanId', 'PlanId', 'Id')]
        $Plan,

        [ValidateSet('None', 'Children', 'DefaultTesters')]
        [string]
        $Expand,

        [switch]
        $AsTreeView
    )

    process {

        # Handle pipeline input
        if ($null -ne $InputObject) {
            $Plan = $InputObject
        }

        # Extract plan ID and project information from plan object if needed
        $planId = $null
        if ($Plan -is [PSObject] -and $Plan.project -and $Plan.id) {
            # Use project from plan object if available
            $Project = $Plan.project
            # It's a plan object with an id property
            $planId = $Plan.id
        } elseif ($Plan -match '^\d+$') {
            # It's a plan ID
            $planId = [int]$Plan
        } else {
            throw "Plan must be a test plan object with an 'id' property or a numeric plan ID."
        }

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # GET https://dev.azure.com/{organization}/{project}/_apis/testplan/Plans/{planId}/suites?api-version=7.1
        $uri = Join-Uri `
            -Base $connection.ProjectBaseUri `
            -Relative "_apis/testplan/Plans/$($planId)/suites" `
            -NoTrailingSlash

        # Add optional query parameters
        $queryParams = @{}

        if ($Expand) {
            $queryParams['expand'] = $Expand
        }

        if ($AsTreeView) {
            $queryParams['asTreeView'] = $true
        }

        if ($queryParams.Count -gt 0) {
            $uri = Add-QueryParameter `
                -Uri $uri `
                -Parameters $queryParams
        }

        # Make the call
        Invoke-ApiListPagedWithContinuationToken `
            -ApiCredential:$connection.ApiCredential `
            -ApiVersion:$connection.ApiVersion `
            -Uri:$uri
    }
}
