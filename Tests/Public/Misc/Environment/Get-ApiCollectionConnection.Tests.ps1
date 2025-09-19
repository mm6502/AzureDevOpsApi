[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'For testing only'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ApiCollectionConnection' {

    BeforeAll {
        $mockCollectionUri = 'https://dev.azure.com/myorg/'
        $mockApiVersion = '6.0'
        $mockCredential = [pscredential]::new('user', ('password' | ConvertTo-SecureString -AsPlainText -Force))
        $mockApiCredential = New-ApiCredential `
            -Credential $mockCredential `
            -Authorization 'Basic'

        Mock -ModuleName $ModuleName -CommandName Find-ApiCollection -MockWith {
            return New-ApiCollection `
                -CollectionUri $mockCollectionUri `
                -ApiVersion    $mockApiVersion
        }

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith { $mockCollectionUri }
        Mock -ModuleName $ModuleName -CommandName Use-ApiVersion -MockWith { $mockApiVersion }
        Mock -ModuleName $ModuleName -CommandName Use-ApiCredential -MockWith { $mockApiCredential }
    }

    It 'Returns a valid ApiConnection object' {
        # Act
        $connection = Get-ApiCollectionConnection -Uri 'https://dev.azure.com/myorg/myproject'

        # Assert
        $connection.PSObject.TypeNames | Should -Contain $global:PSTypeNames.AzureDevOpsApi.ApiCollectionConnection
        $connection.CollectionUri | Should -Be $mockCollectionUri
        $connection.ApiCredential.PSObject.TypeNames | Should -Contain $global:PSTypeNames.AzureDevOpsApi.ApiCredential
        $connection.ApiVersion | Should -Be $mockApiVersion
    }

    It 'Uses CollectionUri parameter when provided' {
        # Act
        $connection = Get-ApiCollectionConnection -CollectionUri $mockCollectionUri

        # Assert
        $connection.CollectionUri | Should -Be $mockCollectionUri
    }

    It 'Handles missing CollectionUri and Uri parameters' {
        # Act
        { Get-ApiCollectionConnection } | Should -Not -Throw
    }

    It 'Uses provided ApiCredential when specified' {
        # Act
        $connection = Get-ApiCollectionConnection `
            -CollectionUri $mockCollectionUri `
            -ApiCredential $mockApiCredential

        # Assert
        $connection.ApiCredential | Should -Be $mockApiCredential
    }

    It 'Uses provided ApiVersion when specified' {
        # Arrange
        $mockApiVersion = '6.1'

        # Act
        $connection = Get-ApiCollectionConnection `
            -CollectionUri $mockCollectionUri `
            -ApiVersion $mockApiVersion

        # Assert
        $connection.ApiVersion | Should -Be $mockApiVersion
    }
}
