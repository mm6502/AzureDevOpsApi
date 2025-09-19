[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-DetermineOutputFileName' {

    BeforeAll {
        $testDate = [DateTime]::new(2023, 5, 15, 10, 30, 0, [DateTimeKind]::Utc)
        $testExportData = [PSCustomObject]@{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Release    = @{
                CreatedDate = $testDate
                Project     = 'TestProject'
            }
        }
    }

    It 'Should return the input path when it ends with .xlsx' {
        # Act
        $result = Export-DetermineOutputFileName `
            -ExportData $testExportData `
            -Path '~\test\file.xlsx' `
            -FileExtension 'xlsx'

        # Assert
        $result | Should -Be '~\test\file.xlsx'
    }

    It 'Should use constant filename when UseConstantFileName is specified' {
        # Arrange
        $expected = Join-Path -Path '~\test' -ChildPath 'ReleaseNotes.xlsx'

        # Act
        $result = Export-DetermineOutputFileName `
            -ExportData $testExportData `
            -Path '~\test' `
            -UseConstantFileName `
            -FileExtension 'xlsx'

        # Assert
        $result | Should -Be $expected
    }

    It 'Should generate correct filename with provided path and date' {
        # Arrange
        $expected = Join-Path -Path '~\test' -ChildPath 'ReleaseNotes_TestProject_2023-05-15_10-30.xlsx'

        # Act
        $result = Export-DetermineOutputFileName `
            -ExportData $testExportData `
            -Path '~\test' `
            -FileExtension 'xlsx'

        # Assert
        $result | Should -Be $expected
    }

    It 'Should handle custom TimeZone string' {
        # Arrange
        $expected = Join-Path -Path '~\test' -ChildPath 'ReleaseNotes_TestProject_2023-05-15_06-30.xlsx'

        Mock -ModuleName $ModuleName -CommandName Get-CustomTimeZone -MockWith {
            return [TimeZoneInfo]::FindSystemTimeZoneById('Eastern Standard Time')
        }

        Mock -ModuleName $ModuleName -CommandName ConvertTo-TimeZoneDateTime -MockWith {
            return [DateTime]::new(2023, 5, 15, 6, 30, 0)
        }

        # Act
        $result = Export-DetermineOutputFileName `
            -ExportData $testExportData `
            -Path '~\test' `
            -FileExtension 'xlsx' `
            -TimeZone 'Eastern Standard Time'

        # Assert
        $result | Should -Be $expected
        Should -Invoke -ModuleName $ModuleName -CommandName Get-CustomTimeZone -Times 1
        Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-TimeZoneDateTime -Times 1
    }

    It 'Should handle TimeZoneInfo object' {
        # Arrange
        $expected = Join-Path -Path '~\test' -ChildPath 'ReleaseNotes_TestProject_2023-05-15_03-30.xlsx'

        $customTimeZone = [TimeZoneInfo]::FindSystemTimeZoneById('Pacific Standard Time')

        Mock -ModuleName $ModuleName -CommandName ConvertTo-TimeZoneDateTime -MockWith {
             return [DateTime]::new(2023, 5, 15, 3, 30, 0)
        }

        # Act
        $result = Export-DetermineOutputFileName `
            -ExportData $testExportData `
            -Path '~\test' `
            -FileExtension 'xlsx' `
            -TimeZone $customTimeZone

        # Assert
        $result | Should -Be $expected
        Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-TimeZoneDateTime -Times 1
    }
}
