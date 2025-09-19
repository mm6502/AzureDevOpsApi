BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-CommitArtifactUriObject' {

    It 'Should convert a valid commit URI to an ArtifactUri object' {
        # Arrange
        $collectionUri = 'https://dev-tfs/tfs/internal_projects'
        $projectId = '890669f3-5144-4962-a81f-a96feb160a10'
        $repositoryId = 'c2b7419e-9006-4d2c-9f7e-e9f29a89adce'
        $commitId = '548ded02bb9b602833ddefe26347e99e71ef434d'

        $expected = [PSCustomObject]@{
            CollectionUri = $collectionUri
            ProjectId = $projectId
            RepositoryId = $repositoryId
            CommitId = $commitId
            ArtifactUri = "vstfs:///Git/Commit/$($projectId)%2f$($repositoryId)%2f$($commitId)"
            CommitUri = "$($collectionUri)/$($projectId)/_apis/git/repositories/$($repositoryId)/commits/$($commitId)"
        }

        # Act
        $result = ConvertTo-CommitArtifactUriObject -CommitUri $expected.CommitUri

        # Assert
        $result | Should -BeOfType [PSCustomObject]
        $result.Uri | Should -Be $expected.CommitUri
        $result.CollectionUri | Should -Be $expected.CollectionUri
        $result.ProjectId | Should -Be $expected.ProjectId
        $result.RepositoryId | Should -Be $expected.RepositoryId
        $result.CommitId | Should -Be $expected.CommitId
        $result.ArtifactUri | Should -Be $expected.ArtifactUri
    }

    It 'Should handle pipeline input' {
        # Arrange
        $commitUri = 'https://dev-tfs/tfs/internal_projects/890669f3-5144-4962-a81f-a96feb160a10/_apis/git/repositories/c2b7419e-9006-4d2c-9f7e-e9f29a89adce/commits/548ded02bb9b602833ddefe26347e99e71ef434d'

        # Act
        $result = $commitUri | ConvertTo-CommitArtifactUriObject

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.ArtifactUri | Should -Be 'vstfs:///Git/Commit/890669f3-5144-4962-a81f-a96feb160a10%2Fc2b7419e-9006-4d2c-9f7e-e9f29a89adce%2F548ded02bb9b602833ddefe26347e99e71ef434d'
    }

    It 'Should handle multiple commit URIs' {
        # Arrange
        $commitUris = @(
            'https://dev-tfs/tfs/internal_projects/890669f3-5144-4962-a81f-a96feb160a10/_apis/git/repositories/c2b7419e-9006-4d2c-9f7e-e9f29a89adce/commits/548ded02bb9b602833ddefe26347e99e71ef434d',
            'https://dev-tfs/tfs/internal_projects/890669f3-5144-4962-a81f-a96feb160a10/_apis/git/repositories/d3c8420e-9106-4e2c-9f7e-e9f29a89adce/commits/649ded02bb9b602833ddefe26347e99e71ef434e'
        )

        # Act
        $results = $commitUris | ConvertTo-CommitArtifactUriObject

        # Assert
        $results | Should -HaveCount 2
        $results[0].ArtifactUri | Should -Be 'vstfs:///Git/Commit/890669f3-5144-4962-a81f-a96feb160a10%2Fc2b7419e-9006-4d2c-9f7e-e9f29a89adce%2F548ded02bb9b602833ddefe26347e99e71ef434d'
        $results[1].ArtifactUri | Should -Be 'vstfs:///Git/Commit/890669f3-5144-4962-a81f-a96feb160a10%2Fd3c8420e-9106-4e2c-9f7e-e9f29a89adce%2F649ded02bb9b602833ddefe26347e99e71ef434e'
    }

    It 'Should return null for invalid commit URI' {
        # Arrange
        $invalidUri = 'https://invalid-uri/not-a-commit'

        # Act
        $result = ConvertTo-CommitArtifactUriObject -CommitUri $invalidUri

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle commit URIs with additional path segments' {
        # Arrange
        $commitUri = 'https://dev-tfs/tfs/internal_projects/890669f3-5144-4962-a81f-a96feb160a10/_apis/git/repositories/c2b7419e-9006-4d2c-9f7e-e9f29a89adce/commits/548ded02bb9b602833ddefe26347e99e71ef434d/changes'

        # Act
        $result = ConvertTo-CommitArtifactUriObject -CommitUri $commitUri

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.ArtifactUri | Should -Be 'vstfs:///Git/Commit/890669f3-5144-4962-a81f-a96feb160a10%2Fc2b7419e-9006-4d2c-9f7e-e9f29a89adce%2F548ded02bb9b602833ddefe26347e99e71ef434d'
    }
}
