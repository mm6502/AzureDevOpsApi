function Export-ExcelSetHeader {

    <#
        .SYNOPSIS
            Set the header for an Excel worksheet.

        .PARAMETER Worksheet
            Worksheet to set the header on.

        .PARAMETER HeaderRowStyle
            Header style definition.

        .PARAMETER Columns
            List of columns to add.
    #>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        $Worksheet,
        $HeaderRowStyle,
        $Columns
    )

    process {

        # write out the data
        $index = 0
        foreach ($column in $Columns) {
            $index++
            $address = Export-ExcelGetCellAddress -Row 1 -Column $index
            $Worksheet.Cells[$address].Value = $column
        }

        # freeze the top row and first column
        $Worksheet.View.FreezePanes(2, 2)

        # format first row
        $address = Export-ExcelGetCellAddress -Row 1 -Column $Columns.Count
        $range = "A1:$($address)"
        $Worksheet.Cells[$range].AutoFilter = $true
        ImportExcel\Set-ExcelRange `
            -Worksheet $Worksheet `
            -Range $range `
            -Bold:$headerRowStyle.Bold `
            -BackgroundColor $headerRowStyle.BackgroundColor `
            -FontColor $headerRowStyle.FontColor `
            -AutoSize
    }
}
