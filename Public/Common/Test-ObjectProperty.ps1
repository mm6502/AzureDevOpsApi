function Test-ObjectProperty {

    <#
        .SYNOPSIS
            Tests if properties of given object match one of given patterns.
            Uses Test-String for comparison.

        .PARAMETER InputObject
            Object to test.

        .PARAMETER Property
            List of properties to test.
            If not specified, the whole object is used.
            Property names can be separated by '.' to access nested properties.

        .PARAMETER Pattern
            List of patterns to test. Can use '*' and '?' as wildcards.

        .OUTPUTS
            Returns $true if at least one property matches one of the patterns.
    #>

    [CmdletBinding()]
    [OutputType([bool])]
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

        # If no object is specified, return false
        if ($null -eq $InputObject) {
            return $false
        }

        # If no pattern is specified, return true
        if (!$Pattern) {
            return $true
        }

        $haystack = [System.Collections.Generic.List[object]]::new()

        if (!$Property) {
            # If no property is specified, use the whole object
            $haystack += $InputObject
            # And all of its level properties
            $haystack += $InputObject | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
        } else {
            # If property is specified, use only the specified properties
            foreach ($item in $Property) {
                $obj = $InputObject
                # Split the property name into parts (e.g. 'a.b' -> 'a','b')
                # The property may be $obj.'a.b' or $obj.a.b;
                # deliberatelly ignoring $obj.'a.b' for now
                $partialNames = $item -split '\.'
                # Iterate over the parts and get the property value
                foreach ($partialName in $partialNames) {
                    try {
                        $obj = $obj.$partialName
                    } catch {
                        # nothing to do
                    }
                }
                $haystack += $obj
            }
        }

        # Test if any of the properties matches the pattern
        $result = $false
        foreach ($item in $haystack) {
            # Test if any of the properties matches the pattern
            $result = $result -or ($item | Test-String -Include $Pattern)
            if ($result) { break }
        }

        # Return the result
        return $result
    }
}

Set-Alias -Name Test-Object -Value Test-ObjectProperty
