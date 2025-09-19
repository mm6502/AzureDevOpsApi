function Repair-PSTypeName {

    <#
        .SYNOPSIS
            Repair PSTypeNames for deserialized objects, by removing the "Deserialized." prefix.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        $InputObject
    )

    process {
        # Repair all given objects
        foreach ($obj in $InputObject) {

            # Get the type names as stack
            # to retain the order of original types
            $stack = [System.Collections.Generic.Stack[string]] $obj.PSObject.TypeNames

            foreach ($type in $stack) {
                # Add a repaired typename
                if ($type -like "Deserialized.*") {
                    $obj.PSTypeNames.Insert(0, $type.Substring("Deserialized.".Length))
                }
            }

            # Repair all properties
            foreach ($property in $obj.PSObject.Properties) {
                # skip the primitive properties
                if ($property.TypeNameOfValue -like "Deserialized.*") {
                    $null = Repair-PSTypeName $property.Value
                }
            }

            # Return the repaired object
            $obj
        }
    }
}
