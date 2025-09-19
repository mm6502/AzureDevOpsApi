[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ExportDataRelations' {

    BeforeAll {

        $mockItem1ApiUrl = 'https://example.com/_apis/wit/workitems/1'
        $mockItem2ApiUrl = 'https://example.com/_apis/wit/workitems/2'

        $mockItem1 = @{
            WorkItemId    = 1
            ApiUrl        = $mockItem1ApiUrl
            PortalUrl     = 'https://example.com/1'
            WorkItemType  = 'Bug'
            RelationsList = @(
                @{
                    Name      = 'Parent'
                    Relations = @($mockItem2ApiUrl)
                }
            )
        }

        $mockItem2 = @{
            WorkItemId    = 2
            ApiUrl        = $mockItem2ApiUrl
            PortalUrl     = 'https://example.com/2'
            WorkItemType  = 'Feature'
            RelationsList = @(
                @{
                    Name      = 'Child'
                    Relations = @($mockItem1ApiUrl)
                }
            )
        }

        $mockItems = @{
            $mockItem1.ApiUrl = $mockItem1
            $mockItem2.ApiUrl = $mockItem2
        }
    }

    It 'Should return correct number of relation items' {
        # Act
        $result = ConvertTo-ExportDataRelations -Items $mockItems

        # Assert
        $result.Count | Should -Be 2
    }

    It 'Should return items with correct PSTypeName' {
        # Act
        $result = ConvertTo-ExportDataRelations -Items $mockItems

        # Assert
        $result | ForEach-Object {
            $_.PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ExportDataRelationItem'
        }
    }

    It 'Should correctly map work item properties' {
        # Act
        $result = ConvertTo-ExportDataRelations -Items $mockItems

        # Assert
        $firstItem = $result | Where-Object { $_.'A.WorkItemId' -eq 1 }
        $firstItem.'A.WorkItemId' | Should -Be $mockItem1.WorkItemId
        $firstItem.'A.PortalUrl' | Should -Be $mockItem1.PortalUrl
        $firstItem.'A.ApiUrl' | Should -Be $mockItem1.ApiUrl
        $firstItem.'A.WorkItemType' | Should -Be $mockItem1.WorkItemType
        $firstItem.'A.RelationName' | Should -Be $mockItem1.RelationsList[0].Name
        $firstItem.'B.WorkItemId' | Should -Be $mockItem2.WorkItemId
        $firstItem.'B.WorkItemType' | Should -Be $mockItem2.WorkItemType
        $firstItem.'B.PortalUrl' | Should -Be $mockItem2.PortalUrl
        $firstItem.'B.ApiUrl' | Should -Be $mockItem2.ApiUrl
    }

    It 'Should handle items with no relations' {
        # Arrange
        $itemUrl = 'https://example.com/_apis/wit/workitems/1'
        $noRelationsItems = @{
            $itemUrl = @{
                WorkItemId    = 1
                ApiUrl        = $itemUrl
                PortalUrl     = 'https://example.com/1'
                WorkItemType  = 'Bug'
                RelationsList = @()
            }
        }

        # Act
        $result = ConvertTo-ExportDataRelations -Items $noRelationsItems

        # Assert
        $result.Count | Should -Be 0
    }

    It 'Should handle multiple relations for a single item' {
        # Arrange
        $multipleRelationsItems = @{
            1 = @{
                WorkItemId    = 1
                PortalUrl     = 'https://example.com/1'
                WorkItemType  = 'Bug'
                RelationsList = @(
                    @{
                        Name      = 'Parent'
                        Relations = @(2, 3)
                    }
                )
            }
            2 = @{
                WorkItemId    = 2
                PortalUrl     = 'https://example.com/2'
                WorkItemType  = 'Feature'
                RelationsList = @()
            }
            3 = @{
                WorkItemId    = 3
                PortalUrl     = 'https://example.com/3'
                WorkItemType  = 'Epic'
                RelationsList = @()
            }
        }

        # Act
        $result = ConvertTo-ExportDataRelations -Items $multipleRelationsItems

        # Assert
        $result.Count | Should -Be 2
        $result[0].'B.WorkItemId' | Should -Be 2
        $result[1].'B.WorkItemId' | Should -Be 3
    }
}
