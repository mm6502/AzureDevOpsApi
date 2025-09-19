[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ParentUrl' {
    It 'Should convert ApiUrl correctly' {
        # Arrange
        $childUrl = 'https://dev.azure.com/org/project/_apis/wit/workitems/123'
        $parentId = 345
        $expected = 'https://dev.azure.com/org/project/_apis/wit/workitems/345'

        # Act
        $result = ConvertTo-ParentUrl -ChildUrl $childUrl -ParentId $parentId

        # Assert
        $result | Should -Be $expected
    }

    It 'Should convert PortalUrl correctly' {
        # Arrange
        $childUrl = 'https://dev.azure.com/org/project/_workitems/edit/123'
        $parentId = 345
        $expected = 'https://dev.azure.com/org/project/_workitems/edit/345'

        # Act
        $result = ConvertTo-ParentUrl -ChildUrl $childUrl -ParentId $parentId

        # Assert
        $result | Should -Be $expected
    }

    It 'Should not modify URLs without matching patterns' {
        # Arrange
        $childUrl = 'https://dev.azure.com/org/project/some/other/url'
        $parentId = 789

        #  Act
        $result = ConvertTo-ParentUrl -ChildUrl $childUrl -ParentId $parentId

        # Assert
        $result | Should -Be $childUrl
    }
}
