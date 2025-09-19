function Set-ProjectProperty {

    <#
        .SYNOPSIS
            Sets properties of given project.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Property
            Dictionary, HashTable, or PSCustomObject of properties to set.

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

        [Alias('Properties', 'Value', 'Values')]
        [AllowNull()]
        [AllowEmptyCollection()]
        $Property = @{}
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

        # Convert PSCustomObject to hashtable
        $PropertyHashTable = ConvertTo-HashTable -Value $Property

        # Create new patch document
        $patchDocument = @()

        # Add each property to patch document
        foreach ($item in $PropertyHashTable.GetEnumerator())
        {
            # Add property to patch document

            # Determine key and value
            $key = $item.Key
            $value = $item.Value

            # Determine operation
            # If value is null, remove property
            if ($null -eq $value) {
                $operation = 'remove'
            }
            else {
                $operation = 'add'
            }

            # Create property change object
            $propertyChange = @{
                op    = $operation
                path  = "/$($key)"
            }

            if ($null -ne $value) {
                $propertyChange['value'] = $value
            }

            # Add property to patch document
            $patchDocument += $propertyChange
        }

        # Create body
        $body = ConvertTo-JsonCustom -Value $patchDocument

        # Make the call
        Invoke-Api `
            -ApiCredential $connection.ApiCredential `
            -ApiVersion $connection.ApiVersion `
            -Method 'PATCH' `
            -Uri $uri `
            -ContentType 'application/json-patch+json' `
            -Body $body
    }
}
