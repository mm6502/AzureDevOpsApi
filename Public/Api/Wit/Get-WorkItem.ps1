function Get-WorkItem {

    <#
        .SYNOPSIS
            Load details of given work items.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER WorkItem
            List of work items we want to load.
            May be ane of the following:
            - Work Item object (will be loaded again only if $AsOf is also specified)
            - Work Item Ref object
            - Work Item Api Url
                'https://dev-tfs/tfs/internal_projects/ZVJS/_apis/wit/workitems/432371'
            - Work Item Web Url
                'https://dev-tfs/tfs/internal_projects/ZVJS/_workitems/edit/432371'
            - Work Item ID (Project has to be specified, otherwise default project is used)

        .PARAMETER AsOf
            Reference date and time in UTC.
            Takes objects in the state they were in at this date and time.

        .PARAMETER ActivityParentId
            ID of the parent activity.

        .PARAMETER NoProgress
            Flag, indicating that no progress should be reported.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-requests/get-pull-requests-by-project?view=azure-devops-rest-5.1&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [AllowEmptyString()]
        $WorkItem,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        $AsOf,

        [int] $ActivityParentId,

        [switch] $NoProgress
    )

    begin {
        # Prepare progress reporting
        $Activity = "Getting WorkItems"
        $ActivityId = $ActivityParentId + 1
    }

    process {

        $WorkItem | ForEach-Object {

            $current = $_

            # If it is null, skip it
            if (!$current) {
                return
            }

            # Possible inputs:
            # A/ Work Item object (will be loaded again only if $AsOf is also specified)
            # B/ Work Item Ref object
            # C/ Work Item Uri
            # D/ Work Item ID (if Project is specified)

            # If it has Url property
            if ($current.url) {

                # Decide if it is A/ or B/
                if ($current.rev -and $current.fields) {
                    # It is A/
                    if (!$PSBoundParameters.ContainsKey('AsOf')) {
                        # And $AsOf is not specified, just return it
                        $current | Write-Output
                        return
                    }
                }

                # It is B/ or we should load it again
                $current = $current.url
            }

            # Decide if it is C/ or D/
            if ($current | Test-WebAddress) {
                # It is C/
                $uri = $current

                # Allow Remote/Web url to be used
                $uri = $uri -replace '/_workitems/edit/', '/_apis/wit/workitems/'

                # WorkItemUri from WorkItemRef does not contain project part
                try {
                    # Get connection to project
                    $connection = Get-ApiProjectConnection `
                        -CollectionUri $CollectionUri `
                        -Project $uri
                } catch {
                    # Get connection to collection
                    $connection = Get-ApiCollectionConnection `
                        -CollectionUri $CollectionUri
                }
            } else {
                # It is D/

                # Get the project or collection connection
                $connection = Get-ApiProjectConnection `
                    -CollectionUri $CollectionUri `
                    -Project $Project `
                    -AllowFallback:$true

                # Build the Work Item Api Url;
                # this allows to use either Project-scoped or Collection-scoped URLs:
                # GET https://dev.azure.com/{organization}/{project}/_apis/wit/workitems/{id}?fields={fields}&asOf={asOf}&$expand={$expand}&api-version=5.0
                # GET https://dev.azure.com/{organization}/_apis/wit/workitems/{id}?fields={fields}&asOf={asOf}&$expand={$expand}&api-version=5.0
                # The first form is preferred, as with the second form, incorrect credentials may be used.
                $uri = Get-WorkItemApiUrl `
                    -CollectionUri $connection.CollectionUri `
                    -Project $connection.ProjectId `
                    -WorkItem $current
            }

            # Report progress
            # Try to get work item ID from URI
            if ($uri -match '.*_apis/wit/workitems/(\d+)$') {
                $currentId = $Matches[1]
            } else {
                $currentId = '???'
            }

            Write-CustomProgress `
                -Activity $Activity `
                -Status "WorkItem #$($currentId)" `
                -AllItems $WorkItem `
                -Current $_ `
                -Id $ActivityId `
                -ParentId $ActivityParentId `
                -NoProgress:$NoProgress

            # Add Query parameters
            $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{
                '$expand' = 'relations'
            }

            if ($AsOf) {
                $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{
                    'asOf' = Format-Date -Value $AsOf
                }
            }

            # Make the call
            Invoke-Api `
                -Uri $uri `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion
        }
    }

   end {
       if (!$NoProgress.IsPresent -or ($true -ne $NoProgress)) {
            Write-Progress `
                -Activity $Activity `
                -Id $ActivityId `
                -ParentId $ActivityParentId `
                -Completed
       }
   }
}
