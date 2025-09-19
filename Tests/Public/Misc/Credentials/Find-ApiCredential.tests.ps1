[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Find-ApiCredential' {

    BeforeEach {
        $global:ApiCredentialsCache = @{}
    }

    It 'Should return null when no credentials are found' {
        # Act
        $result = Find-ApiCredential -CollectionUri 'https://example.com' -Project 'MyProject'

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should return the collection credentials when no project is specified' {
        # Arrange
        $collectionUri = Format-Uri -Uri 'https://example.com'
        $collectionCredential = [pscustomobject]@{ Username = 'user'; Token = 'token' }
        $global:ApiCredentialsCache[$collectionUri] = @{ '' = $collectionCredential }

        # Act
        $result = Find-ApiCredential -CollectionUri $collectionUri

        # Assert
        $result | Should -Be $collectionCredential
    }

    It 'Should return the project credentials when found' {
        # Arrange
        $collectionUri = Format-Uri -Uri 'https://example.com'
        $project = 'MyProject'
        $projectCredential = [pscustomobject]@{ Username = 'user'; Token = 'token' }
        $global:ApiCredentialsCache[$collectionUri] = @{ $project = $projectCredential }

        # Act
        $result = Find-ApiCredential -CollectionUri $collectionUri -Project $project

        # Assert
        $result | Should -Be $projectCredential
    }

    It 'Should return the default credentials when project credentials are not found and PreventFallback is not set' {
        # Arrange
        $collectionUri = Format-Uri -Uri 'https://example.com'
        $project = 'MyProject'
        $defaultCredential = @{ Username = 'user'; Token = 'token' }
        $global:ApiCredentialsCache[$collectionUri] = @{ '' = $defaultCredential }

        # Act
        $result = Find-ApiCredential -CollectionUri $collectionUri -Project $project

        # Assert
        $result | Should -Be $defaultCredential
    }

    It 'Should not return default credentials when PreventFallback is set' {
        # Arrange
        $collectionUri = 'https://example.com'
        $project = 'MyProject'
        $defaultCredential = [pscustomobject]@{ Username = 'user'; Token = 'token' }
        $global:ApiCredentialsCache[$collectionUri] = @{ '' = $defaultCredential }

        # Act
        $result = Find-ApiCredential -CollectionUri $collectionUri -Project $project -PreventFallback

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle trailing slashes in CollectionUri' {
        # Arrange
        $collectionUri = Format-Uri -Uri 'https://example.com/'
        $project = 'MyProject'
        $projectCredential = @{ Username = 'user'; Token = 'token' }
        $global:ApiCredentialsCache[$collectionUri] = @{ $project = $projectCredential }

        # Act
        $result = Find-ApiCredential -CollectionUri $collectionUri -Project $project

        # Assert
        $result | Should -Be $projectCredential
    }
}
