[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemPortalUrl' {
    BeforeAll {
        $mockCollectionUri = 'https://dev.azure.com/myorg'
        $mockProject = 'myproject'
        $mockWorkItemId = 123
        $expectedUrl = "https://dev.azure.com/myorg/myproject/_workitems/edit/123"
    }

    It 'Should return the correct portal URL for a work item' {
        # Act
        $result = Get-WorkItemPortalUrl `
            -CollectionUri $mockCollectionUri `
            -Project $mockProject `
            -WorkItem $mockWorkItemId

        # Assert
        $result | Should -Be $expectedUrl
    }

    It 'Should handle a collection URI with trailing slash' {
        # Arrange
        $mockCollectionUriWithSlash = 'https://dev.azure.com/myorg/'

        # Act
        $result = Get-WorkItemPortalUrl `
            -CollectionUri $mockCollectionUriWithSlash `
            -Project $mockProject `
            -WorkItem $mockWorkItemId

        # Assert
        $result | Should -Be $expectedUrl
    }

    It 'Should throw an error when CollectionUri is null or empty' {
        # Act & Assert
        { Get-WorkItemPortalUrl -CollectionUri $null -Project $mockProject -WorkItemId $mockWorkItemId } | Should -Throw
        { Get-WorkItemPortalUrl -CollectionUri '' -Project $mockProject -WorkItemId $mockWorkItemId } | Should -Throw
    }

    It 'Should throw an error when Project is null or empty' {
        # Act & Assert
        { Get-WorkItemPortalUrl -CollectionUri $mockCollectionUri -Project $null -WorkItemId $mockWorkItemId } | Should -Throw
        { Get-WorkItemPortalUrl -CollectionUri $mockCollectionUri -Project '' -WorkItemId $mockWorkItemId } | Should -Throw
    }

    It 'Should throw an error when WorkItemId is 0 or negative' {
        # Act & Assert
        { Get-WorkItemPortalUrl -CollectionUri $mockCollectionUri -Project $mockProject -WorkItemId 0 } | Should -Throw
        { Get-WorkItemPortalUrl -CollectionUri $mockCollectionUri -Project $mockProject -WorkItemId -1 } | Should -Throw
    }
}
