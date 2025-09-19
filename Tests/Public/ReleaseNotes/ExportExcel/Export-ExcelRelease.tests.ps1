[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-ExcelRelease' {

    BeforeAll {

        $testPath = Join-Path -Path $TestDrive -ChildPath 'TestPath.xlsx'

        $mockExportData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Release = [PSCustomObject]@{
                Collection = 'TestCollection'
                Project = 'TestProject'
                DateFrom = (Get-Date).AddDays(-7)
                DateTo = Get-Date
                AsOf = Get-Date
                TargetBranch = 'main'
                TrunkBranch = 'develop'
                ReleaseBranch = 'release/1.0'
                ByUser = 'TestUser'
                CreatedDate = (Get-Date).AddDays(-1)
                CreatedBy = 'TestCreator'
                ProjectPortalUrl = 'https://dev.azure.com/testorg/testproject'
            }
        }

        $mockStyles = @{
            DateTime = @{
                TargetTimeZone = 'UTC'
                Format = 'yyyy-MM-dd HH:mm:ss'
                HorizontalAlignment = 'Center'
            }
            Link = @{
                Underline = $true
                HorizontalAlignment = 'Left'
            }
            Header = @{
                Bold = $true
                BackgroundColor = 'LightGray'
                FontColor = 'Black'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Set-ExcelRange -MockWith {
            ImportExcel\Set-ExcelRange @PSBoundParameters
        }
    }

    It 'Should export all expected properties' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath
        $expectedProperties = @(
            'Collection', 'Project', 'DateFrom', 'DateTo', 'AsOf',
            'TargetBranch', 'TrunkBranch', 'ReleaseBranch',
            'ByUser', 'CreatedDate', 'CreatedBy'
        )

        # Act
        Export-ExcelRelease -ExportData $mockExportData -ExcelPackage $excelPackage -Styles $mockStyles

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['Release']
        foreach ($index in 1..$expectedProperties.Count) {
            $worksheet.Cells[($index), 1].Value `
            | Should -BeIn $expectedProperties
        }
    }

    It 'Should set hyperlink for Project' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelease -ExportData $mockExportData -ExcelPackage $excelPackage -Styles $mockStyles

        # Assert
        $worksheet = $excelPackage.Workbook.Worksheets['Release']
        $worksheet.Cells[2, 2].Hyperlink.Address `
        | Should -Be $mockExportData.Release.ProjectPortalUrl.OriginalString
    }

    It 'Should format header column' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelease -ExportData $mockExportData -ExcelPackage $excelPackage -Styles $mockStyles

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName ImportExcel\Set-ExcelRange -ParameterFilter {
            $Bold -eq $mockStyles.Header.Bold -and
            $BackgroundColor -eq $mockStyles.Header.BackgroundColor -and
            $FontColor -eq $mockStyles.Header.FontColor -and
            $AutoSize -eq $true
        }
    }

    It 'Should auto-size the second column' {
        # Arrange
        $excelPackage = ImportExcel\Open-ExcelPackage -Create -Path $testPath

        # Act
        Export-ExcelRelease -ExportData $mockExportData -ExcelPackage $excelPackage -Styles $mockStyles

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName ImportExcel\Set-ExcelRange -ParameterFilter {
            $AutoSize -eq $true
        }
    }
}
