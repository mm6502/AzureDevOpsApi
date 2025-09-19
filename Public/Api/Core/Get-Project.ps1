function Get-Project {

    <#
        .SYNOPSIS
            Returns detail of a given project.

        .DESCRIPTION
            Returns detail of a given project.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.

        .PARAMETER ApiCredential
            Credentials to use when connecting to Azure DevOps.
            If not specified, $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Parameter')]
    param(
        [Parameter(ParameterSetName = 'Parameter', Position = 0)]
        [Parameter(ParameterSetName = 'Pipeline', Mandatory, ValueFromPipeline)]
        [Alias('Uri')]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        [Parameter(ParameterSetName = 'ProjectConnection', Position = 0, DontShow)]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiProjectConnection')]
        [Alias('Connection','ProjectConnection')]
        $ApiProjectConnection
    )

    process {

        # Get connection to project
        if (!$ApiProjectConnection) {
            $connection = Get-ApiProjectConnection `
                -CollectionUri $CollectionUri `
                -ApiCredential $ApiCredential `
                -Project $Project
        } else {
            $connection = $ApiProjectConnection
        }

        # to get single project, use:
        # GET https://dev-tfs/tfs/internal_projects/_apis/projects/{project_name}?api-version=5.0-preview
        # GET https://dev-tfs/tfs/internal_projects/_apis/projects/{project_id}?api-version=5.0-preview
        $uri = $connection.ProjectUri

        # Make the call
        try {
            $result = Invoke-Api `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri `
                -ErrorAction Stop
        } catch {
            # Try to be smart when reporting the error;
            # Try project name, id and
            $tmpProject = $connection.ProjectName
            if (!$tmpProject) {
                $tmpProject = $connection.ProjectId
            }
            if (!$tmpProject) {
                $tmpProject = $Project
            }
            if (!$tmpProject) {
                $tmpProject = $uri
            }
            # Throw an error
            throw "Failed to get project '$($tmpProject)' from" `
                +" '$($connection.CollectionUri)' due to error: $($_)"
        }

        # Add the project basic properties (Name,ID,URI) to cache
        # for later reuse
        $null = Add-ApiProject `
            -Project $result `
            -CollectionUri $connection.CollectionUri

        # Synchronize ApiCredential for both Project Name and Project ID
        # are registered in CredentialsCache
        $null = Sync-ApiCredentialForProject `
            -Project $result `
            -CollectionUri $connection.CollectionUri `
            -ApiCredential $connection.ApiCredential

        # Return the result
        $result
    }
}
