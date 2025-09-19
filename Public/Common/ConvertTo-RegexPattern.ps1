function ConvertTo-RegexPattern {

    <#
        .SYNOPSIS
            Converts mask to regex pattern.

        .DESCRIPTION
            Converts mask to regex pattern.

        .PARAMETER InputObject
            Mask to interpret as regex.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]] $InputObject
    )

    process {

        # if no mask is given treat as wildcard
        if (!$InputObject) {
            return '^.*$'
        }

        foreach ($mask in $InputObject) {

            # if no mask is given treat as wildcard
            # if mask is empty treat as wildcard
            if (!$mask) {
                '^.*$'
                continue
            }

            # if mask is a single character treat as wildcard
            if ($mask.Length -eq 1) {
                if ($mask -eq '?') {
                    '^.$'
                    continue
                }
                if ($mask -eq '*') {
                    '^.*$'
                    continue
                }
                "^$($mask)$"
                continue
            }

            # if mask contains a question mark treat as wildcard
            $mask = $mask -replace '[?]', '.'

            # treat multiple subsequent asterisks as single asterisk
            $mask = $mask -replace '\*+', '*'

            # if mask contains an asterisk treat as wildcard
            $mask = $mask -replace '[*]', '.*'

            # for masks with explicit length;
            # '???' will match only strings with length 3
            $mask = "^$($mask)`$"

            $mask
        }
    }
}

Set-Alias -Name Limit-StringsMakePattern -Value ConvertTo-RegexPattern
