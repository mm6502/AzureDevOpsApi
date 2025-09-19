[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-MarkDownSection' {

    BeforeAll {

        $testFile = 'TestDrive:\output.md'

        $mockWorkItems = @(
            [PSCustomObject]@{
                WorkItemId   = 1
                WorkItemType = 'Bug'
                State        = 'closed'
                Title        = 'Test Bug 1'
                PortalUrl    = 'https://dev.azure.com/org/project/_workitems/edit/1'
            },
            [PSCustomObject]@{
                WorkItemId   = 2
                WorkItemType = 'Feature'
                State        = 'closed'
                Title        = 'Test Feature 1'
                PortalUrl    = 'https://dev.azure.com/org/project/_workitems/edit/2'
            }
        )
        $mockExportData = [PSCustomObject]@{
            PSTypeName = 'PStypeNames.AzureDevOpsApi.ExportData'
            WorkItems  = $mockWorkItems
        }
    }

    BeforeEach {
        Remove-Item -Path $testFile -ErrorAction SilentlyContinue
    }

    It 'Should create markdown file with correct header' {
        # Arrange
        $header = 'Test Header'

        # Act
        Export-MarkDownSection `
            -ExportData $mockExportData `
            -File $testFile `
            -Header $header

        # Assert
        $content = Get-Content -Path $testFile
        $content | Should -Contain '## <span class="underline">Test Header</span>'
    }

    It 'Should create sections based on SubHeaderHashTable' {
        # Arrange
        $subHeaders = @(
            @{ type = 'Bug'; name = 'Bugs' },
            @{ type = 'Feature'; name = 'Features' }
        )

        # Act
        Export-MarkDownSection `
            -ExportData $mockExportData `
            -File $testFile `
            -SubHeaders $subHeaders

        # Assert
        $content = Get-Content -Path $testFile
        $content | Should -Contain '### Bugs'
        $content | Should -Contain '### Features'
        $content | Should -Contain '1. [#1](https://dev.azure.com/org/project/_workitems/edit/1) - Test Bug 1'
        $content | Should -Contain '1. [#2](https://dev.azure.com/org/project/_workitems/edit/2) - Test Feature 1'
    }

    It 'Should skip empty sections' {
        # Arrange
        $subHeaders = @(
            @{ type = 'Task'; name = 'Tasks' }
        )

        # Act
        Export-MarkDownSection `
            -ExportData $mockExportData `
            -File $testFile `
            -SubHeaders $subHeaders

        # Assert
        $content = Get-Content -Path $testFile
        $content | Should -Not -Contain '### Tasks'
    }

    It 'Should filter by state' {
        # Arrange
        $mockWorkItemsWithState = @(
            [PSCustomObject]@{
                WorkItemId   = 1
                WorkItemType = 'Bug'
                State        = 'active'
                Title        = 'Active Bug'
                PortalUrl    = 'https://dev.azure.com/org/project/_workitems/edit/1'
            },
            [PSCustomObject]@{
                WorkItemId   = 2
                WorkItemType = 'Bug'
                State        = 'closed'
                Title        = 'Closed Bug'
                PortalUrl    = 'https://dev.azure.com/org/project/_workitems/edit/2'
            }
        )
        $mockDataWithState = [PSCustomObject]@{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            WorkItems  = $mockWorkItemsWithState
        }
        $subHeaders = @(
            @{ type = 'Bug'; name = 'Bugs' }
        )

        # Act
        Export-MarkDownSection `
            -ExportData $mockDataWithState `
            -File $testFile `
            -SubHeaders $subHeaders `
            -State 'active'

        # Assert
        $content = Get-Content -Path $testFile
        $content | Should -Contain '1. [#1](https://dev.azure.com/org/project/_workitems/edit/1) - Active Bug'
        $content | Should -Not -Contain '- Closed Bug'
    }
}
