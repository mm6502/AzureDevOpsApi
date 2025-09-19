[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-ExcelWorkItems' {

    BeforeAll {

        $testPath = Join-Path -Path $TestDrive -ChildPath 'TestPath.xlsx'

        $workItem1 = [PSCustomObject] @{
            WorkItemId = 1
            Title      = 'Test Item 1'
            State      = 'Active'
            PortalUrl  = 'https://test.com/1'
        }

        $workItem2 = [PSCustomObject] @{
            WorkItemId = 2
            Title      = 'Test Item 2'
            State      = 'Closed'
            PortalUrl  = 'https://test.com/2'
        }

        $testExportData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            WorkItems  = @($workItem1, $workItem2)
        }

        $testStyles = @{
            Header   = @{
                Bold            = $true
                BackgroundColor = 'Black'
                FontColor       = 'White'
            }
            DateTime = @{
                Format              = 'yyyy-MM-dd HH:mm:ss'
                HorizontalAlignment = 'Left'
                TargetTimeZone      = 'UTC'
            }
            Date     = @{
                Format              = 'yyyy-MM-dd'
                HorizontalAlignment = 'Left'
                TargetTimeZone      = 'UTC'
            }
            Link     = @{
                Underline           = $true
                HorizontalAlignment = 'Left'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Set-ExcelRange -MockWith {
            ImportExcel\Set-ExcelRange @PSBoundParameters
        }
    }

    It 'Should create a worksheet with the specified name' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelWorkItems `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles `
            -WorksheetName 'Work Items'

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['Work Items']
        $worksheet | Should -Not -BeNullOrEmpty
    }

    It 'Should set the header for the worksheet' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        Mock -ModuleName $ModuleName -CommandName Export-ExcelSetHeader -MockWith { }

        # Act
        Export-ExcelWorkItems `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles

        # Assert
        Should -ModuleName $ModuleName -Invoke -CommandName Export-ExcelSetHeader
    }

    It 'Should apply custom filter when provided' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelWorkItems `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles `
            -Filter { $_.State -eq 'Active' }

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['WorkItems']
        $worksheet.Cells['A2'].Value | Should -Be $workItem1.WorkItemId
        $worksheet.Cells['A3'].Value | Should -BeNullOrEmpty
    }

    It 'Should include only specified properties when IncludeProperties is used' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $expectedProperties = $includedProperties = @('WorkItemId', 'Title')

        # Act
        Export-ExcelWorkItems `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles `
            -IncludeProperties $includedProperties

        # Assert

        # Check Headers
        $worksheet = $excelPackage.Workbook.Worksheets['WorkItems']
        $found = @()
        do {
            $column++
            $address = Export-ExcelGetCellAddress -Row 1 -Column $column
            $value = $worksheet.Cells[$address].Value
            if ($value -eq $null) {
                break
            }
            $found += $value
        } while ($true)

        $found | Should -HaveCount $expectedProperties.Count
        $found | Should -BeIn $expectedProperties
    }

    It 'Should exclude specified properties when ExcludeProperties is used' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $includedProperties = @('WorkItemId', 'Title')
        $excludedProperties = @('State', 'PortalUrl')
        $expectedProperties = ($workItem1 | Get-Member -MemberType NoteProperty).Name `
            | Where-Object { $_ -notin $excludedProperties }

        # Act
        Export-ExcelWorkItems `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles `
            -IncludeProperties $includedProperties `
            -ExcludeProperties $excludedProperties

        # Assert

        # Check Headers
        $worksheet = $excelPackage.Workbook.Worksheets['WorkItems']
        $found = @()
        do {
            $column++
            $address = Export-ExcelGetCellAddress -Row 1 -Column $column
            $value = $worksheet.Cells[$address].Value
            if ($value -eq $null) {
                break
            }
            $found += $value
        } while ($true)

        $found | Should -HaveCount $expectedProperties.Count
        $found | Should -BeIn $expectedProperties
    }

    It 'Should set hyperlink for WorkItemId' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelWorkItems `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['WorkItems']
        $worksheet.Cells["A2"].Hyperlink | Should -Not -BeNullOrEmpty
        $worksheet.Cells["A2"].Hyperlink.ToString() | Should -Be $workItem1.PortalUrl
    }

    It 'Should apply date formatting for date fields' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $date = [datetime]::Parse('2023-02-01T01:02:03Z').ToUniversalTime()
        $workItem1 | Add-Member -MemberType NoteProperty -Name 'ClosedDate' -Value $date
        Mock -ModuleName $ModuleName -CommandName ConvertTo-TimeZoneDateTime -MockWith {
            AzureDevOpsApi\ConvertTo-TimeZoneDateTime @PSBoundParameters
        }

        # Act
        Export-ExcelWorkItems `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['WorkItems']
        Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-TimeZoneDateTime -Times 1
        Should -Invoke -ModuleName $ModuleName -CommandName ImportExcel\Set-ExcelRange -ParameterFilter {
            $NumberFormat -eq $testStyles.DateTime.Format
        }
    }
}
