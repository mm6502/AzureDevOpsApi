function Get-WorkItemRefsListByChangeset {

    <#
        .SYNOPSIS
            Return the list of work item ids referenced in given changesets.

        .DESCRIPTION
            Return the list of work item ids referenced in given changesets.
            Combines consecutive calls to Get-ChangesetsList and Get-ChangesetAssociatedWorkItemIds.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER CreatedBy
            Author of the commits.
            API searches for partial match on system name and display name.
            For '*Mra*' will find 'Michal Mracka' (system name 'DITEC\mracka')
            For 'M*a' will find 'Michal Mracka' (system name 'DITEC\mracka')

        .PARAMETER TargetBranch
            Name of a branch to search.

        .PARAMETER DateFrom
            Lists commits created on or after specified date time.

        .PARAMETER DateTo
            Lists commits created on or before specified date time.
    #>

    [OutputType([string[]])]
    [CmdletBinding(DefaultParameterSetName = 'Parameters')]
    param(
        [Parameter(ParameterSetName = 'Pipeline', ValueFromPipeline)]
        [Alias('InputObject')]
        $Changeset,

        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('FromDate', 'From')]
        $DateFrom,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('ToDate', 'To')]
        $DateTo,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('Branch')]
        [string] $TargetBranch,

        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('Author')]
        $CreatedBy
    )

    begin {
        # Collect the ids in a hashset to avoid duplicates
        $workItemUris = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        $CollectionUri = Use-CollectionUri -CollectionUri $CollectionUri
        $Project = Use-Project -Project $Project

        # If invoked via Parameters, get the PullRequests
        if ($PSCmdlet.ParameterSetName -ne 'Pipeline') {

            # Get the PullRequests
            $Changeset = @(Get-ChangesetsList `
                -Project $Project `
                -CollectionUri $CollectionUri `
                -TargetBranch $TargetBranch `
                -DateFrom $DateFrom `
                -DateTo $DateTo `
                -CreatedBy $CreatedBy
            )

            if (!$Changeset) {
                return
            }
        }
    }

    process {

        $Changeset | ForEach-Object {

            $current = $_

            # If we don't have a changeset, skip it...
            if (!$current) {
                return
            }

            # Ensure we actually have a changeset object, not just ID for example...
            $current = Get-Changeset `
                -CollectionUri $CollectionUri `
                -Project $Project `
                -Changeset $current

            # If we don't have a changeset, skip it...
            if (!$current) {
                return
            }

            # Get WorkItemRefs from Changesets
            Get-WorkItemRefsListByChangeset_Workitem_Internal `
                -CollectionUri $CollectionUri `
                -Project $current.Project `
                -Changeset $current
        } `
        | ForEach-Object {
            # Add the WorkItemRefs to the result
            if (![string]::IsNullOrWhiteSpace($_.url)) {
                if (!$workItemUris.Contains($_.url)) {
                    $null = $workItemUris.Add($_.url)
                    $_ | Write-Output
                }
            }
        }
    }
}
