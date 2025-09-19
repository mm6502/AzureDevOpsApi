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

        # if powershell 7, use native cmdlet
        if ((Get-PSVersion) -ge 7) {
            foreach ($item in $Id) {
                Get-TimeZone -Id $Id
            }
            return
        }

        # if time zone identifier is given, try to convert
        [System.TimeZoneInfo]::FindSystemTimeZoneById($Id)
    }
}
