function Get-TestSuiteTestCasesList {

    <#
        .SYNOPSIS
            Gets list of test cases for a test suite.

        .DESCRIPTION
            Gets list of test cases for a test suite using Azure DevOps Test Plans API.

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
            Optional if Suite object has TestPlanId or plan property.

        .PARAMETER Suite
            Test suite object (with id and optionally TestPlanId or plan property) or test suite ID.
            Can be piped from Get-TestSuitesList.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/test/test-case/list?view=azure-devops-rest-5.0
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

        [Parameter(ParameterSetName = 'FromId', Position = 1)]
        [Alias('PlanId', 'Id')]
        $Plan,

        [Parameter(ParameterSetName = 'FromId', Mandatory, Position = 2)]
        [Alias('SuiteId')]
        $Suite
    )

    process {

        # Handle pipeline input
        if ($null -ne $InputObject) {
            # Check if InputObject has plan property (indicates it's a suite object)
            if ($InputObject -and $InputObject.plan.id) {
                # This is a suite object with plan property
                $Suite = $InputObject
                $Plan = $InputObject.plan
                # If suite has project property, use it
                if ($InputObject.project) {
                    $Project = $InputObject.project
                }
            } elseif ($InputObject -and $InputObject.id) {
                # Check if it has typical plan properties (project and id without plan property)
                if ($InputObject.project -and -not $InputObject.plan) {
                    # Treat as plan object
                    $Plan = $InputObject
                } else {
                    # Treat as suite object
                    $Suite = $InputObject
                }
            } else {
                # Otherwise treat as plan object
                $Plan = $InputObject
            }
        }

        # If Suite is provided and has plan property but Plan is not set, extract it
        if ($null -eq $Plan -and $Suite -and $Suite.plan.id) {
            $Plan = $Suite.plan
        }

        # Extract plan ID and project information from plan object if needed
        $planId = $null
        if ($null -eq $Plan) {
            throw "Plan must be specified either directly or via a Suite object with TestPlanId or plan property."
        }

        # Handle hashtable or PSObject with id property
        if ($Plan -and $Plan.id) {
            # Use project from plan object if available
            if ($Plan.project) {
                $Project = $Plan.project
            }
            # It's a plan object with an id property
            $planId = $Plan.id
        } elseif ($Plan -match '^\d+$') {
            # It's a plan ID
            $planId = [int]$Plan
        } else {
            throw "Plan must be a test plan object with an 'id' property or a numeric plan ID."
        }

        # Extract suite ID from suite object if needed
        $suiteId = $null
        if ($Suite -and $Suite.id) {
            # It's a suite object with an id property
            $suiteId = $Suite.id
        } elseif ($Suite -match '^\d+$') {
            # It's a suite ID
            $suiteId = [int]$Suite
        } else {
            throw "Suite must be a test suite object with an 'id' property or a numeric suite ID."
        }

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # GET https://dev.azure.com/{organization}/{project}/_apis/testplan/Plans/{planId}/Suites/{suiteId}/testcase?api-version=5.0
        $uri = Join-Uri `
            -Base $connection.ProjectBaseUri `
            -Relative "_apis/testplan/Plans/$($planId)/Suites/$($suiteId)/testcase" `
            -NoTrailingSlash

        # Documentation is wrong here:
        # Minimum api-version is 5.1, not 5.0-preview.2 as documented
        if ($connection.ApiVersion -lt [Version]'5.1') {
            $connection.ApiVersion = [Version]'5.1'
        }

        # Make the call
        Invoke-ApiListPaged `
            -ApiCredential:$connection.ApiCredential `
            -ApiVersion:$connection.ApiVersion `
            -Uri:$uri
    }
}
