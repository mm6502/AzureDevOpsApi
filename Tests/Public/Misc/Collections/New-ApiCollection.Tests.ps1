BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-ApiCollection' {

    BeforeAll {
        $global:AzureDevOpsApi_CollectionUri = $null
    }

    AfterAll {
        $global:AzureDevOpsApi_CollectionUri = $null
    }

    It 'Returns an ApiCollection object' {
        # Arrange
        $global:AzureDevOpsApi_CollectionUri = 'https://dev.azure.com/myorg/'
        $expected = $global:PSTypeNames.AzureDevOpsApi.ApiCollection
        # Act
        $collection = New-ApiCollection
        # Assert
        $collection.PSObject.TypeNames[0] | Should -Be $expected
    }

    It 'Formats the CollectionUri correctly' {
        # Arrange
        $global:AzureDevOpsApi_CollectionUri = 'https://dev.azure.com/myorg/'
        $expected = $global:AzureDevOpsApi_CollectionUri
        # Act
        $collection = New-ApiCollection -CollectionUri $expected
        # Assert
        $collection.CollectionUri | Should -Be $expected
    }

    It 'Sets the ApiVersion correctly' {
        # Arrange
        $global:AzureDevOpsApi_CollectionUri = 'https://dev.azure.com/myorg/'
        # Act
        $collection = New-ApiCollection -ApiVersion '6.1-preview'
        # Assert
        $collection.ApiVersion | Should -Be '6.1-preview'
    }

    It 'Handles CollectionUri given <name>' -ForEach @(
        @{ Name = '$null'; CollectionUri = $null }
        @{ Name = 'empty string'; CollectionUri = '' }
    ) {
        # Arrange
        $global:AzureDevOpsApi_CollectionUri = 'https://dev.azure.com/myorg/'
        $expected = $global:AzureDevOpsApi_CollectionUri
        # Act
        $collection = New-ApiCollection -CollectionUri $CollectionUri
        # Assert
        $collection.CollectionUri | Should -Be $expected
    }

    It 'Handles ApiVersion given <name>' -ForEach @(
        @{ Name = '$null'; ApiVersion = $null }
        @{ Name = 'empty string'; ApiVersion = '' }
    ) {
        # Arrange
        $global:AzureDevOpsApi_CollectionUri = 'https://dev.azure.com/myorg/'

        $expected = '7.0'
        Mock -ModuleName $ModuleName -CommandName Use-ApiVersion -MockWith {
            $expected
        }

        # Act
        $collection = New-ApiCollection -ApiVersion $ApiVersion
        # Assert
        $collection.ApiVersion | Should -Be $expected
    }

    It 'Should create a new ApiCollection object' {
        # Arrange
        $expected = @{
            CollectionUri = 'https://dev.azure.com/myorg/'
            ApiVersion   = '6.0'
        }

        # Act
        $apiCollection = New-ApiCollection `
            -CollectionUri $expected.CollectionUri `
            -ApiVersion $expected.ApiVersion

        # Assert
        $apiCollection | Should -BeOfType ([PSCustomObject])
        $apiCollection.PSTypeNames | Should -Contain $global:PSTypeNames.AzureDevOpsApi.ApiCollection
        $apiCollection.CollectionUri | Should -Be $expected.CollectionUri
        $apiCollection.ApiVersion | Should -Be $expected.ApiVersion
    }
}
