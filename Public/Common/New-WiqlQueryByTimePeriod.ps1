function New-WiqlQueryByTimePeriod {

    <#
        .SYNOPSIS
            Creates a WIQL query that returns all work items of the types given by the WorkItemTypes parameter,
            which were switched to the Resolved state in the specified time frame and are in this state
            at the query launch or the time specified with AsOf parameter.

        .PARAMETER Project
            Name or identifier of a project in the $Collection.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER WorkItemTypes
            List of types of work items that interest us.
            Default value is @('Requirement', 'Bug').

        .PARAMETER DateFrom
            Start of the time interval we want to search.

        .PARAMETER DateTo
            End of the time interval we want to search.
            If not specified, UTCNow is used.

        .PARAMETER AsOf
            Reference date and time. For the purposes of the WIQL query, it takes the objects
            in the state they were in at this date and time.
            If not specified, UTCNow is used.

        .PARAMETER DateAttribute
            Attribute name against which the date parameters will be compared.
            Default value is 'System.ChangedDate'.

        .NOTES
            https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/wiql/query-by-wiql?view=azure-devops-rest-5.0&tabs=HTTP
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = ''
    )]
    [CmdletBinding()]
    param(
        $Project = $global:AzureDevOpsApi_Project,

        [Parameter()]
        [Alias('WITypes', 'WIType', 'Types', 'Type')]
        [string[]]$WorkItemTypes = @('Requirement', 'Bug'),

        [Parameter()]
        [Alias('WIStates', 'WIState', 'States', 'State')]
        [string[]]$WorkItemStates = @(),

        [Alias('Start', 'From', 'FromDate')]
        $DateFrom = $global:AzureDevOpsApi_DefaultFromDate,

        [Alias('End', 'To', 'ToDate')]
        $DateTo = [DateTime]::UtcNow,

        $AsOf = $DateTo,

        $DateAttribute = 'System.ChangedDate'
    )

    process {
        $WITypesAsString = $WorkItemTypes -join "','"
        $WIStatesAsString = $WorkItemStates -join "','"

        $query = (@"
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE
[System.TeamProject] = '$($Project)'
"@)

        if ($WorkItemTypes) {
            $query += " AND [System.WorkItemType] IN ('$($WITypesAsString)')"
        }

        if ($WorkItemStates) {
            $query += " AND [System.WorkItemType] IN ('$($WIStatesAsString)')"
        }

        if ($DateFrom) {
            if ($DateFrom -is [DateTime]) {
                $DateFrom = Format-Date -Value $DateFrom
            }
            if (-not $DateFrom.StartsWith('@')) {
                $DateFrom = "'$($DateFrom)'"
            }
            $query += " AND [$($DateAttribute)] >= $($DateFrom) "
        }

        if ($DateTo) {
            if ($DateTo -is [DateTime]) {
                $DateTo = Format-Date -Value $DateTo
            }
            if (-not $DateTo.StartsWith('@')) {
                $DateTo = "'$($DateTo)'"
            }
            $query += " AND [$($DateAttribute)] <= $($DateTo) "
        }

        if ($AsOf) {
            if ($AsOf -is [DateTime]) {
                $AsOf = Format-Date -Value $AsOf
            }
            if (-not $AsOf.StartsWith('@')) {
                $AsOf = "'$($AsOf)'"
            }
            $query += " ASOF $($AsOf) "
        }

        return $query
    }
}
