BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ApiCredentialsList' {

    BeforeEach {
        $global:ApiCredentialsCache = @{}
    }

    It 'Should return an empty list when no credentials are registered' {
        # Act
        $result = Get-ApiCredentialsList
        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should return a list of registered credentials' {
        # Arrange
        $expected = @{
            CollectionUri  = Format-Uri -Uri 'https://example.org'
            Project        = 'Project1'
            ApiCredential  = New-ApiCredential -Authorization 'Bearer' -Token 'token1'
            SkipValidation = $true
        }

        $null = Add-ApiCredential @expected

        # Act
        $result = @(Get-ApiCredentialsList)

        # Assert
        $result.Count | Should -Be 1
        $result.CollectionUri | Should -Be $expected.CollectionUri
        $result.Project | Should -Be $expected.Project
        $result.ApiCredential | Should -Be $expected.ApiCredential
    }

    It 'Should return multiple registered credentials' {
        # Arrange
        $Project1 = @{
            CollectionUri  = Format-Uri -Uri 'https://example.org'
            Project        = 'Project1'
            ApiCredential  = New-ApiCredential -Authorization 'Bearer' -Token 'token1'
            SkipValidation = $true
        }
        $Project2 = @{
            CollectionUri  = Format-Uri -Uri 'https://example.com'
            Project        = 'Project2'
            ApiCredential  = New-ApiCredential -Authorization 'PAT' -Token 'token1'
            SkipValidation = $true
        }

        $null = Add-ApiCredential @Project1
        $null = Add-ApiCredential @Project2

        # Act
        $result = Get-ApiCredentialsList | Sort-Object -Property CollectionUri,Project

        # Assert
        $result.Count | Should -Be 2
        $result[0].CollectionUri | Should -Be $Project2.CollectionUri
        $result[0].Project | Should -Be $Project2.Project
        $result[0].ApiCredential | Should -Be $Project2.ApiCredential
        $result[1].CollectionUri | Should -Be $Project1.CollectionUri
        $result[1].Project | Should -Be $Project1.Project
        $result[1].ApiCredential | Should -Be $Project1.ApiCredential
    }
}
