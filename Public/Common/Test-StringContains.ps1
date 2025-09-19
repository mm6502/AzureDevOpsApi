function Test-StringContains {

    <#
        .SYNOPSIS
            Check if $Haystack contains $Needle.

        .PARAMETER Haystack
            String in which to search.

        .PARAMETER Needle
            The string we are looking for.

        .PARAMETER StringComparison
            String comparison method. Default is [StringComparison]::InvariantCultureIgnoreCase.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]] $Haystack,

        [Parameter(Mandatory, ValueFromRemainingArguments = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Alias('Needles')]
        [string[]] $Needle,

        [StringComparison] $StringComparison = [StringComparison]::InvariantCultureIgnoreCase
    )

    process {
        # If we have nowhere to search, we have found nothing
        if (!$Haystack -or !$Needle) {
            return $false
        }

        foreach ($stack in $Haystack) {

            foreach ($item in $Needle) {
                # There is no point in looking for a non-existent needle
                if (!$item) {
                    return $false
                }

                $found = ($stack.IndexOf($item, $StringComparison) -ge 0)

                # If one is not found, let's finish
                if (-not $found) {
                    return $false
                }
            }
        }

        # Return result
        return $true
    }
}
