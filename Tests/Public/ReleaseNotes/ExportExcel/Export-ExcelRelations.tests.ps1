[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-ExcelRelations' {

    BeforeAll {

        $testPath = Join-Path -Path $TestDrive -ChildPath 'TestPath.xlsx'

        $relationItem1 = @{
            'A.WorkItemId'   = 1
            'A.WorkItemType' = 'Bug'
            'A.RelationName' = 'Parent'
            'B.WorkItemId'   = 2
            'B.WorkItemType' = 'Task'
            'A.PortalUrl'    = 'https://dev.azure.com/org/project/_workitems/edit/1'
            'B.PortalUrl'    = 'https://dev.azure.com/org/project/_workitems/edit/2'
        }

        $relationItem2 = @{
            'A.WorkItemId'   = 3
            'A.WorkItemType' = 'User Story'
            'A.RelationName' = 'Child'
            'B.WorkItemId'   = 4
            'B.WorkItemType' = 'Bug'
            'A.PortalUrl'    = 'https://dev.azure.com/org/project/_workitems/edit/3'
            'B.PortalUrl'    = 'https://dev.azure.com/org/project/_workitems/edit/4'
        }

        $testExportData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Relations = @($relationItem1, $relationItem2)
        }

        $testStyles = @{
            Header = @{
                FontColor       = 'White'
                BackgroundColor = 'Black'
                Bold            = $true
            }
            Link = @{
                Underline = $true
                HorizontalAlignment = 'Center'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Export-ExcelSetHeader -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Set-ExcelRange -MockWith {
            ImportExcel\Set-ExcelRange @PSBoundParameters
        }
    }

    It 'Should create a worksheet named Relations' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelations `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['Relations']
        $worksheet.Name | Should -Be 'Relations'
    }

    It 'Should set the header with correct properties' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelations `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Export-ExcelSetHeader -Times 1 -ParameterFilter {
            $Columns -contains 'A.WorkItemId' -and
            $Columns -contains 'A.WorkItemType' -and
            $Columns -contains 'A.RelationName' -and
            $Columns -contains 'B.WorkItemId' -and
            $Columns -contains 'B.WorkItemType'
        }
    }

    It 'Should populate cells with correct data' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelations `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['Relations']
        $worksheet.Cells['A2'].Value | Should -Be $relationItem1.'A.WorkItemId'
        $worksheet.Cells['A2'].Hyperlink | Should -Be $relationItem1.'A.PortalUrl'
        $worksheet.Cells['D3'].Value | Should -Be $relationItem2.'B.WorkItemId'
        $worksheet.Cells['D3'].Hyperlink | Should -Be $relationItem2.'B.PortalUrl'
    }

    It 'Should apply styles to hyperlinks' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelations `
            -ExportData $testExportData `
            -ExcelPackage $excelPackage `
            -Styles $testStyles

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Set-ExcelRange -Times 4 -ParameterFilter {
            $Underline -eq $true -and $HorizontalAlignment -eq 'Center'
        }
    }

    It 'Should auto-size columns' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelations -ExportData $testExportData -ExcelPackage $excelPackage -Styles $testStyles

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Set-ExcelRange -Times 1 -ParameterFilter {
            $Range -eq 'A:E' -and $AutoSize -eq $true
        }
    }
}
