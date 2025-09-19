function New-WorkItem {

    <#
        .SYNOPSIS
            Create a new work item.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER PatchDocument
            A JSON Patch document describing the work item to create.
            Can be created with New-PatchDocumentCreate.

        .PARAMETER BypassRules
            If set, rules will not be run.

        .PARAMETER ValidateOnly
            If set, only validation will be performed.

        .PARAMETER SuppressNotifications
            If set, notifications will not be sent for this work item.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/create?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument')]
        $PatchDocument,

        [switch] $BypassRules,
        [switch] $ValidateOnly,
        [switch] $SuppressNotifications
    )

    process {

        $PatchDocument | ForEach-Object {

            $currentItem = $_

            # If the patch document is null, do nothing
            if ($null -eq $currentItem) {
                return
            }

            # Determine the where to get the project
            $projectToUse = $Project
            if ($null -eq $projectToUse) {
                $projectToUse = $currentItem.WorkItemUrl
            }

            # Get the project connection
            $connection = Get-ApiProjectConnection `
                -CollectionUri $CollectionUri `
                -Project $projectToUse

            # Get the work item type from the patch document
            $workItemType = $currentItem.WorkItemType

            # Get the uri
            $uri = Join-Uri `
                -BaseUri $connection.ProjectBaseUri `
                -RelativeUri '_apis/wit/workitems/', "`$$($workItemType)"

            if ($BypassRules.IsPresent -and $BypassRules) {
                $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{ 'bypassRules' = $true }
            }

            if ($ValidateOnly.IsPresent -and $ValidateOnly) {
                $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{ 'validateOnly' = $true }
            }

            if ($SuppressNotifications.IsPresent -and $SuppressNotifications) {
                $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{ 'suppressNotifications' = $true }
            }

            # Get the patch document
            if ($currentItem.Operations -is [System.Collections.IEnumerable]) {
                $body = ConvertTo-JsonCustom -Value $currentItem.Operations -Depth 5
            } else {
                $body = ConvertTo-JsonCustom -Value $currentItem.Operations -AsArray -Depth 5
            }

            Write-Debug "Creating work item of type '$($workItemType)' at '$($uri)'`n$($body)"

            # Send the data
            $response = Invoke-Api `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri `
                -Method 'POST' `
                -ContentType 'application/json-patch+json' `
                -Body $body `
                -ErrorAction Stop

            # If the validateOnly flag is set, set a fake id and url
            if ($ValidateOnly.IsPresent -and ($true -eq $ValidateOnly)) {
                # If the response is null, make fake response
                if (!$response) {
                    $response = [PSCustomObject] @{}
                }
                # If the response has no id, take the id from the patch document
                if (!$response.id) {
                    if ($PatchDocument.WorkItemUrl -match '_apis/wit/workitems/(\d+)') {
                        $fakeid = $Matches[1]
                    } else {
                        $fakeid = 0
                    }
                    $response | Add-Member -MemberType NoteProperty -Name 'id' -Value $fakeid
                }
                # If the response has no url, take the url from the patch document
                if (!$response.url) {
                    $fakeurl = $PatchDocument.WorkItemUrl
                    if (!$fakeurl) {
                        $fakeurl = Get-WorkItemApiUrl `
                            -CollectionUri $CollectionUri `
                            -Project $projectToUse `
                            -Id 0
                    }
                    $response | Add-Member -MemberType NoteProperty -Name 'url' -Value $fakeurl
                }
            }

            # Return the response
            if ($response) {
                $response
            }
        }
    }
}
