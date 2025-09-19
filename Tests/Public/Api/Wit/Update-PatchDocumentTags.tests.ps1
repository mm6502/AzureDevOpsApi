[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Update-PatchDocumentTags' {

    BeforeAll {
        function Get-PatchDocumentFieldItem {
            <#
                .SYNOPSIS
                    Test helper function to locate the tags field item.
            #>
            param(
                $PatchDocument
            )
            $PatchDocument.Operations `
            | Where-Object { $_.path -eq '/fields/System.Tags' } `
            | Select-Object -First 1
        }
    }

    BeforeEach {
        $mockPatchDocument = New-PatchDocument
    }

    It 'Should add new tags to empty patch document' {
        # Arrange
        $emptyPatchDoc = New-PatchDocument
        $mockTags = @('tag1', 'tag2', 'tag3')

        # Act
        Update-PatchDocumentTags -PatchDocument $emptyPatchDoc -Tags $mockTags

        # Assert
        $result = Get-PatchDocumentFieldItem $emptyPatchDoc
        $result | Should -Not -BeNullOrEmpty
        $result.op | Should -Be 'add'
        $result.path | Should -Be '/fields/System.Tags'
        $result.value | Should -Be 'tag1; tag2; tag3'
    }

    It 'Should handle empty tags array' {
        # Arrange
        $emptyTags = @()

        # Act
        Update-PatchDocumentTags -PatchDocument $mockPatchDocument -Tags $emptyTags

        # Assert
        $result = Get-PatchDocumentFieldItem $mockPatchDocument
        $result | Should -Not -BeNullOrEmpty
        $result.value | Should -BeNullOrEmpty
    }

    It 'Should handle null tags parameter' {
        # Act
        $result = Update-PatchDocumentTags -PatchDocument $mockPatchDocument -Tags $null

        # Assert
        $result = Get-PatchDocumentFieldItem $mockPatchDocument
        $result | Should -Not -BeNullOrEmpty
        $result.value | Should -BeNullOrEmpty
    }

    It 'Should properly format tags with semicolons' {
        # Arrange
        $tagsWithSemicolons = @('tag;1', 'tag;2')

        # Act
        $result = Update-PatchDocumentTags -PatchDocument $mockPatchDocument -Tags $tagsWithSemicolons

        # Assert
        $result = Get-PatchDocumentFieldItem $mockPatchDocument
        $result | Should -Not -BeNullOrEmpty
        $result.value | Should -Be 'tag; 1; tag; 2'
    }

    It 'Should handle tags with special characters' {
        # Arrange
        $specialTags = @('tag@1', 'tag#2', 'tag$3')

        # Act
        $result = Update-PatchDocumentTags -PatchDocument $mockPatchDocument -Tags $specialTags

        # Assert
        $result = Get-PatchDocumentFieldItem $mockPatchDocument
        $result | Should -Not -BeNullOrEmpty
        $result.value | Should -Be 'tag@1; tag#2; tag$3'
    }

    It 'Should append to existing patch document operations' {
        # Arrange
        $mockPatchDocument.Operations += [PSCustomObject] @{
            op = 'add'
            path = '/fields/System.Tags'
            value = 'tag1; tag2; tag3'
        }

        $tagsToSet = @('tag4', 'tag5', 'tag8')

        # Act
        $result = Update-PatchDocumentTags `
            -PatchDocument $mockPatchDocument `
            -Tags $tagsToSet `
            -Add 'tag6', 'tag7' `
            -Remove 'tag4', 'tag8'

        # Assert
        $result = Get-PatchDocumentFieldItem $mockPatchDocument
        $result | Should -Not -BeNullOrEmpty
        $result.value | Should -Be 'tag5; tag6; tag7'
    }
}
