[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Use-ApiCredential' {

    BeforeAll {
        $collectionUri = 'https://dev.azure.com/myorg'
        $project       = 'myproject'
        $credential    = New-ApiCredential
    }

    BeforeEach {
        $global:AzureDevOpsApi_ApiCredential = $null
    }

    It 'Should return the provided ApiCredential' {
        # Act
        $result = Use-ApiCredential -ApiCredential $credential -CollectionUri $collectionUri -Project $project
        # Assert
        $result | Should -Be $credential
    }

    It 'Should find the ApiCredential from the cache' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Find-ApiCredential -MockWith { $credential }

        # Act
        $result = Use-ApiCredential -CollectionUri $collectionUri -Project $project

        # Assert
        $result | Should -Be $credential
    }

    It 'Should use the global ApiCredential if not found in cache' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Find-ApiCredential
        $global:AzureDevOpsApi_ApiCredential = $credential

        # Act
        $result = Use-ApiCredential -CollectionUri $collectionUri -Project $project

        # Assert
        $result.Authorization | Should -Be $credential.Authorization
    }

    It 'Should return $null if no ApiCredential is found' {
        # Arrange
        $expected = @{
            Authorization = 'Default'
        }

        Mock -ModuleName $ModuleName -CommandName Find-ApiCredential

        $global:AzureDevOpsApi_ApiCredential = $null

        # Act
        $result = Use-ApiCredential `
            -CollectionUri $collectionUri `
            -Project $project `
            -WarningAction 'SilentlyContinue'

        # Assert
        $result | Should -BeNullOrEmpty
    }
}
