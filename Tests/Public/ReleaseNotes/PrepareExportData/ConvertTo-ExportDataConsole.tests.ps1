[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ExportDataConsole' {
    BeforeAll {
        $mockItems = @{
            'Item1' = @{
                WorkItemId   = 1
                PortalUrl    = 'https://example.com/1'
                WorkItemType = 'Bug'
                Reasons      = @('Reason1', 'Reason2')
                Relations    = @('Relation1', 'Relation2')
            }
            'Item2' = @{
                WorkItemId   = 2
                PortalUrl    = 'https://example.com/2'
                WorkItemType = 'Task'
                Reasons      = @('Reason3')
                Relations    = @('Relation3')
            }
        }
    }

    It 'Should convert hashtable to ExportDataConsoleItem objects using parameter input' {
        $result = ConvertTo-ExportDataConsole -Items $mockItems

        $result | Should -HaveCount 2
        $result[0].PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ExportDataConsoleItem'
        $result[1].PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ExportDataConsoleItem'
    }

    It 'Should handle empty input' {
        $emptyItems = @{}
        $result = ConvertTo-ExportDataConsole -Items $emptyItems
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle single item input' {
        $singleItem = @{
            'Item1' = @{
                WorkItemId   = 1
                PortalUrl    = 'https://example.com/1'
                WorkItemType = 'Bug'
                Reasons      = @('Reason1')
                Relations    = @('Relation1')
            }
        }
        $result = ConvertTo-ExportDataConsole -Items $singleItem

        $result | Should -HaveCount 1
        $result[0].PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ExportDataConsoleItem'
        $result[0].WorkItemId | Should -Be 1
        $result[0].PortalUrl | Should -Be 'https://example.com/1'
        $result[0].WorkItemType | Should -Be 'Bug'
        $result[0].Reasons | Should -Be @('Reason1')
        $result[0].Relations | Should -Be @('Relation1')
    }
}
