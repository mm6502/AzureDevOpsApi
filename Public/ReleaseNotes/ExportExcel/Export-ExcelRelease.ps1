function Export-ExcelRelease {

    <#
        .SYNOPSIS
            Exports the Release subset.

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
        $ExcelPackage,
        $Styles
    )

    process {

        # add new sheet to hold the data
        $worksheet = ImportExcel\Add-Worksheet `
            -ExcelPackage $excelPackage `
            -WorksheetName Release

        # list of properties we want to export
        $properties = @(
            'Collection', 'Project', 'DateFrom', 'DateTo', 'AsOf',
            'TargetBranch', 'TrunkBranch', 'ReleaseBranch',
            'ByUser', 'CreatedDate', 'CreatedBy'
        )

        # write out the data
        $row = 0
        foreach ($item in $properties) {

            # skip properties that don't exist
            $property = $ExportData.Release | Get-Member -Name $item -ErrorAction SilentlyContinue
            if (!$property) {
                continue
            }

            # write out the header property
            $row++
            $address = Export-ExcelGetCellAddress -Column 1 -Row $row
            $worksheet.Cells[$address].Value = $item

            $address = Export-ExcelGetCellAddress -Column 2 -Row $row
            $worksheet.Cells[$address].Value = $ExportData.Release.$item

            if ($item -iin @('DateFrom', 'DateTo', 'AsOf', 'CreatedDate')) {

                # reset the value to target zone
                $worksheet.Cells[$address].Value = ConvertTo-TimeZoneDateTime `
                    -DateTime $ExportData.Release.$item `
                    -TimeZone $Styles.DateTime.TargetTimeZone

                # set the format
                Set-ExcelRange `
                    -Worksheet $worksheet `
                    -Range "B$($row)" `
                    -NumberFormat $Styles.DateTime.Format `
                    -HorizontalAlignment $Styles.DateTime.HorizontalAlignment
            }
        }

        $address = Export-ExcelGetCellAddress -Column 2 -Row 2
        $worksheet.Cells[$address].Value = $ExportData.Release.Project
        $worksheet.Cells[$address].Hyperlink = $ExportData.Release.ProjectPortalUrl
        ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
            -Underline:$styles.Link.Underline `
            -HorizontalAlignment $styles.Link.HorizontalAlignment

        # format first column
        ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range "A1:A$($row)" `
            -Bold:$Styles.Header.Bold `
            -BackgroundColor $Styles.Header.BackgroundColor `
            -FontColor $Styles.Header.FontColor `
            -AutoSize

        # format second column
        ImportExcel\Set-ExcelRange `
            -Worksheet $worksheet `
            -Range "B1:B$($row)" `
            -AutoSize
    }
}
