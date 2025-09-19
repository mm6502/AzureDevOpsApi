[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'For testing only'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Add-ApiCredential' {

    BeforeAll {
        $username = 'testuser'
        $password = 'testpassword'
        $securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
        $credential = [pscredential]::new($username, $securePassword)
    }

    Context 'When given ApiCredential' {

        It 'Adds a credential to the credential cache' {
            # Arrange
            $global:ApiCredentialsCache = @{ }

            $expected = @{
                CollectionUri = 'http://TestTarget/'
                Project       = ''
                ApiCredential = New-ApiCredential
            }

            Mock -ModuleName $ModuleName -CommandName Get-ConnectionData -MockWith { $true }

            # Act
            $result = Add-ApiCredential `
                -ApiCredential $expected.ApiCredential `
                -CollectionUri $expected.CollectionUri `
                -Project $expected.Project `
                -PassThru

            # Assert
            $result | Should -Be $expected.ApiCredential
            $global:ApiCredentialsCache.Count | Should -Be 1
            $global:ApiCredentialsCache[$expected.CollectionUri][$expected.Project] `
            | Should -Be $expected.ApiCredential
        }
    }

    Context 'When given attributes for ApiCredential' {

        It 'Adds a credential to the credential cache' {
            # Arrange
            $global:ApiCredentialsCache = @{ }

            $expected = @{
                CollectionUri = 'http://TestTarget/'
                Project       = ''
                Authorization = 'PAT'
                Token         = 'invalid_token'
                ApiCredential = New-ApiCredential -Authorization $expected.Authorization -Token $expected.Token
            }

            Mock -ModuleName $ModuleName -CommandName Get-ConnectionData -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName New-ApiCredential -MockWith { $expected.ApiCredential }

            # Act
            $result = Add-ApiCredential `
                -Authorization $expected.Authorization `
                -Token $expected.Token `
                -CollectionUri $expected.CollectionUri `
                -Project $expected.Project `
                -PassThru

            # Assert
            $result | Should -Be $expected.ApiCredential
            $global:ApiCredentialsCache.Count | Should -Be 1
            $global:ApiCredentialsCache[$expected.CollectionUri][$expected.Project] `
            | Should -Be $expected.ApiCredential
        }
    }

    Context 'When not given a CollectionUri' {

        It 'Adds a credential to the credential cache for the default collection ('''')' {
            # Arrange
            $global:ApiCredentialsCache = @{ }
            $newCredential = [pscredential]::new('newuser', $securePassword)
            $expected = @{
                CollectionUri = ''
                ProjectId     = 'id'
                ProjectName   = 'Project'
                ApiCredential = New-ApiCredential -Credential $newCredential
            }
            # Mock responses
            Mock -ModuleName $ModuleName -CommandName Get-ConnectionData -MockWith { $true }
            Mock -ModuleName $ModuleName -CommandName Get-Project -MockWith {
                @{
                    id                 = $expected.ProjectId
                    name               = $expected.ProjectName
                }
            }

            # Act
            $WarningPreference = 'SilentlyContinue'
            $result = Add-ApiCredential `
                -ApiCredential $expected.ApiCredential `
                -Project $expected.ProjectName `
                -WarningAction SilentlyContinue `
                -PassThru

            # Assert
            $result | Should -Be $expected.ApiCredential
            $global:ApiCredentialsCache.Count | Should -Be 1
            $global:ApiCredentialsCache[''][$expected.ProjectName] `
            | Should -Be $expected.ApiCredential
        }

        It 'Throws an error for an invalid credential' {
            { Add-ApiCredential -Credential $null -Target 'TestTarget' } | Should -Throw
        }

        It 'Throws an error for an empty target' {
            { Add-ApiCredential -Credential $testCredential -Target '' } | Should -Throw
        }
    }

    It 'Overwrites an existing credential for the same target' {
        # Arrange

        # Reset cache
        $global:ApiCredentialsCache = @{ }
        $newCredential = [pscredential]::new('newuser', $securePassword)

        $expected = @{
            CollectionUri = 'http://TestTarget/'
            ProjectId     = 'id'
            ProjectName   = 'Project'
            ApiCredential = New-ApiCredential -Credential $newCredential
        }

        # Mpck responses
        Mock -ModuleName $ModuleName -CommandName Get-ConnectionData -MockWith { $true }
        Mock -ModuleName $ModuleName -CommandName Get-Project -MockWith {
            @{
                id   = $expected.ProjectId
                name = $expected.ProjectName
            }
        }

        # Add existing credential
        $null = Add-ApiCredential `
            -ApiCredential (New-ApiCredential) `
            -Project $expected.ProjectName `
            -CollectionUri $expected.CollectionUri `

        # Act
        # Replace existing credential
        $result = Add-ApiCredential `
            -ApiCredential $expected.ApiCredential `
            -CollectionUri $expected.CollectionUri `
            -Project $expected.ProjectName `
            -PassThru

        # Assert
        $result | Should -Be $expected.ApiCredential
        $global:ApiCredentialsCache.Count | Should -Be 1
        $global:ApiCredentialsCache[$expected.CollectionUri][$expected.ProjectName] `
        | Should -Be $expected.ApiCredential
        $global:ApiCredentialsCache[$expected.CollectionUri][$expected.ProjectId] `
        | Should -Be $expected.ApiCredential
    }
}
