function ConvertTo-JsonCustom {

    <#
        .SYNOPSIS
            Converts the given object to a JSON string as an array.
            This is a wrapper around ConvertTo-Json that adds the -AsArray parameter because:
            - the default behavior of ConvertTo-Json is to output a single JSON object
            - PowerShell 5 does not support the -AsArray parameter

        .PARAMETER Value
            Object to convert to JSON.

        .PARAMETER AsArray
            If set, the JSON string will be wrapped in square brackets.

        .PARAMETER Depth
            Depth of the JSON string.
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [AllowEmptyString()]
        $Value,

        [switch] $AsArray,
        $Depth = 5
    )

    process {

        # When $Value is null, return null
        if ($null -eq $Value) {
            return "null"
        }

        # Powershell 7 supports -AsArray
        if ((Get-PSVersion) -ge 7) {
            return ConvertTo-Json -InputObject $Value -Depth $Depth -AsArray:$AsArray
        }

        # when $AsArray not specified or $false, use default
        if (-not ($AsArray.IsPresent -and ($true -eq $AsArray))) {
            return ConvertTo-Json -InputObject $Value -Depth $Depth
        }

        # otherwise;
        # serialize the object to a string
        $temp = ConvertTo-Json -InputObject $Value -Depth $Depth

        # when is already array, just return it
        if ($temp -and ($temp[0] -eq '[')) {
            return $temp
        }

        # otherwise;
        # alter the string to be an array
        return '[' + $temp + ']'
    }
}
