[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ExportData' {
    BeforeAll {
        $mockCollection = 'https://dev.azure.com/myorg'
        $mockProject = 'MyProject'
        $mockDateFrom = (Get-Date).AddDays(-7)
        $mockDateTo = Get-Date
        $mockAsOf = Get-Date
        $mockByUser = 'user@example.com'
        $mockTargetBranch = 'main'
        $mockTrunkBranch = 'trunk'
        $mockReleaseBranch = 'release'

        $mockReleaseNotesDataItem = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            ApiUrl     = 'https://dev.azure.com/myorg/_apis/wit/workitems/1'
            Exclude    = $false
        }

        Mock -ModuleName $ModuleName -CommandName ConvertTo-ExportDataRelease -MockWith {
            return [PSCustomObject]@{
                Collection = $mockCollection
                Project    = $mockProject
            }
        }

        Mock -ModuleName $ModuleName -CommandName ConvertTo-ExportDataConsole -MockWith {
            return @('Console Item')
        }

        Mock -ModuleName $ModuleName -CommandName ConvertTo-ExportDataRelations -MockWith {
            return @('Relation Item')
        }

        Mock -ModuleName $ModuleName -CommandName ConvertTo-ExportDataWorkItems -MockWith {
            return @('WorkItem Item')
        }
    }

    Context 'When using ItemsList parameter set' {
        It 'Should convert list of items to export data' {
            # Act
            $result = ConvertTo-ExportData -ItemsList @($mockReleaseNotesDataItem) `
                -Collection $mockCollection `
                -Project $mockProject `
                -DateFrom $mockDateFrom `
                -DateTo $mockDateTo `
                -AsOf $mockAsOf `
                -ByUser $mockByUser `
                -TargetBranch $mockTargetBranch `
                -TrunkBranch $mockTrunkBranch `
                -ReleaseBranch $mockReleaseBranch

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Release | Should -Not -BeNullOrEmpty
            $result.Console | Should -Contain 'Console Item'
            $result.Relations | Should -Contain 'Relation Item'
            $result.WorkItems | Should -Contain 'WorkItem Item'

            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataRelease -Times 1
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataConsole -Times 1
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataRelations -Times 1
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataWorkItems -Times 1
        }
    }

    Context 'When using ItemsTable parameter set' {
        It 'Should convert hashtable of items to export data' {
            # Arrange
            $mockItemsTable = @{
                $mockReleaseNotesDataItem.ApiUrl = $mockReleaseNotesDataItem
            }

            # Act
            $result = ConvertTo-ExportData -ItemsTable $mockItemsTable `
                -Collection $mockCollection `
                -Project $mockProject

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Release | Should -Not -BeNullOrEmpty
            $result.Console | Should -Contain 'Console Item'
            $result.Relations | Should -Contain 'Relation Item'
            $result.WorkItems | Should -Contain 'WorkItem Item'

            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataRelease -Times 1
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataConsole -Times 1
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataRelations -Times 1
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataWorkItems -Times 1
        }
    }

    Context 'When items are to be excluded' {
        It 'Should remove excluded items from the result' {
            # Arrange
            $mockExcludedItem = [PSCustomObject]@{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
                ApiUrl     = 'https://dev.azure.com/myorg/_apis/wit/workitems/2'
                Exclude    = $true
            }

            # Act
            $result = ConvertTo-ExportData -ItemsList @($mockReleaseNotesDataItem, $mockExcludedItem) `
                -Collection $mockCollection `
                -Project $mockProject

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Release | Should -Not -BeNullOrEmpty
            $result.Console | Should -Contain 'Console Item'
            $result.Relations | Should -Contain 'Relation Item'
            $result.WorkItems | Should -Contain 'WorkItem Item'

            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportDataConsole -Times 1 -ParameterFilter {
                $Items.Count -eq 1 -and $Items.ContainsKey($mockReleaseNotesDataItem.ApiUrl)
            }
        }
    }
}
