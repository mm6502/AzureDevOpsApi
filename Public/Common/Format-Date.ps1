function Format-Date {

    <#
        .SYNOPSIS
            Converts the given date time to UTC and formats it to the format used in the Azure DevOps API:
            'yyyy-MM-ddTHH:mm:ss.fffZ'

        .PARAMETER Value
            Date time to format.
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [Alias('Date', 'DateTime', 'Time')]
        [AllowNull()]
        [AllowEmptyString()]
        $Value
    )

    process {
        if (!$Value) {
            $Value = [DateTime]::UtcNow
        }

        return ([DateTime] $Value).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffK')
    }
}
