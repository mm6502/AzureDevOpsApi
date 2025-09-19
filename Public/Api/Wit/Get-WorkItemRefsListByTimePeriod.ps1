function Get-WorkItemRefsListByTimePeriod {

    <#
        .SYNOPSIS
            Return the list of work items for the release notes / change list.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Project to get. Can be passed as a name, identifier, full project URI, or object with any one
            these properties.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateFrom
            Start of the time interval we want to search.

        .PARAMETER DateTo
            End of the time interval we want to search.
            If not specified, the beginning of tomorrow's day is used.
            I.e. including all changes today, up to the moment the query is run.

        .PARAMETER AsOf
            Reference date and time. Takes objects in the state they were in at this date and time.
            If not specified, the value from DateTo will be used.
            I.e. including all changes today, up to the moment the query is run.

        .PARAMETER WorkItemTypes
            List of work item types of interest.
            Default value is @('Requirement', 'Bug', 'Task')

        .PARAMETER DateAttribute
            Attribute name against which the date parameters will be compared.
            Default value is 'System.ChangedDate'.
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        $Project,

        [AllowNull()]
        [AllowEmptyString()]
        $CollectionUri,

        $DateFrom,
        $DateTo,
        $AsOf,

        [string[]]$WorkItemTypes = @('Requirement', 'Bug', 'Task'),

        $DateAttribute = 'System.ChangedDate'
    )

    begin {
        # Correct parameters
        $DateTo = Use-ToDateTime -Value $DateTo
        $AsOf = Use-AsOfDateTime -Value $AsOf -DateTo $DateTo

        # Collect the url in a hashset to avoid duplicates
        $result = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    process {

        # Get Project or Collection Connection
        $connection = Get-ApiProjectConnection `
            -CollectionUri $CollectionUri `
            -Project $Project `
            -AllowFallback

        # Create the query
        $query = New-WiqlQueryByTimePeriod `
            -Project $connection.ProjectName `
            -DateFrom $DateFrom `
            -DateTo $DateTo `
            -AsOf $AsOf `
            -WorkItemTypes $WorkItemTypes `
            -DateAttribute $DateAttribute

        # Get Work Item Ref's by Query
        $response = Invoke-WorkItemsQuery `
            -CollectionUri $connection.CollectionUri `
            -Project $connection.ProjectId `
            -Query $query

        # Add the work item ids to the result
        $response.workItems | ForEach-Object {
            if (![string]::IsNullOrWhiteSpace($_.url)) {
                if (!$result.Contains($_.url)) {
                    $null = $result.Add($_.url)
                    $_ | Write-Output
                }
            }
        }
    }
}
