BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ApiProject' {

    It 'Should convert from a project Name' {
        # Arrange
        $expected = @{
            CollectionUri      = 'https://dev.azure.org/samples/'
            ProjectName        = 'CAFE'
            ProjectNameBaseUri = 'https://dev.azure.org/samples/CAFE/'
        }

        # Act
        $result = ConvertTo-ApiProject `
            -Project $expected.ProjectName `
            -CollectionUri $expected.CollectionUri

        # Assert
        $result.CollectionUri | Should -Be $expected.CollectionUri
        $result.ProjectUri | Should -BeNullOrEmpty
        $result.ProjectId | Should -BeNullOrEmpty
        $result.ProjectName | Should -Be $expected.ProjectName
        $result.ProjectNameBaseUri | Should -Be $expected.ProjectNameBaseUri
    }

    It 'Should convert from a project ID' {
        # Arrange
        $expected = @{
            CollectionUri  = 'https://dev.azure.org/samples/'
            ProjectId      = '00000000-0000-0000-cafe-000000000000'
            ProjectUri     = 'https://dev.azure.org/samples/_apis/projects/00000000-0000-0000-cafe-000000000000'
            ProjectBaseUri = 'https://dev.azure.org/samples/00000000-0000-0000-cafe-000000000000/'
        }

        # Act
        $result = ConvertTo-ApiProject `
            -Project $expected.ProjectId `
            -CollectionUri $expected.CollectionUri

        # Assert
        $result.CollectionUri | Should -Be $expected.CollectionUri
        $result.ProjectId | Should -Be $expected.ProjectId
        $result.ProjectName | Should -BeNullOrEmpty
        $result.ProjectUri | Should -Be $expected.ProjectUri
        $result.ProjectBaseUri | Should -Be $expected.ProjectBaseUri
    }

    It 'Should convert a project object' {
        # Arrange
        $projectId = '00000000-0000-0000-cafe-000000000000'

        $expected = @{
            CollectionUri  = 'https://dev.azure.org/test/'
            ProjectId      = $projectId
            ProjectName    = 'Test Project'
            ProjectUri     = "https://dev.azure.org/test/_apis/projects/$($projectId)"
            ProjectBaseUri = "https://dev.azure.org/test/$($projectId)/"
        }

        $source = [PSCustomObject] @{
            id   = $expected.ProjectId
            name = $expected.ProjectName
            url  = $expected.ProjectUri
        }

        # Act
        $result = ConvertTo-ApiProject -Project $source

        # Assert
        $result | Should -BeOfType [PSCustomObject]
        $result.ProjectId | Should -Be $expected.ProjectId
        $result.ProjectName | Should -Be $expected.ProjectName
        $result.ProjectUri | Should -Be $expected.ProjectUri
        $result.ProjectBaseUri | Should -Be $expected.ProjectBaseUri
    }

    Context 'Project like Uri' -ForEach @(
        @{ CollectionUri = 'https://dev.azure.org/samples/' }
    ) {

        It 'Should convert when conains name, variant <name>' -ForEach @(
            @{
                Name          = '1 name portal self'
                CollectionUri = $CollectionUri
                Project       = "$($CollectionUri)IAM"
                ProjectName   = 'IAM'
            }
            @{
                Name          = '2 name api self'
                CollectionUri = $CollectionUri
                Project       = "$($CollectionUri)_apis/projects/IAM"
                ProjectName   = 'IAM'
            }
            @{
                Name          = '3 name api workitem'
                CollectionUri = $CollectionUri
                Project       = "$($CollectionUri)IAM/_apis/wit/workitems/12345"
                ProjectName   = 'IAM'
            }
        ) {
            # Arrange
            $expected = @{
                CollectionUri      = $CollectionUri
                ProjectName        = $ProjectName
                ProjectUri         = Join-Uri -Base $CollectionUri -RelativeUri "_apis/projects/$($ProjectName)" -NoTrailingSlash
                ProjectNameBaseUri = Join-Uri -Base $CollectionUri -RelativeUri $ProjectName
            }

            # Act
            $result = ConvertTo-ApiProject `
                -Project $Project `
                -CollectionUri $expected.CollectionUri

            # Assert
            $result.CollectionUri | Should -Be $expected.CollectionUri
            $result.ProjectName | Should -Be $expected.ProjectName
            $result.ProjectNameBaseUri | Should -Be $expected.ProjectNameBaseUri
        }

        It 'Should convert when conains id, variant <name>' -ForEach @(
            @{
                Name          = '4 id portal self'   ;
                CollectionUri = $CollectionUri
                Project       = "$($CollectionUri)00000000-0000-0000-cafe-000000000000"
                ProjectId     = '00000000-0000-0000-cafe-000000000000'
            }
            @{
                Name          = '5 id api self'      ;
                CollectionUri = $CollectionUri
                Project       = "$($CollectionUri)_apis/projects/00000000-0000-0000-cafe-000000000000"
                ProjectId     = '00000000-0000-0000-cafe-000000000000'
            }
            @{
                Name          = '6 id api workitem'  ;
                CollectionUri = $CollectionUri
                Project       = "$($CollectionUri)00000000-0000-0000-cafe-000000000000/_apis/wit/workitems/12345"
                ProjectId     = '00000000-0000-0000-cafe-000000000000'
            }
        ) {
            # Arrange
            $expected = @{
                CollectionUri    = $CollectionUri
                ProjectId        = $ProjectId
                ProjectUri       = Join-Uri -Base $CollectionUri -RelativeUri "_apis/projects/$($ProjectId)" -NoTrailingSlash
                ProjectIdBaseUri = Join-Uri -Base $CollectionUri -RelativeUri $ProjectId
            }

            # Act
            $result = ConvertTo-ApiProject `
                -Project $Project `
                -CollectionUri $expected.CollectionUri

            # Assert
            $result.CollectionUri | Should -Be $expected.CollectionUri
            $result.ProjectId | Should -Be $expected.ProjectId
            $result.ProjectUri | Should -Be $expected.ProjectUri
            $result.ProjectIdBaseUri | Should -Be $expected.ProjectIdBaseUri
        }
    }
}
