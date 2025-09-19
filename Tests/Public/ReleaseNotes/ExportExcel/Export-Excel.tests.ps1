BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-Excel' {
    BeforeAll {

        Mock -ModuleName $ModuleName -CommandName Open-ExcelPackage -MockWith {
            $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $Path
            $null = ImportExcel\Add-Worksheet `
                -ExcelPackage $excelPackage `
                -WorksheetName Dummy
            return $excelPackage
        }

        Mock -ModuleName $ModuleName -CommandName Export-ExcelRelease   -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Export-ExcelWorkItems -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Export-ExcelRelations -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Export-ExcelConsole   -MockWith { }
    }

    It 'Should produce an Excel file' {
        # Arrange
        $testPath = Join-Path -Path $TestDrive -ChildPath 'TestPath.xlsx'
        $testData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            'Column1'  = 'Value1'
            'Column2'  = 'Value2'
        }

        Mock -ModuleName $ModuleName -CommandName Export-DetermineOutputFileName -MockWith {
            $testPath
        }

        # Act
        $result = AzureDevOpsApi\Export-Excel `
            -Path $testPath `
            -ExportData $testData `
            -PassThru

        # Assert
        $result | Should -Be $testPath
        Should -Invoke -ModuleName $ModuleName -CommandName Export-ExcelRelease   -Exactly 1
        Should -Invoke -ModuleName $ModuleName -CommandName Export-ExcelRelations -Exactly 1
        Should -Invoke -ModuleName $ModuleName -CommandName Export-ExcelConsole   -Exactly 1
        Should -Invoke -ModuleName $ModuleName -CommandName Export-ExcelWorkItems
    }
}
