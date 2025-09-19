[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Update-WorkItem' {

    BeforeAll {
        $expected = [PSCustomObject] @{
            Connection = New-TestApiProjectConnection
            WorkItemId = 123
            Fields = @{
                'System.Title' = 'Updated Title'
                'System.Description' = 'Updated Description'
            }
        }

        $sourceWorkItem = [PSCustomObject] @{
            id = $expected.WorkItemId
            url = $expected.Connection.ProjectUrl + "/_apis/wit/workitems/$($expected.WorkItemId)"
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            [PSCustomObject] @{
                id = $expected.WorkItemId
                fields = $expected.Fields
            }
        }
    }

    It 'Should call API with correct parameters' {
        # Arrange
        $mockPatchDocument = New-PatchDocumentUpdate -SourceWorkItem $sourceWorkItem

        # Act
        $result = Update-WorkItem `
            -PatchDocument $mockPatchDocument

        # Assert
        $result.id | Should -Be $expected.WorkItemId
        $result.fields | Should -Be $expected.Fields

        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*/_apis/wit/workitems/$($expected.WorkItemId)*" -and
            $Method -eq 'PATCH'
        }
    }
}
