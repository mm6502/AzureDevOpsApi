function Get-CustomTimeZone {

    <#
        .SYNOPSIS
            Returns the time zone for date tiem conversions for export.

        .PARAMETER Id
            Time Zone Id to use.

            Possible values are:
            IANA style zone ids, f.e. "Europe/Bratislava"
            Windows style zone ids, f.e. "Central Europe Standard Time"
    #>

    [OutputType([System.TimeZoneInfo])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('Name')]
        [string[]] $Id
    )

    process {
        # if time zone identifier is given, try to convert
        foreach ($item in $Id) {
            Get-TimeZone -Id $item
        }
    }
}
