BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Find-ApiCollection' {

    BeforeAll {
        $c1 = New-ApiCollection -CollectionUri 'https://dev-tfs/tfs/internal_projects/' -ApiVersion '6.0'
        $c2 = New-ApiCollection -CollectionUri 'https://new-tfs/tfs/other_projects/' -ApiVersion '7.0'

        $testCache = @{
            $c1.CollectionUri = $c1
            $c2.CollectionUri = $c2
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionsCache -MockWith {
            $testCache
        }
    }

    It 'Returns cached collection Uri when Uri starts with cached collection Uri' {
        # Arrange
        $uri = 'https://dev-tfs/tfs/internal_projects/_apis/projects/SIZP_KSED'
        $expected = 'https://dev-tfs/tfs/internal_projects/'

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            $expected
        }

        # Act & Assert
        (Find-ApiCollection -Uri $uri).CollectionUri | Should -Be $expected
    }

    It 'Returns cached collection Uri when Uri is contained in cached collection Uri' {
        # Arrange
        $uri = 'https://dev-tfs'
        $expected = 'https://dev-tfs/tfs/internal_projects/'

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            $expected
        }

        # Act & Assert
        (Find-ApiCollection -Uri $uri).CollectionUri | Should -Be $expected
    }

    It 'Returns new ApiCollection when Uri is not cached and no global variables are set' {
        # Arrange
        $uri = 'https://new-tfs/tfs/projects/'
        $expected = [PSCustomObject] @{
            CollectionUri = $uri
            ApiVersion = '5.0'
        }

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            $expected.CollectionUri
        }

        Mock -ModuleName $ModuleName -CommandName Use-ApiVersion -MockWith {
            $expected.ApiVersion
        }

        # Act & Assert
        $result = Find-ApiCollection -Uri $expected.CollectionUri

        # Assert
        $result.CollectionUri | Should -Be ($expected.CollectionUri)
        $result.ApiVersion | Should -Be ($expected.ApiVersion)
    }

    It 'Returns new ApiCollection with global variables when Uri is not cached' {
        # Arrange
        $expected = [PSCustomObject] @{
            CollectionUri = 'https://global-tfs/tfs/projects/'
            ApiVersion = '6.0'
        }

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            $expected.CollectionUri
        }

        Mock -ModuleName $ModuleName -CommandName Use-ApiVersion -MockWith {
            $expected.ApiVersion
        }

        # Act
        $result = Find-ApiCollection -Uri "NOT-CACHED-URI"

        # Assert
        $result.CollectionUri | Should -Be $expected.CollectionUri
        $result.ApiVersion | Should -Be $expected.ApiVersion
    }

    It 'Returns any cached when Uri is null or empty' {
        # Arrange
        $cache = Get-ApiCollectionsCache
        $expected = $cache.Keys | Select-Object -First 1

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            $expected
        }

        # Act & Assert
        (Find-ApiCollection -Uri $null).CollectionUri | Should -Be $expected
        (Find-ApiCollection -Uri '').CollectionUri | Should -Be $expected
    }
}
