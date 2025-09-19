function Use-AsOfDateTime {

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
            'AsOf', 'AsOfDateTime', 'AsOfDate', 'AsOfTime',
            'DateTime', 'DateTimeAsOf',
            'Date', 'DateAsOf',
            'Time', 'TimeAsOf'
        )]
        $Value = $null,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias(
            'To', 'ToDateTime', 'ToDate', 'ToTime',
            'DateTimeTo',
            'TimeTo'
        )]
        $DateTo = $null
    )

    process {
        # If not given, use default value
        $DateTo = Use-ToDateTime -Value $DateTo

        # Now resolve the AsOf DateTime
        if (!$Value) {
            return $DateTo
        } else {
            return Use-ToDateTime -Value $Value
        }
    }
}
