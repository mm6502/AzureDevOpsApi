function Export-ExcelGetCellAddress {

    <#
        .SYNOPSIS
            Returns the Excel cell address for a given row and column.

        .PARAMETER Row
            Row number for the cell address.

        .PARAMETER Column
            Column for the cell address. Specified by its number or letters.

        .OUTPUTS
            Excel cell address as a string in format "A1".
    #>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        $Row,
        $Column
    )

    process {

        # if assembling range of rows, column may not be specified
        if (!$Column) {
            return $Row
        }

        $address = ""

        # if column is given as number, calculate its "name"
        if ($Column -match '\d+') {
            $Column = ([int] $Column) - 1
            # count of characters
            $characterCount = 1 + ([int][char] 'Z' - [int][char] 'A')
            for ( ; $Column -ge 0; $Column = [int] [Math]::Truncate(($Column) / 26) - 1) {
                $remainder = ($Column % $characterCount)
                $char = [char] (([int][char]'A') + $remainder)
                $address = $char + $address
            }
        } else {
            $address = $Column
        }

        # add the row, if specified
        if ($Row) {
            $address += $Row
        }

        $address
    }
}
