function Test-WebAddress {

    <#
        .SYNOPSIS
            Tests if the given address looks like a valid web address.

        .DESCRIPTION
            Tests if the given address looks like a valid web address.

        .PARAMETER Address
            Address to test.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        $Address
    )

    process {

        $Address | ForEach-Object {

            # Empty items are not valid web addresses
            if (!$_) {
                return $false
            }

            # Check if the address is a valid web address
            return ($_ -match '^https?://.*')
        }
    }
}
