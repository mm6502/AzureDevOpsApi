function Select-ByObjectProperty {

    <#
        .SYNOPSIS
            Filters objects based on properties.
            Uses Test-String for comparison.

        .PARAMETER InputObject
            Object to filter.

        .PARAMETER Property
            List of properties to filter.
            If not specified, the whole object is used.
            Property names can be separated by '.' to access nested properties.

        .PARAMETER Pattern
            List of patterns to filter. Can use '*' and '?' as wildcards.

        .OUTPUTS
            Returns objects that have at least one property matching one of the patterns.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        $InputObject,

        [Parameter()]
        [string[]] $Property,

        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]] $Pattern
    )

    process {
        $InputObject | Where-Object {
            $_ | Test-ObjectProperty -Property $Property -Pattern $Pattern
        }
    }
}

Set-Alias -Name 'Where-ObjectProperty' -Value 'Select-ByObjectProperty'
