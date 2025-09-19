function Use-ToDateTime {

    <#
        .SYNOPSIS
            Gets the ToDateTime to use for given Azure DevOps collection URI.

        .DESCRIPTION
            Gets the ToDateTime to use for given Azure DevOps collection URI.
            If the ToDateTime is not given, will use the current date & time in UTC.

        .PARAMETER ToDateTime
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
            'To', 'ToDateTime', 'ToDate', 'ToTime',
            'DateTime', 'DateTimeTo',
            'Date', 'DateTo',
            'Time', 'TimeTo'
        )]
        $Value = $null
    )

    process {

        $candidate = $Value

        # If not given, use default value
        if (!$candidate) {
            return [DateTime]::UtcNow
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
        return [DateTime]::UtcNow
    }
}
