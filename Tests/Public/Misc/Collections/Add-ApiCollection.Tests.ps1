BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Add-ApiCollection' {

    BeforeEach {
        $testCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionsCache -MockWith {
            $testCache
        }
    }

    Context 'When called with ByObject parameter set' {
        It 'Should add the ApiCollection object to the cache' {
            # Arrange
            $apiCollection = New-ApiCollection `
                -CollectionUri 'https://dev.azure.com/myorg/' `
                -ApiVersion '6.0'

            # Act
            Add-ApiCollection -ApiCollection $apiCollection

            # Assert
            $testCache.ContainsKey($apiCollection.CollectionUri) | Should -BeTrue
            $testCache[$apiCollection.CollectionUri] | Should -Be $apiCollection
        }
    }

    Context 'When called with ByParams parameter set' {
        It 'Should create a new ApiCollection object and add it to the cache' {

            # Arrange
            $collectionUri = 'https://dev.azure.com/myorg/'
            $apiVersion = '6.0'

            # Act
            Add-ApiCollection -CollectionUri $collectionUri -ApiVersion $apiVersion

            # Assert
            $testCache.ContainsKey($collectionUri) | Should -BeTrue
            $testCache[$collectionUri].CollectionUri | Should -Be $collectionUri
            $testCache[$collectionUri].ApiVersion | Should -Be $apiVersion
        }
    }

    Context 'When called with invalid parameters' {
        It 'Should throw an error when both ByObject and ByParams parameter sets are used' {
            { Add-ApiCollection `
                -ApiCollection ([PSObject]::new()) `
                -CollectionUri 'https://dev.azure.com/myorg' `
                -ApiVersion '6.0'
            } | Should -Throw
        }
    }
}
