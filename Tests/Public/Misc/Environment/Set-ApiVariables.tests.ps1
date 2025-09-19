[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable.'
)]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Ok for testing purposes.'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Set-ApiVariables' {

    BeforeEach {
        $expected = @{
            CollectionUri = Format-Uri -Uri 'https://example.com/expected_collection'
            Project       = 'ExpectedProject'
            Authorization = 'PAT'
            Token         = 'invalid_token'
            ApiCredential = New-ApiCredential -Authorization 'PAT' -Token 'invalid_token'
            ApiVersion    = '6.3'
        }

        Mock -ModuleName $ModuleName -CommandName Get-Project -MockWith {
            @{
                id = 'id'
                name = $expected.Project
            }
        }

        Mock -ModuleName $ModuleName -CommandName Get-ConnectionData -MockWith {
            $true
        }
    }

    It 'Should set global and script variables for DefaultFromDate' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Set-Variable -MockWith { } -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_DefaultFromDate'
        }

        # Act
        Set-ApiVariables

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Set-Variable -Exactly -Times 1 -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_DefaultFromDate' -and
            $Value -eq ([DateTime]'2000-01-01Z')
        }
    }

    It 'Should set global and script variables for ApiVersion' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Set-Variable -MockWith { } -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_ApiVersion'
        }

        # Act
        Set-ApiVariables -ApiVersion $expected.ApiVersion

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Set-Variable -Exactly -Times 1 -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_ApiVersion' -and
            $Value -eq ($expected.ApiVersion)
        }
    }

    It 'Should set global and script variables for CollectionUri' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Set-Variable -MockWith { } -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_CollectionUri'
        }

        # Act
        Set-ApiVariables -CollectionUri $expected.CollectionUri

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Set-Variable -Exactly -Times 1 -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_CollectionUri' -and
            $Value -eq ($expected.CollectionUri)
        }
    }

    It 'Should set global and script variables for Project' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Set-Variable -MockWith { } -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_Project'
        }

        # Act
        Set-ApiVariables -Project $expected.Project

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Set-Variable -Exactly -Times 1 -ParameterFilter {
            $Name -eq 'AzureDevOpsApi_Project' -and
            $Value -eq ($expected.Project)
        }
    }

    It 'Should call Add-ApiCollection when CollectionUri is provided' {
        # Arrange
        $testCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionsCache -MockWith {
            $testCache
        }

        # Act
        Set-ApiVariables -CollectionUri $expected.CollectionUri -ApiVersion $expected.ApiVersion

        # Assert
        $collection = Find-ApiCollection -CollectionUri $expected.CollectionUri
        $collection | Should -Not -BeNullOrEmpty
        $collection.CollectionUri | Should -Be $expected.CollectionUri
    }

    It 'Should call Add-ApiCredential when ApiCredential is provided' {
        # Arrange
        $testApiCollectionsCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionsCache -MockWith {
            $testApiCollectionsCache
        }

        $testApiCredentialsCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiCredentialsCache -MockWith {
            $testApiCredentialsCache
        }

        Mock -ModuleName $ModuleName -CommandName Add-ApiCredential -MockWith { }

        # Act
        Set-ApiVariables `
            -CollectionUri $expected.CollectionUri `
            -ApiCredential $expected.ApiCredential

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Add-ApiCredential -Exactly -Times 1 -ParameterFilter {
            $CollectionUri -eq $expected.CollectionUri -and
            $ApiCredential -eq $expected.ApiCredential
        }
    }

    It 'Should not call Add-ApiCredential when ApiCredential is not provided' {
        # Arrange
        $testApiCredentialsCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiCredentialsCache -MockWith {
            $testApiCredentialsCache
        }

        # Act
        Set-ApiVariables -CollectionUri $expected.CollectionUri

        # Assert
        $result = Find-ApiCredential -CollectionUri $expected.CollectionUri
        $result | Should -BeNullOrEmpty
    }

    Context 'For Old Style Authorization' {
        It 'Should handle old style PAT token parameter' {
            # Arrange
            $testApiCollectionsCache = @{ }
            Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionsCache -MockWith {
                $testApiCollectionsCache
            }

            # Act
            Set-ApiVariables `
                -CollectionUri $expected.CollectionUri `
                -Authorization $expected.ApiCredential.Authorization `
                -Token 'test_token'

            # Assert
            $credential = Find-ApiCredential -CollectionUri $expected.CollectionUri
            $credential | Should -Not -BeNullOrEmpty
            $credential.Authorization | Should -Be 'PAT'
            $credential.Token | Should -Not -BeNullOrEmpty
            $credential.Token | Should -BeOfType [SecureString]
        }

        It 'Should handle old style Basic credential parameter' {
            # Arrange
            $testApiCollectionsCache = @{ }
            Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionsCache -MockWith {
                $testApiCollectionsCache
            }
            $testCred = [PSCredential]::new("user", (ConvertTo-SecureString "pass" -AsPlainText -Force))

            # Act
            Set-ApiVariables -CollectionUri $expected.CollectionUri -Authorization 'Basic' -Credential $testCred

            # Assert
            $credential = Find-ApiCredential -CollectionUri $expected.CollectionUri
            $credential | Should -Not -BeNullOrEmpty
            $credential.Authorization | Should -Be 'Basic'
            $credential.Credential | Should -Be $testCred
        }

        It 'Should ignore credentials when CollectionUri is not provided' {
            # Arrange
            Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }

            # Act
            Set-ApiVariables -Authorization 'PAT' -Token 'test_token'

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Write-Warning -Times 1 -ParameterFilter {
                $Message -like '*CollectionUri was not provided*'
            }
        }
    }
}
