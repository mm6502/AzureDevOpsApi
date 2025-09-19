function Export-ExcelConsole {

    <#
        .SYNOPSIS
            Exports the Console subset.

        .PARAMETER ExportData
            Export data prepared by ConvertTo-ExportData.

        .PARAMETER ExcelPackage
            Package to add the worksheet to.
    #>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ExportData')]
        [Parameter(Mandatory, Position = 1)]
        [Alias('Data')]
        $ExportData,

        [Alias('WorkBook', 'Excel', 'Package')]
        $ExcelPackage,
        $Styles
    )

    process {

        # add new sheet to hold the data
        $worksheet = ImportExcel\Add-Worksheet `
            -ExcelPackage $excelPackage `
            -WorksheetName Console

        # list of properties we want to export
        $properties = @(
            'WorkItemId', 'WorkItemType', 'Reasons', 'Relations'
        )

        # set header
        Export-ExcelSetHeader `
            -Worksheet $worksheet `
            -HeaderRowStyle $Styles.Header `
            -Columns $properties

        # write out the data
        $row = 1
        foreach ($item in $ExportData.Console | Sort-Object -Property WorkItemId) {
            $column = 0
            $row++

            # WorkItemId
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.WorkItemId
            $worksheet.Cells[$address].Hyperlink = $item.PortalUrl
            ImportExcel\Set-ExcelRange `
                -Worksheet $worksheet `
                -Range $address `
                -Underline:$styles.Link.Underline `
                -HorizontalAlignment $styles.Link.HorizontalAlignment

            # WorkItemType
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.WorkItemType

            # Reasons
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.Reasons

            # Relations
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.Relations
        }

        # format columns
        $address = Export-ExcelGetCellAddress -Column $column
        ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range "A:$($address)" -AutoSize
    }
}
