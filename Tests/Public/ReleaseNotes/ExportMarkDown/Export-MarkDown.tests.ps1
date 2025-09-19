[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-MarkDown' {

    BeforeAll {
        $testExportData = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Items      = @()
            Release    = [PSCustomObject] @{
                CreatedDate = (Get-Date)
                DateTo      = (Get-Date)
            }
        }

        Mock -ModuleName $ModuleName -CommandName Show-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Set-Content -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Add-Content -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Export-MarkDownSection -MockWith { }
    }

    It 'Should accept custom work item types' {
        # Arrange
        $customTesterTypes = @(
            [PSCustomObject] @{type = 'customBug'; name = "CustomBugs" }
        )

        $customManagementTypes = @(
            [PSCustomObject] @{type = 'customTask'; name = "CustomTasks" }
        )

        # Act & Assert
        { $null = Export-MarkDown `
                -ExportData $testExportData `
                -TesterWorkItemTypes $customTesterTypes `
                -ManagementWorkItemTypes $customManagementTypes
        } `
        | Should -Not -Throw
    }

    It 'Should handle empty export data' {
        # Act & Assert
        { $null = Export-MarkDown -ExportData $testExportData } `
        | Should -Not -Throw
    }

    It 'Should respect custom ProgressPreference' {
        # Arrange
        $customPreference = 'SilentlyContinue'

        # Act
        $null = Export-MarkDown `
            -ExportData $testExportData `
            -ProgressPreference $customPreference

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Export-MarkDownSection -ParameterFilter {
            $ProgressPreference -eq $customPreference
        }
    }

    # TODO: Add more meaningful tests
}
