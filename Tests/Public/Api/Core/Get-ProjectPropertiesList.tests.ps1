[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ProjectPropertiesList' {

    BeforeAll {
        $expected = @{
            Connection = New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
    }

    It 'Should return project properties' {
        # Arrange
        $expectedProperties = @{
            'key1' = 'value1'
            'key2' = 'value2'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            $expectedProperties
        }

        Mock -ModuleName $ModuleName -CommandName Get-Project -MockWith {
            [pscustomobject] @{ url = $ProjectUri }
        }

        # Act
        $result = Get-ProjectPropertiesList `
            -CollectionUri $CollectionUri `
            -Project $ProjectName

        # Assert
        $result.Count | Should -Be $expectedProperties.Keys.Count
        foreach ($key in $expectedProperties.Keys) {
            $result.$key | Should -Be $expectedProperties.$key
        }
    }

    It 'Should return only specified properties' {
        # Arrange
        $expectedProperties = @{
            'key1' = 'value1'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { $expectedProperties }

        # Act
        $result = Get-ProjectPropertiesList `
            -CollectionUri $CollectionUri `
            -Project $ProjectName `
            -Keys 'key1'

        # Assert
        $result.Count | Should -Be 1
        $result.'key1' | Should -Be $expectedProperties.'key1'
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*keys=key1*"
        }
    }

    It 'Should handle null or empty project' {
        # Arrange
        $global:AzureDevOpsApi_Project = "some_project"

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            @{ ProjectUri = 'https://dev.azure.com/myorg/some_project' }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            @{ value = $null }
        }

        # Act & Assert
        { Get-ProjectPropertiesList `
            -CollectionUri $CollectionUri `
            -Project $null `
        } | Should -Not -Throw
        { Get-ProjectPropertiesList `
            -CollectionUri $CollectionUri `
            -Project '' `
        } | Should -Not -Throw
    }
}
