function Export-ExcelWorkItems {

    <#
        .SYNOPSIS
            Exports work items to an Excel worksheet.

        .PARAMETER ExportData
            Export data prepared by ConvertTo-ExportData.

        .PARAMETER ExcelPackage
            Package to add the worksheet to.

        .PARAMETER Styles
            Style properties for different cell types.

        .PARAMETER WorksheetName
            Name of the worksheet to create.

        .PARAMETER Filter
            Scriptblock filter for $ExportData.WorkItems to be included on this worksheet.

        .PARAMETER IncludeProperties
            List of patterns for properties to include.

        .PARAMETER ExcludeProperties
            List of patterns for properties to exclude.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
    [CmdletBinding()]
    param(
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ExportData')]
        [Parameter(Mandatory, Position = 1)]
        [Alias('Data')]
        $ExportData,

        [Alias('WorkBook', 'Excel', 'Package')]
        $ExcelPackage,

        $Styles,

        $WorksheetName = 'WorkItems',

        [scriptblock] $Filter = { $true },

        $IncludeProperties = @( '*' ),

        $ExcludeProperties = @( )
    )

    process {

        # add new sheet to hold the data
        $worksheet = ImportExcel\Add-Worksheet `
            -ExcelPackage $excelPackage `
            -WorksheetName $WorksheetName

        # list of known properties
        $KnownProperties = @(
            'WorkItemId'
            'InclusionReason'
            'TestedWorkItemStates'
            'WorkItemType'
            'Title'
            'State'
            'Reason'
            'AreaPath'
            'IterationPath'
            'CatalogueRequestNumber'
            'ExternalIdentificationNumber'
            'AssignedToDisplayName'
            'AssignedToUniqueName'
            'Discipline'
            'ResolvedDate'
            'ResolvedByDisplayName'
            'ResolvedByUniqueName'
            'ResolvedReason'
            'ClosedDate'
            'ClosedByDisplayName'
            'ClosedByUniqueName'
            'RequiresTest'
            'OriginalEstimate'
            'CompletedWork'
            'RemainingWork'
            'TargetDate'
            'Tags'
            'Parent'
        )

        # list of properties we want to export
        $properties = $KnownProperties `
        | Limit-String `
            -Include $IncludeProperties `
            -Exclude $ExcludeProperties

        # set header
        Export-ExcelSetHeader `
            -Worksheet $worksheet `
            -HeaderRowStyle $Styles.Header `
            -Columns $properties

        # write out the data
        $row = 1
        foreach ($item in $ExportData.WorkItems | Where-Object $Filter | Sort-Object -Property WorkItemId) {
            $column = 0
            $row++

            # WorkItemId
            if ($properties -icontains 'WorkItemId') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.WorkItemId
                $worksheet.Cells[$address].Hyperlink = $item.PortalUrl
                ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
                    -Underline:$Styles.Link.Underline `
                    -HorizontalAlignment $Styles.Link.HorizontalAlignment
            }

            # InclusionReason
            if ($properties -icontains 'InclusionReason') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.InclusionReason
            }

            # TestedWorkItemStates
            if ($properties -icontains 'TestedWorkItemStates') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.TestedWorkItemStates
            }

            # WorkItemType
            if ($properties -icontains 'WorkItemType') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.WorkItemType
            }

            # Title
            if ($properties -icontains 'Title') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.Title
            }

            # State
            if ($properties -icontains 'State') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.State
            }

            # Reason
            if ($properties -icontains 'Reason') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.Reason
            }

            # AreaPath
            if ($properties -icontains 'AreaPath') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.AreaPath
            }

            # IterationPath
            if ($properties -icontains 'IterationPath') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.IterationPath
            }

            # CatalogueRequestNumber
            if ($properties -icontains 'CatalogueRequestNumber') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.CatalogueRequestNumber
            }

            # ExternalIdentificationNumber
            if ($properties -icontains 'ExternalIdentificationNumber') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.ExternalIdentificationNumber
            }

            # AssignedToDisplayName
            if ($properties -icontains 'AssignedToDisplayName') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.AssignedToDisplayName
            }

            # AssignedToUniqueName
            if ($properties -icontains 'AssignedToUniqueName') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.AssignedToUniqueName
            }

            # Discipline
            if ($properties -icontains 'Discipline') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.Discipline
            }

            # ResolvedDate
            if ($properties -icontains 'ResolvedDate') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = ConvertTo-TimeZoneDateTime `
                    -DateTime $item.ResolvedDate `
                    -TimeZone $Styles.DateTime.TargetTimeZone
                ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
                    -NumberFormat $Styles.DateTime.Format `
                    -HorizontalAlignment $Styles.DateTime.HorizontalAlignment
            }

            # ResolvedByDisplayName
            if ($properties -icontains 'ResolvedByDisplayName') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.ResolvedByDisplayName
            }

            # ResolvedByUniqueName
            if ($properties -icontains 'ResolvedByUniqueName') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.ResolvedByUniqueName
            }

            # ResolvedReason
            if ($properties -icontains 'ResolvedReason') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.ResolvedReason
            }

            # ClosedDate
            if ($properties -icontains 'ClosedDate') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = ConvertTo-TimeZoneDateTime `
                    -DateTime $item.ClosedDate `
                    -TimeZone $Styles.DateTime.TargetTimeZone
                ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
                    -NumberFormat $Styles.DateTime.Format `
                    -HorizontalAlignment $Styles.DateTime.HorizontalAlignment
            }

            # ClosedByDisplayName
            if ($properties -icontains 'ClosedByDisplayName') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.ClosedByDisplayName
            }

            # ClosedByUniqueName
            if ($properties -icontains 'ClosedByUniqueName') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.ClosedByUniqueName
            }

            # RequiresTest
            if ($properties -icontains 'RequiresTest') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.RequiresTest
            }

            # OriginalEstimate
            if ($properties -icontains 'OriginalEstimate') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.OriginalEstimate
            }

            # CompletedWork
            if ($properties -icontains 'CompletedWork') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.CompletedWork
            }

            # RemainingWork
            if ($properties -icontains 'RemainingWork') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.RemainingWork
            }

            # TargetDate
            if ($properties -icontains 'TargetDate') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = ConvertTo-TimeZoneDateTime `
                    -DateTime $item.TargetDate `
                    -TimeZone $Styles.Date.TargetTimeZone
                ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
                    -NumberFormat $Styles.Date.Format `
                    -HorizontalAlignment $Styles.Date.HorizontalAlignment
            }

            # Tags
            if ($properties -icontains 'Tags') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.Tags
            }

            # Parent
            if ($properties -icontains 'Parent') {
                $column++
                $address = Export-ExcelGetCellAddress -Row $row -Column $column
                $worksheet.Cells[$address].Value = $item.Parent
                $worksheet.Cells[$address].Hyperlink = $item.ParentPortalUrl
                ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range $address `
                    -Underline:$styles.Link.Underline `
                    -HorizontalAlignment $styles.Link.HorizontalAlignment
            }
        }

        # format columns
        $address = Export-ExcelGetCellAddress -Column $column
        ImportExcel\Set-ExcelRange -Worksheet $worksheet -Range "A:$($address)" -AutoSize
    }
}
