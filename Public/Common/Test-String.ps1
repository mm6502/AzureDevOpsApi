function Test-String {

    <#
        .SYNOPSIS
            Tests strings for match include and exclude masks.
            Case sensitivity can be controlled via the -CaseSensitive switch.

        .DESCRIPTION
            Tests strings for match include and exclude masks.
            Case sensitivity can be controlled via the -CaseSensitive switch.

        .NOTES
            Regex implementation is approximately 8x faster than double filtering.
            Tested on a 100_000 element array of strings.
            Regex implementation took ~10s.
            Filtering implementation took ~80s.

        .PARAMETER InputObject
            The array of strings to filter.

        .PARAMETER Include
            The strings to include. Default is to include all.

        .PARAMETER Exclude
            The strings to exclude. Default is to exclude none.

        .PARAMETER CaseSensitive
            Switch to control case sensitivity of the filters. Default is to be case insensitive.

        .EXAMPLE
            $inputs = @('abc', 'bcd', 'cde', 'def')
            $inlude = @('*d*')
            $exclude = @('*e*')
            $result = $inputs | Where-Object { $_ | Test-String -Exclude $exclude -Include $inlude }
            $result # -> @('bcd')
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    [OutputType([bool[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]] $InputObject,

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Include = @('*'),

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Exclude = @(),
        [switch] $CaseSensitive
    )

    begin {
        # Repair inputs
        if ($null -eq $Include) {
            $Include = @('*')
        }
        if ($null -eq $Exclude) {
            $Exclude = @()
        }

        # Regex pattern for include
        $includePattern = '^$'
        if ($Include) {
            $includePattern = ($Include | ConvertTo-RegexPattern) -join '|'
        }

        # Regex pattern for exclude
        $excludePattern = '^$'
        if ($Exclude) {
            $excludePattern = ($Exclude | ConvertTo-RegexPattern) -join '|'
        }
    }

    process {

        $InputObject | ForEach-Object {

            $result = $false

            # Depending on the case sensitivity flag, perform the comparison
            if ($CaseSensitive.IsPresent -and $CaseSensitive -eq $true) {
                # Case sensitive comparison
                $shouldBeExcluded = ($_ -cmatch $excludePattern)
                $shouldBeIncluded = ($_ -cmatch $includePattern)
                $result = $shouldBeIncluded -and (-not $shouldBeExcluded)
            } else {
                # Case insensitive comparison
                $shouldBeExcluded = ($_ -match $excludePattern)
                $shouldBeIncluded = ($_ -match $includePattern)
                $result = $shouldBeIncluded -and (-not $shouldBeExcluded)
            }

            # Return the result
            Write-Output $result

        }
    }
}

Set-Alias -Name Test-StringMasks -Value Test-String
