[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-ReleaseNotesDataItem' {

    BeforeAll {
        $mockWorkItem = @{
            id     = 123
            url    = "https://dev.azure.com/org/project/_workitems/edit/123"
            fields = @{
                "System.WorkItemType" = "Bug"
                "System.Title"        = "Test Bug"
            }
        }
    }

    It 'Should create a new ReleaseNotesDataItem with WorkItemUrl parameter' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItemUrl $mockWorkItem.url
        # Assert
        $result | Should -Not -BeNull
        $result.PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
        $result.ApiUrl | Should -Be $mockWorkItem.url
    }

    It 'Should create a new ReleaseNotesDataItem with WorkItem parameter' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItem $mockWorkItem
        # Assert
        $result | Should -Not -BeNull
        $result.PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
        $result.ApiUrl | Should -Be $mockWorkItem.url
        $result.WorkItem | Should -Be $mockWorkItem
    }

    It 'Should have correct ScriptProperties' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItem $mockWorkItem
        # Assert
        $result.WorkItemType | Should -Be "Bug"
        $result.Title | Should -Be "Test Bug"
    }

    It 'Should initialize ReasonsList and RelationsList as empty arrays' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItemUrl 123
        # Assert
        ($null -ne $result.ReasonsList) | Should -BeTrue
        $result.ReasonsList.Count | Should -Be 0
        ($null -ne $result.RelationsList) | Should -BeTrue
        $result.RelationsList.Count | Should -Be 0
    }

    It 'Should set Exclude property to false by default' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItemUrl 123
        # Assert
        $result.Exclude | Should -BeFalse
    }

    It 'Should handle empty Reasons and Relations' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItemUrl 123
        # Assert
        $result.Reasons | Should -Be ""
        $result.Relations | Should -Be ""
        $result.RelationsCounts | Should -Be ""
    }

    It 'Should format Relations correctly when less than or equal to 5 items' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItemUrl 123
        $result.RelationsList = @(
            @{ Name = "Parent"; Relations = @(1, 2, 3) },
            @{ Name = "Child"; Relations = @(4, 5) }
        )
        # Assert
        $result.Relations | Should -Be "Parent (1, 2, 3), Child (4, 5)"
    }

    It 'Should format Relations correctly when more than 5 items' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItemUrl 123
        $result.RelationsList = @(
            @{ Name = "Parent"; Relations = @(1, 2, 3, 4, 5, 6) }
        )
        # Assert
        $result.Relations | Should -Be "Parent (many)"
    }

    It 'Should format RelationsCounts correctly' {
        # Act
        $result = New-ReleaseNotesDataItem -WorkItemUrl 123
        $result.RelationsList = @(
            @{ Name = "Parent"; Relations = @(1, 2, 3) },
            @{ Name = "Child"; Relations = @(4, 5) }
        )
        # Assert
        $result.RelationsCounts | Should -Be "Parent (3), Child (2)"
    }
}
