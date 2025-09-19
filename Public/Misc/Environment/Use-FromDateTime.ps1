function Use-FromDateTime {

    <#
        .SYNOPSIS
            Gets the FromDateTime to use for given Azure DevOps collection URI.

        .DESCRIPTION
            Gets the FromDateTime to use for given Azure DevOps collection URI.
            If the FromDateTime is not given, will use the default value from
            $global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables).
            If the FromDateTime is not determined, it will default to '2000-01-01T00:00:00Z'

        .PARAMETER FromDateTime
            Date & time of the time period we want to search.

        .OUTPUTS
            [DateTime]
            Date & time of the time period we want to search in UTC.
    #>

    [CmdletBinding()]
    [OutputType([DateTime])]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias(
            'From', 'FromDateTime', 'FromDate', 'FromTime',
            'DateTime', 'DateTimeFrom',
            'Date', 'DateFrom',
            'Time', 'TimeFrom'
        )]
        $Value
    )

    process {

        $candidate = $Value

        # If not given, use default value
        if (!$candidate) {
            $candidate = $global:AzureDevOpsApi_DefaultFromDate
        }

        # If given a string, parse it as a DateTime or fail
        if ($candidate -is [string]) {
            $candidate = [DateTime]::Parse($candidate)
        }

        # If given a DateTime, convert to UTC
        if ($candidate -is [DateTime]) {
            return $candidate.ToUniversalTime()
        }

        # If not determined, return default value
        return [DateTime]::new(2000, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
    }
}
