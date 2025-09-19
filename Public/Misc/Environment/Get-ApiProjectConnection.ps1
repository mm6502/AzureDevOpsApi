function Get-ApiProjectConnection {

    <#
        .SYNOPSIS
            Creates a connection object to a project in Azure DevOps.

        .DESCRIPTION
            Creates a connection object to a project in Azure DevOps.

            The $Project parameter can be a project object, a project name, a project ID,
            or a project URI.

            This function will try to find the project in the cache first.
            If the project is not found in the cache, it will try to construct it from given parameters.

            The returned connection object has the following properties:
            - CollectionUri: The URI of the collection the project belongs to.
            - ApiVersion: The API version to use for the connection.
            - ApiCredential: The API credential to use for the connection.
            - ProjectUri: The URI of the project.
            - ProjectId: The ID of the project.
            - ProjectName: The name of the project.
            - ProjectBaseUri: The base URI for the project's resources.

        .PARAMETER Project
            The project to create a connection for.

        .PARAMETER CollectionUri
            The URI of the collection the project belongs to.

        .PARAMETER ApiCredential
            The API credential to use for the connection.

        .PARAMETER Patterns
            A list of additional patterns to use to extract the Project and CollectionUri
            when the Project parameter is an Uri.

        .PARAMETER AllowFallback
            If set, the function will try to construct the project connection.
            If the project could not be determined, or is not found in the cache,
            it will try to return a collection connection.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Patterns,

        [Alias('WithFallback', 'Fallback')]
        [switch] $AllowFallback
    )

    process {

        # Try to get the project from the cache
        $projectObj = Resolve-ApiProject `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -Patterns $Patterns

        # We get object in any case, even if the project is not found in cache
        # We need the connection object to get the project's properties
        $connection = Get-ApiCollectionConnection `
            -Uri $projectObj.CollectionUri `
            -ApiCredential $ApiCredential

        # Fail, if no connection object could be constructed
        if (!$connection) {
            throw "Could not create a connection to project: $($Project)"
        }

        # Initialize credential variable
        $credentialX = $null

        # Try by ProjectId
        if (!$credentialX) {
            $credentialX = Find-ApiCredential `
                -CollectionUri $connection.CollectionUri `
                -Project $projectObj.ProjectId
        }

        # Try by ProjectName
        if (!$credentialX) {
            $credentialX = Find-ApiCredential `
                -CollectionUri $connection.CollectionUri `
                -Project $projectObj.ProjectName
        }

        if (!$connection.ApiCredential -and $credentialX) {
            $connection.ApiCredential = $credentialX
        }

        # Make the Project Connection object
        $result = New-ApiProjectConnection `
            -ApiCollectionConnection $connection `
            -ProjectUri $projectObj.ProjectUri `
            -ProjectBaseUri $projectObj.ProjectBaseUri `
            -ProjectId $projectObj.ProjectId `
            -ProjectName $projectObj.ProjectName `
            -Verified $projectObj.Verified

        # If the project is found in cache, we have correct values
        if ($projectObj.Verified) {
            # Return the connection object
            return $result
        }

        # If the project is not found in cache, try to resolve it via API
        # If no project identifier could be determined at all, check fallback option
        if (!$projectObj.ProjectId -and !$projectObj.ProjectName) {
            if ($AllowFallback -and ($true -eq $AllowFallback)) {
                return $connection
            } else {
                throw "Could not determine project to connect to."
            }
        }

        # If no project URI could be constructed, try to get the project by calling the api
        # Construct the temporary project URI with project name
        if (!$result.ProjectUri) {
            $result.ProjectUri = Join-Uri `
                -Base $connection.CollectionUri `
                -Relative '_apis/projects', $result.ProjectName `
                -NoTrailingSlash
        }

        # Get the project from the pre constructed connection
        $projectObj = Get-Project -ApiProjectConnection $result

        # Correct the resulting connection, if the project was found
        return Get-ApiProjectConnection `
            -Project $projectObj.url `
            -ApiCredential $result.ApiCredential `
            -CollectionUri $result.CollectionUri
    }
}
