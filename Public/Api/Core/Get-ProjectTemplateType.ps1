function Get-ProjectTemplateType {

    <#
        .SYNOPSIS
            Gets template type of given project.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Name or identifier of a project in the $CollectionUri.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.
            If input from pipeline, this parameter matched with property 'name' of input object.
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
        $CollectionUri
    )

    begin {
        $key = 'System.Process Template'
    }

    process {

        # Get connection to project
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project

        # Make the call
        $projectTemplateType = Get-ProjectPropertiesList `
            -CollectionUri $connection.CollectionUri `
            -Uri $connection.ProjectId `
            -Keys @($key)

        $templateType = $null
        $templateType = $projectTemplateType.Value

        # If not determined from project properties, try to get it from work item types
        if ($null -eq $templateType) {
            # Try to get template type from work item types
            Write-Verbose "Template type not found in project properties, trying to get it from work item types"

            # Get work item types
            $response = Get-WorkItemTypesList `
                -CollectionUri:$connection.CollectionUri `
                -Project:$connection.ProjectId

            # Determine the template type from work item types
            $templateType = switch ($response.referenceName) {
                'Impediment'  { 'SCRUM'; break; }
                'User Story'  { 'Agile'; break; }
                'Requirement' { 'CMMI';  break; }
            }
        }

        # If piped input, add property to it
        # otherwise just return the value
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            if ($null -ne $templateType) {
                Add-Member `
                    -MemberType NoteProperty `
                    -InputObject $Project `
                    -Name $key `
                    -Value $templateType `
                    -Force
            }
            # Return the altered object
            $Project
        } else {
            # Return the template type
            $templateType
        }
    }
}
