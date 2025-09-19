function ConvertTo-ExportData {

    <#
        .SYNOPSIS
            Converts set of ReleaseNotesDataItems to ExportData.

        .PARAMETER ItemsList
            List of ReleaseNotesDataItems.

        .PARAMETER ItemsTable
            Hashtable of ReleaseNotesDataItems, key is WorkItemId as string.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_Collection (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Name or identifier of a project in the $Collection.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateFrom
            Starting date & time of the time period.
            If not specified, $global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateTo
            Ending date & time of the time period.
            If not specified, [DateTime]::UTCNow is used.

        .PARAMETER AsOf
            Reference date and time in UTC.
            Objects are listed in the state they were in at this date and time.

        .PARAMETER ByUser
            Only pull requests created by given users will be returned.

        .PARAMETER TargetBranch
            The target branch of pull requests.

        .PARAMETER TrunkBranch
            The trunk branch of TFVC repositories.

        .PARAMETER ReleaseBranch
            The release branch of TFVC repositories.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.ExportData')]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem')]
        [Parameter(Mandatory, ParameterSetName = 'List', Position = 1)]
        [Alias('Items')]
        [object[]] $ItemsList,

        [Parameter(Mandatory, ParameterSetName = 'HashTable', Position = 1)]
        [hashtable] $ItemsTable,

        $CollectionUri,
        $Project,
        $DateFrom,
        $DateTo,
        $AsOf,
        $ByUser,
        $TargetBranch,
        $TrunkBranch,
        $ReleaseBranch
    )

    begin {
        $result = New-ExportData

        # Convert list to hashtable
        if ($PSCmdlet.ParameterSetName -ieq 'List') {
            $ItemsTable = @{}
            foreach ($item in $ItemsList) {
                $ItemsTable[$item.ApiUrl] = $item
            }
        }

        # Remove items that are to be excluded
        $toBeExcluded = $ItemsTable.GetEnumerator() | Where-Object { $true -eq $_.Value.Exclude }
        if ($toBeExcluded) {
            $toBeExcluded.Key | ForEach-Object { $ItemsTable.Remove($_) }
        }

        # Prepare the Release info
        $result.Release = ConvertTo-ExportDataRelease `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -DateFrom $DateFrom `
            -DateTo $DateTo `
            -AsOf $AsOf `
            -ByUser $ByUser `
            -TargetBranch $TargetBranch `
            -TrunkBranch $TrunkBranch `
            -ReleaseBranch $ReleaseBranch
    }

    process {

        # Console
        $result.Console += @(ConvertTo-ExportDataConsole -Items $ItemsTable)

        # Relations
        $result.Relations += @(ConvertTo-ExportDataRelations -Items $ItemsTable)

        # WorkItems
        $result.WorkItems += @(ConvertTo-ExportDataWorkItems -Items $ItemsTable)
    }

    end {
        $result
    }
}
