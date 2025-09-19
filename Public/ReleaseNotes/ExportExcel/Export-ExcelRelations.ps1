function Export-ExcelRelations {

    <#
        .SYNOPSIS
            Exports the Relations subset.

        .PARAMETER ExportData
            Export data prepared by ConvertTo-ExportData.

        .PARAMETER ExcelPackage
            Package to add the worksheet to.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
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
            -WorksheetName Relations

        # list of properties we want to export
        $properties = @(
            'A.WorkItemId', 'A.WorkItemType', 'A.RelationName', 'B.WorkItemId', 'B.WorkItemType'
        )

        # set header
        Export-ExcelSetHeader `
            -Worksheet $worksheet `
            -HeaderRowStyle $Styles.Header `
            -Columns $properties

        # write out the data
        $row = 1
        $relations = $ExportData.Relations | Sort-Object -Property @(
            @{ e = { [int] $_.'A.WorkItemId' } },
            @{ e = { [int] $_.'B.WorkItemId' } },
            @{ e = { $_.'A.RelationName' } }
        )
        foreach ($item in $relations) {
            $column = 0
            $row++

            # A.WorkItemId
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.'A.WorkItemId'
            $worksheet.Cells[$address].Hyperlink = $item.'A.PortalUrl'
            ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
                -Underline:$styles.Link.Underline `
                -HorizontalAlignment $styles.Link.HorizontalAlignment

            # A.WorkItemType
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.'A.WorkItemType'

            # A.RelationName
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.'A.RelationName'

            # B.WorkItemId
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.'B.WorkItemId'
            $worksheet.Cells[$address].Hyperlink = $item.'B.PortalUrl'
            ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
                -Underline:$styles.Link.Underline `
                -HorizontalAlignment $styles.Link.HorizontalAlignment

            # B.WorkItemType
            $column++
            $address = Export-ExcelGetCellAddress -Row $row -Column $column
            $worksheet.Cells[$address].Value = $item.'B.WorkItemType'
        }

        # format columns
        $address = Export-ExcelGetCellAddress -Column $column
        ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range "A:$($address)" -AutoSize
    }
}
