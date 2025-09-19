[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-PatchDocumentUpdate' {

    Context 'Callback' {
        It 'Should validate callback parameter is a ScriptBlock' {
            # Arrange
            $invalidCallback = "not a scriptblock"

            # Act & Assert
            { New-PatchDocumentCreate -Callback $invalidCallback } |
            Should -Throw -ExpectedMessage "*Cannot process argument transformation on parameter 'Callback'*"
        }

        It 'Should accept valid ScriptBlock as callback' {
            # Arrange
            $validCallback = { param($x) $x }

            # Act & Assert
            { New-PatchDocumentCreate -Callback $validCallback } `
            | Should -Not -Throw
        }

        It 'Should handle null callback parameter' {
            # Act & Assert
            { New-PatchDocumentCreate -Callback $null } |
            Should -Not -Throw
        }

        It 'Should execute callback function when provided' {
            # Arrange
            $callback = {
                param($document)
                $document.Operations += [PSCustomObject]@{
                    op    = 'add'
                    path  = '/fields/Custom.Field'
                    value = 'CustomValue'
                }
                $document
            }

            # Act
            $result = New-PatchDocumentCreate -Callback $callback

            # Assert
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/Custom.Field' } `
            | Should -Not -BeNullOrEmpty
        }
    }

    Context 'SourceWorkItem' {
        It 'Should create patch document with source work item and properties' {
            # Arrange
            $sourceWorkItem = [PSCustomObject] @{
                rev    = 1
                url    = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
                fields = [PSCustomObject] @{
                    'System.WorkItemType' = 'Bug'
                    field1                = 'value1'
                    field2                = 'value2'
                }
            }

            $properties = @('field1', 'field2')

            # Act
            $result = New-PatchDocumentUpdate `
                -SourceWorkItem $sourceWorkItem `
                -Properties $properties

            # Assert
            $result.WorkItemType | Should -Be $sourceWorkItem.fields.'System.WorkItemType'
            $result.Operations.Count | Should -BeGreaterThan 0
            $result.WorkItemUrl | Should -Be $sourceWorkItem.url
            $result.Operations `
            | Where-Object { $_.op -eq 'test' -and $_.path -eq '/rev' } `
            | Should -Not -BeNullOrEmpty
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/field1' } `
            | Should -Not -BeNullOrEmpty
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/field2' } `
            | Should -Not -BeNullOrEmpty
        }

        It 'Should create patch document with additional data' {
            # Arrange
            $sourceWorkItem = [PSCustomObject] @{
                url    = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
                rev    = 1
                fields = [PSCustomObject] @{
                    'System.WorkItemType' = 'Bug'
                }
            }

            $data = @{
                'System.Title'       = 'New Title'
                'System.Description' = 'New Description'
            }

            # Act
            $result = New-PatchDocumentUpdate -SourceWorkItem $sourceWorkItem -Data $data

            # Assert
            $result.WorkItemType | Should -Be $sourceWorkItem.fields.'System.WorkItemType'
            $result.Operations `
            | Where-Object { $_.op -eq 'test' -and $_.path -eq '/rev' } `
            | Should -Not -BeNullOrEmpty
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/System.Title' } `
            | Should -Not -BeNullOrEmpty
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/System.Description' } `
            | Should -Not -BeNullOrEmpty
        }

        It 'Should handle tags modifications when tags modifications are specified' {
            # Arrange
            $sourceWorkItem = [PSCustomObject] @{
                url    = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
                rev    = 1
                fields = [PSCustomObject] @{
                    'System.WorkItemType' = 'Bug'
                    'System.Tags'         = 'oldtag1; oldtag2'
                }
            }

            $tagsToAdd = @('newtag1')
            $tagsToRemove = @('oldtag1')

            # Act
            $result = New-PatchDocumentUpdate `
                -SourceWorkItem $sourceWorkItem `
                -TagsToAdd $tagsToAdd `
                -TagsToRemove $tagsToRemove

            # Assert
            $tags = $result.Operations `
            | Where-Object { $_.op -eq 'add' -and $_.path -eq '/fields/System.Tags' }
            $tags | Should -Not -BeNullOrEmpty
            $tags.value | Should -BeLike '*oldtag2*'
            $tags.value | Should -Not -BeLike '*oldtag1*'
            $tags.value | Should -BeLike '*newtag1*'
        }

        It 'Should handle tags modifications when tags modifications are not specified' {
            # Arrange
            $sourceWorkItem = [PSCustomObject] @{
                url    = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
                rev    = 1
                fields = [PSCustomObject] @{
                    'System.WorkItemType' = 'Bug'
                    'System.Tags'         = 'oldtag1; oldtag2'
                }
            }

            # Act
            $result = New-PatchDocumentUpdate `
                -SourceWorkItem $sourceWorkItem

            # Assert
            $tags = $result.Operations `
            | Where-Object { $_.op -eq 'add' -and $_.path -eq '/fields/System.Tags' }
            $tags | Should -BeNullOrEmpty
        }

        It 'Should handle null source work item' {
            # Act
            $result = New-PatchDocumentUpdate -SourceWorkItem $null

            # Assert
            $result.Operations `
            | Where-Object { $_.op -eq 'test' -and $_.path -eq '/rev' } `
            | Should -BeNullOrEmpty
        }

        It 'Should combine all operation types' {
            # Arrange
            $sourceWorkItem = [PSCustomObject] @{
                rev = 1;
                fields = [PSCustomObject] @{ field1 = 'value1' }
            }
            $properties = @('field1')
            $data = @{ 'System.Title' = 'New Title' }
            $tagsToAdd = @('newtag')
            $tagsToRemove = @('oldtag')

            # Act
            $result = New-PatchDocumentUpdate `
                -SourceWorkItem $sourceWorkItem `
                -Properties $properties `
                -Data $data `
                -TagsToAdd $tagsToAdd `
                -TagsToRemove $tagsToRemove

            # Assert
            $result.Operations `
            | Where-Object { $_.op -eq 'test' -and $_.path -eq '/rev' } `
            | Should -Not -BeNullOrEmpty
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/field1' } `
            | Should -Not -BeNullOrEmpty
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/System.Title' } `
            | Should -Not -BeNullOrEmpty
            $result.Operations `
            | Where-Object { $_.path -eq '/fields/System.Tags' } `
            | Should -Not -BeNullOrEmpty
        }
    }
}
