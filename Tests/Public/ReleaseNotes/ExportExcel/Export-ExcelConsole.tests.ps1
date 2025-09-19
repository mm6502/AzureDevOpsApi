[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-ExcelConsole' {
    BeforeAll {
        $testPath = Join-Path -Path $TestDrive -ChildPath 'TestPath.xlsx'

        Mock -ModuleName $ModuleName -CommandName Export-ExcelSetHeader -MockWith { }
    }

    It 'Should create a new worksheet named Console' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $exportData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Console    = @()
        }

        # Act
        Export-ExcelConsole -ExportData $exportData -ExcelPackage $excelPackage

        # Assert
        $excelPackage.Workbook.Worksheets["Console"] | Should -Not -BeNullOrEmpty
    }

    It 'Should set the header with correct properties' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $exportData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Console    = @()
        }

        # Act
        Export-ExcelConsole `
            -ExportData $exportData `
            -ExcelPackage $excelPackage `
            -Styles @{ Header = 'HeaderStyle' }

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Export-ExcelSetHeader -ParameterFilter {
            $HeaderRowStyle -eq 'HeaderStyle' -and
            $Columns -contains 'WorkItemId' -and
            $Columns -contains 'WorkItemType' -and
            $Columns -contains 'Reasons' -and
            $Columns -contains 'Relations'
        }
    }

    It 'Should process each item in the Console array' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $exportData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Console    = @(
                [PSCustomObject] @{
                    WorkItemId   = 1
                    WorkItemType = 'Bug'
                    Reasons      = 'Reason1'
                    Relations    = 'Relation1'
                    PortalUrl    = 'http://example.com/1'
                },
                [PSCustomObject] @{
                    WorkItemId   = 2
                    WorkItemType = 'Task'
                    Reasons      = 'Reason2'
                    Relations    = 'Relation2'
                    PortalUrl    = 'http://example.com/2'
                }
            )
        }

        # Act
        Export-ExcelConsole `
            -ExportData $exportData `
            -ExcelPackage $excelPackage `
            -Styles @{ Link = @{ Underline = $true; HorizontalAlignment = 'Center' } }

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets["Console"]
        $worksheet.Cells['D3'].Value | Should -Be 'Relation2'
    }
}
