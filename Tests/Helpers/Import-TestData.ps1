function Import-TestData {

    <#
        .SYNOPSIS
            Imports test data from a serialized file.

        .DESCRIPTION
            The Import-TestData function deserializes the content of a file located at the specified path,
            relative to the $RootPath variable. It then repairs the PSTypeNames of the deserialized object
            to remove the "Deserialized." prefix, and returns the resulting data.

        .PARAMETER Path
            The path to the serialized file, relative to the $RootPath variable.

        .PARAMETER Root
            The root path to use when resolving the $Path parameter. Defaults to the $RootPath variable.

        .EXAMPLE
            Import-TestData -Path "Mocks\TestData.xml"
            Imports test data from the "Mocks\TestData.xml" file, relative to the $RootPath variable.
    #>

    [CmdletBinding()]
    param(
        $Path,
        $Root = $RootPath
    )

    # Deserialize file content
    $result = Import-Clixml -Path (Join-Path -Path $Root -ChildPath ".\Mocks\$Path")

    # Add PSTypeNames without the "Deserialized." prefix
    $result = Repair-PSTypeName -InputObject $result

    # Return data
    $result
}
