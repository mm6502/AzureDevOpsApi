function Update-WorkItem {

    <#
        .SYNOPSIS
            Updates an axisting work item.

        .PARAMETER PatchDocument
            A JSON Patch document describing changes to be made.
            Can be created with New-PatchDocumentCreate.

        .PARAMETER BypassRules
            If set, rules will not be run.

        .PARAMETER ValidateOnly
            If set, only validation will be performed.

        .PARAMETER SuppressNotifications
            If set, notifications will not be sent for this work item.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/update?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [OutputType('PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument')]
        [AllowNull()]
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

            # Get the uri
            $uri = $currentItem.WorkItemUrl

            if ($BypassRules.IsPresent -and $BypassRules -eq $true) {
                $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{ 'bypassRules' = $true }
            }

            if ($ValidateOnly.IsPresent -and $ValidateOnly -eq $true) {
                $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{ 'validateOnly' = $true }
            }

            if ($SuppressNotifications.IsPresent -and $SuppressNotifications -eq $true) {
                $uri = Add-QueryParametersToUri -Uri $uri -Parameters @{ 'suppressNotifications' = $true }
            }

            # Get the patch document
            if ($currentItem.Operations -is [System.Collections.IEnumerable]) {
                $body = ConvertTo-JsonCustom -Value $currentItem.Operations -Depth 5
            } else {
                $body = ConvertTo-JsonCustom -Value $currentItem.Operations -AsArray -Depth 5
            }

            Write-Debug "Updating work item at '$($uri)'`n$($body)"

            # Get Project Connection
            $connection = Get-ApiProjectConnection `
                -Project $uri

            # Send the data
            $response = Invoke-Api `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri `
                -Method 'PATCH' `
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
                    }
                    $response | Add-Member -MemberType NoteProperty -Name 'id' -Value $fakeid
                }
                # If the response has no url, take the url from the patch document
                if (!$response.url) {
                    $fakeurl = $PatchDocument.WorkItemUrl
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
