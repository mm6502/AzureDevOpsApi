function ConvertTo-TimeZoneDateTime {

    <#
        .SYNOPSIS
            Converts given date time to the given time zone.

        .PARAMETER DateTime
            Date time value to convert.

        .PARAMETER TimeZone
            Time Zone to use.

            Possible values are:
            [TimeZoneInfo] object
            IANA style zone ids, f.e. "Europe/Bratislava"
            Windows style zone ids, f.e. "Central Europe Standard Time"
    #>

    [CmdletBinding()]
    param(
        [Alias('Value', 'Time')]
        $DateTime,
        $TimeZone = 'UTC'
    )

    process {
        # if no value is given, just return it
        if (!$DateTime) {
            return $null
        }

        # if value is not [TimeZoneInfo], try to convert it
        if (-not ($TimeZone -is [TimeZoneInfo])) {
            $TimeZone = Get-CustomTimeZone -Id $TimeZone
        }

        # if string is given, try to convert to date time
        [TimeZoneInfo]::ConvertTime([DateTime] $DateTime, $TimeZone)
    }
}
