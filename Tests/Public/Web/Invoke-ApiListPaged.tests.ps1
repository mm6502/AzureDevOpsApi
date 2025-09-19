[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Invoke-ApiListPaged' {

    BeforeAll {
        $baseUri = 'https://non.existent.domain.qqq/api/data'

        $allItems = @('A', 'B', 'C')
    }

    It 'Should return a list of items from the API' {
        # Arrange
        $response = @{ value = $allItems }
        $expected = @{
            Uri = $baseUri
            Content = $response | ConvertTo-Json
            Items = $allItems
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            @{ Content = $expected.Content }
        }

        # Act
        $result = Invoke-ApiListPaged -Uri $expected.Uri

        # Assert
        $result.Count | Should -Be $expected.Items.Count
        $result[0] | Should -Be $expected.Items[0]
    }

    It 'Should handle pagination correctly <Skip>' -ForEach @(
        @{ Skip = 0; Top = 1; expectedItems = @( 'A' ) }
        @{ Skip = 1; Top = 1; expectedItems = @( 'B' ) }
        @{ Skip = 2; Top = 1; expectedItems = @( 'C' ) }
    ) {
        # Arrange
        $response = @{ value = $expectedItems }
        $expected = @{
            Uri     = $baseUri
            Content = $response | ConvertTo-Json
            Items   = $expectedItems
        }

        # If paging not handled correctly, the API will throw
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            throw 'API error'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            @{ Content = $expected.Content }
        } -ParameterFilter {
            ($Uri -like "*skip=$($Skip)*") `
            -and `
            ($Uri -like "*top=$($Top)*")
        }

        # Act
        $result = Invoke-ApiListPaged -Uri $expected.Uri -Skip $Skip -Top $Top

        # Assert
        $result.Count | Should -Be $expectedItems.Count
        $result[0] | Should -Be $expected.Items[0]
    }

    It 'Should handle API errors gracefully' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            throw 'API error'
        }

        # Act and Assert
        { Invoke-ApiListPaged -Uri $baseUri } | Should -Throw 'API error'
    }

    It 'Should handle invalid API URLs' {
        # Arrange
        $invalidApiUrl = 'invalid://url'

        # Act and Assert
        { Invoke-ApiListPaged -ApiUrl $invalidApiUrl } | Should -Throw
    }
}
