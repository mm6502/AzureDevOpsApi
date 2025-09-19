function ConvertTo-HashTable {

    <#
    .SYNOPSIS
        Converts PSCustomObject to hashtable.

    .DESCRIPTION
        Converts PSCustomObject to hashtable.
    #>

    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(ValueFromPipeline)]
        [Alias("InputObject")]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        $Value = @{}
    )

    process {

        # Fix for null values
        if ($null -eq $Value) {
            $Value = @{}
        }

        # If value is already a hashtable, return it
        if ($Value -is [hashtable]) {
            Write-Output -InputObject $Value -NoEnumerate
            return
        }

        # If value is an IDictionary, convert it to a hashtable
        if ($Value -is [System.Collections.IDictionary]) {
            $ht = @{}
            foreach ($key in $Value.Keys) {
                $ht[$key] = $Value[$key]
            }
            Write-Output -InputObject $ht -NoEnumerate
            return
        }

        # Convert PSCustomObject to hashtable
        if ($Value -is [PSCustomObject]) {
            $ht = @{}
            foreach ($key in $Value.PSObject.Properties.Name) {
                $ht[$key] = $Value.$key
            }
            Write-Output -InputObject $ht -NoEnumerate
            return
        }

        Write-Output -InputObject @{} -NoEnumerate
        return
    }
}