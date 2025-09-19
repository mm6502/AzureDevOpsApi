function Get-SubscriptionsList {
    <#
        .SYNOPSIS
            Returns list of service hook subscriptions from the specified project.

        .DESCRIPTION
            Returns list of service hook subscriptions from the specified project in Azure DevOps.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified and could not be determined from $Project,
            $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get subscriptions for. Can be passed as a name, identifier, full project URI,
            or object with any one of these properties.

        .PARAMETER Top
            Count of records per page.

        .PARAMETER Skip
            Count of records to skip before returning the $Top count of records.
            If not specified, iterates the request with increasing $Skip by $Top,
            while records are being returned.

        .EXAMPLE
            Get-SubscriptionsList

            Lists all subscriptions from all projects in the default collection.

        .EXAMPLE
            Get-SubscriptionsList -Project 'MyProject'

            Lists all subscriptions from the specified project in the default collection.

        .EXAMPLE
            $projectsList | Get-SubscriptionsList

            Lists all subscriptions from specified projects.

    #>

    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        $Top,
        $Skip
    )

    process {

        # If paging parameters are specified, determine paging
        $paging = Use-PagingParameters -Top $Top -Skip $Skip

        # If $Project not specified
        if (!$Project) {
            # Get all subscriptions from collection only

            # Get connection object from Collection URI
            $connection = Get-ApiCollectionConnection `
                -Uri $CollectionUri

            # Get subscriptions from collection
            $uri = Join-Uri `
                -Base $connection.CollectionUri `
                -Relative '_apis/hooks/subscriptions' `
                -NoTrailingSlash

            # To list subscriptions, use:
            # GET https://dev.azure.com/{organization}/_apis/hooks/subscriptions?api-version=6.0
            # (this endpoint does not support paging)
            $allSubscriptions = @(
                Invoke-ApiListPaged `
                    -ApiCredential:$connection.ApiCredential `
                    -ApiVersion:$connection.ApiVersion `
                    -Uri:$uri
            )

            $filteredSubscriptions = @($allSubscriptions)
        } else {
            # If $Project is specified, get subscriptions from every collection.
            # To do so get connections for all collections and iterate over them.
            $connections = $Project `
            | ForEach-Object {
                # Get connection object from Collection URI
                Get-ApiProjectConnection `
                    -CollectionUri $CollectionUri `
                    -Project $_ `
                    -AllowFallback
            }

            # Get ProjectIDs from connections to use for filtering
            $projectIds = $connections.ProjectId

            # Group connections by CollectionUri, and get the subscriptions for each collection
            $allSubscriptions = @(
                $connections `
                | Group-Object -Property 'CollectionUri' `
                | ForEach-Object {
                    # Get connection object from Collection URI
                    $connection = Get-ApiCollectionConnection `
                        -Uri $_.Name

                    # Get subscriptions from collection
                    $uri = Join-Uri `
                        -Base $connection.CollectionUri `
                        -Relative '_apis/hooks/subscriptions' `
                        -NoTrailingSlash

                    # To list subscriptions, use:
                    # GET https://dev.azure.com/{organization}/_apis/hooks/subscriptions?api-version=6.0
                    Invoke-ApiListPaged `
                        -ApiCredential:$connection.ApiCredential `
                        -ApiVersion:$connection.ApiVersion `
                        -Uri:$uri
                }
            )

            # Filter subscriptions by project
            $filteredSubscriptions = @(
                $allSubscriptions `
                | Where-Object { $projectIds -contains $_.PublisherInputs.projectId }
            )
        }

        # Return the filtered subscriptions paged as requested
        if (!$paging.ShouldPage) {
            # Ensure we always return an array for PowerShell 5 compatibility
            $filteredSubscriptions
        } else {
            # The Select-Object cmdlet already returns an array
            $filteredSubscriptions `
            | Select-Object `
                -Skip $paging.Skip `
                -First $paging.Top
        }
    }
}
