function Limit-String {

    <#
        .SYNOPSIS
            Filters an array of strings to only unique values that match include and exclude filters.
            Case sensitivity of the filters can be controlled via the -CaseSensitive switch.

        .DESCRIPTION
            Filters an array of strings to only unique values that match include and exclude filters.
            Case sensitivity of the filters can be controlled via the -CaseSensitive switch.

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
            $result = $inputs | Limit-String -Exclude $exclude -Include $inlude
            $result # -> @('bcd')
    #>

    [CmdletBinding()]
    [OutputType([string])]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]] $InputObject,

        [string[]] $Include = @('*'),

        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $Exclude = @(),
        [switch] $CaseSensitive
    )

    begin {
        # Collection of results as list to keep the source order intact
        $results = [System.Collections.Generic.List[string]]::new()

        # Repair inputs
        if ($null -eq $Include) {
            $Include = @('*')
        }
        if ($null -eq $Exclude) {
            $Exclude = @()
        }

        # Guard to prevent duplicate values
        $comparer = [System.StringComparer]::OrdinalIgnoreCase
        if ($CaseSensitive.IsPresent -and $CaseSensitive -eq $true) {
            $comparer = [System.StringComparer]::Ordinal
        }
        $guard = [System.Collections.Generic.HashSet[string]]::new($comparer)
    }

    process {

        if ($null -eq $InputObject) {
            return
        }

        foreach ($item in $InputObject) {

            # Perform the test
            $testResult = $item | Test-String -CaseSensitive:$CaseSensitive -Include $Include -Exclude $Exclude
            if (!$testResult) {
                continue;
            }

            # Guard to prevent duplicate values
            if ($guard.Add($item)) {
                # Add to results, if not already present
                $results.Add($item)
            }
        }
    }

    end {
        # return results
        [string[]] $results
    }
}

Set-Alias -Name Limit-Strings -Value Limit-String
