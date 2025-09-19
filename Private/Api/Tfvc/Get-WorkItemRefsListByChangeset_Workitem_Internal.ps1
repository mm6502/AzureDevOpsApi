function Get-WorkItemRefsListByChangeset_Workitem_Internal {

    <#
        .SYNOPSIS
            Returns a list of work item identifiers associated with the given pull request.

        .PARAMETER ApiVersion
            Requested version of Azure DevOps API.
            If not specified, $global:AzureDevOpsApi_ApiVersion (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Collection
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_Collection (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Changeset
            Pull request object loaded from API.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/tfvc/changesets/get-changeset-work-items?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        $Changeset,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [AllowNull()]
        [AllowEmptyString()]
        $Project
    )

    # Url variant:
    # {Collection}/_apis/tfvc/changesets/{Changeset}/workitems

    # "ID" variant - identifier of a pull request:
    # (infering from content of '_links' section in "Detail" variant)
    # The list of linked work items is on the relative path to the url from the "Detail" variant:
    # {Collection}/_apis/tfvc/changesets/{id}/workitems

    process {

        $Changeset | ForEach-Object {

            $item = $_

            # Skip empty items
            if (!$item) {
                return
            }

            # if we have a 'workItems' section, just follow the links or read by id
            if ($item.changesetId -and $item.workItems) {
                $url = $item.workItems.href
            } else {
                $url = Join-Uri `
                    -BaseUri $CollectionUri `
                    -RelativeUri '_apis/tfvc/changesets', $item.changesetId, 'workitems' `
                    -NoTrailingSlash
            }

            # Get Project Connection
            $connection = Get-ApiProjectConnection `
                -CollectionUri $CollectionUri `
                -Project $Project

            # if we have a url we can make a shortcut - the link to
            # the list of linked work items in the '_links' section
            # is a link to the pull request + '/workitems'
            $list = Invoke-ApiListPaged `
                -ApiCredential $connection.ApiCredential `
                -Uri $url

            if (!$list.id) {
                return
            }

            $list | ForEach-Object {
                [PSCustomObject] @{
                    # https://dev-tfs/tfs/internal_projects/FS_TKD-TARIC/_apis/wit/workitems/241969
                    url = Get-WorkItemApiUrl `
                        -CollectionUri $connection.CollectionUri `
                        -Project $connection.ProjectId `
                        -WorkItem $_.id
                }
            }
        }
    }
}
