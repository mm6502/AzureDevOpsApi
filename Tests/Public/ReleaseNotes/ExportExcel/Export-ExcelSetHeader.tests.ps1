[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-ExcelSetHeader' {

    BeforeAll {

        $testPath = Join-Path -Path $TestDrive -ChildPath 'TestPath.xlsx'

        $mockHeaderRowStyle = @{
            Bold = $true
            BackgroundColor = 'LightGray'
            FontColor = 'Black'
        }

        $mockColumns = @('Column1', 'Column2', 'Column3')
    }

    It 'Should set cell values correctly' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $worksheet = ImportExcel\Add-Worksheet -ExcelPackage $excelPackage -WorksheetName 'Test'

        # Act
        Export-ExcelSetHeader -Worksheet $worksheet -HeaderRowStyle $mockHeaderRowStyle -Columns $mockColumns

        # Assert
        $worksheet.Cells["A1"].Value | Should -Be 'Column1'
        $worksheet.Cells["B1"].Value | Should -Be 'Column2'
        $worksheet.Cells["C1"].Value | Should -Be 'Column3'
    }

    It 'Should apply auto filter' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $worksheet = ImportExcel\Add-Worksheet -ExcelPackage $excelPackage -WorksheetName 'Test'

        # Act
        Export-ExcelSetHeader -Worksheet $worksheet -HeaderRowStyle $mockHeaderRowStyle -Columns $mockColumns

        # Assert
        $worksheet.Cells["A1:C1"].AutoFilter | Should -Be $true
    }

    It 'Should apply header row style' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $worksheet = ImportExcel\Add-Worksheet -ExcelPackage $excelPackage -WorksheetName 'Test'
        Mock -ModuleName $ModuleName -CommandName ImportExcel\Set-ExcelRange -MockWith {}

        # Act
        Export-ExcelSetHeader -Worksheet $worksheet -HeaderRowStyle $mockHeaderRowStyle -Columns $mockColumns

        # Assert
        Assert-MockCalled -ModuleName $ModuleName -CommandName ImportExcel\Set-ExcelRange -Times 1 -ParameterFilter {
            $Worksheet -eq $worksheet -and
            $Range -eq "A1:C1" -and
            $Bold -eq $mockHeaderRowStyle.Bold -and
            $BackgroundColor -eq $mockHeaderRowStyle.BackgroundColor -and
            $FontColor -eq $mockHeaderRowStyle.FontColor -and
            $AutoSize -eq $true
        }
    }
}
