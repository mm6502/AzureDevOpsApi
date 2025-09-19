BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Split-ApiUri' {

    It 'Should split the URI correctly for the first pattern' {
        # Arrange
        $uri = 'https://dev.azure.com/myorg/myproject/myteam/_apis/work/boards/myboard/charts/mychart?api-version=5.0'
        # Act
        $result = Split-ApiUri -Uri $uri
        # Assert
        $result.collection | Should -Be 'https://dev.azure.com/myorg'
        $result.project | Should -Be 'myproject'
        $result.team | Should -Be 'myteam'
    }

    It 'Should split the URI correctly for the second pattern' {
        # Arrange
        $uri = 'https://dev.azure.com/myorg/_apis/projects/myproject?api-version=5.0'
        # Act
        $result = Split-ApiUri -Uri $uri
        # Assert
        $result.collection | Should -Be 'https://dev.azure.com/myorg'
        $result.project | Should -Be 'myproject'
    }

    It 'Should split the URI correctly for the third pattern' {
        # Arrange
        $uri = 'https://dev-tfs/tfs/myorg/myproject/_apis/some/path'
        # Act
        $result = Split-ApiUri -Uri $uri
        # Assert
        $result.collection | Should -Be 'https://dev-tfs/tfs/myorg'
        $result.project | Should -Be 'myproject'
    }

    It 'Should split the URI correctly for the fourth pattern' {
        # Arrange
        $uri = 'https://dev.azure.com/myorg/myproject/'
        # Act
        $result = Split-ApiUri -Uri $uri
        # Assert
        $result.collection | Should -Be 'https://dev.azure.com/myorg'
        $result.project | Should -Be 'myproject'
    }

    It 'Should return null for an invalid URI' {
        # Arrange
        $uri = 'invalid-uri'
        # Act
        $result = Split-ApiUri -Uri $uri
        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle empty inputs - <name>' -ForEach @(
        @{ Name = '$null';  Uri = $null }
        @{ Name = 'empty string';  Uri = [string]::Empty }
    ) {
        # Act
        $result = Split-ApiUri -Uri $Uri
        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle custom patterns' {
        # Arrange
        $uri = 'https://myserver.com/myorg/myproject/myteam/mypath/'
        $pattern = '^(?<server>.*)/(?<org>.*)/(?<project>.*)/(?<team>.*)/(?<path>.*)/$'
        # Act
        $result = Split-ApiUri -Uri $uri -Patterns $pattern
        # Assert
        $result.server | Should -Be 'https://myserver.com'
        $result.org | Should -Be 'myorg'
        $result.project | Should -Be 'myproject'
        $result.team | Should -Be 'myteam'
        $result.path | Should -Be 'mypath'
    }
}
