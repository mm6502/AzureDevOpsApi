BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ApiProjectConnection' {

    BeforeEach {
        $testApiCollectionsCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionsCache -MockWith {
            $testApiCollectionsCache
        }

        $testApiCredentialsCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiCredentialsCache -MockWith {
            $testApiCredentialsCache
        }

        $testApiProjectsCache = @{ }
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectsCache -MockWith {
            $testApiProjectsCache
        }
    }

    It 'Should use global variables when parameters are not provided' {
        # Arrange
        $expected = [PSCustomObject] @{
            CollectionUri           = 'https://dev.azure.com/myorg/'
            ApiVersion              = '6.0'
            ApiCredential           = New-ApiCredential
            ProjectName             = 'myproject'
            ProjectUri              = 'https://dev.azure.com/myorg/myproject'
            ApiCollectionConnection = $null
            ApiProjectConnection    = $null
        }

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            $expected.CollectionUri
        }

        Mock -ModuleName $ModuleName -CommandName Use-ApiCredential -MockWith {
            $expected.ApiCredential
        }

        Mock -ModuleName $ModuleName -CommandName Use-Project -MockWith {
            $expected.ProjectName
        }

        Mock -ModuleName $ModuleName -CommandName Use-ApiVersion -MockWith {
            $expected.ApiVersion
        }

        # Get-Project will be called, if project was not found in cache
        Mock -ModuleName $ModuleName -CommandName Get-Project -MockWith {
            return [PSCustomObject] @{
                id  = $expected.ProjectId
                url = $expected.ProjectUri
            }
        }

        # Regular Get-Project function will add the project to the cache.
        # This is the call after the Get-Project mock.
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.ApiProjectConnection
        } -ParameterFilter {
            $Project -eq $expected.ProjectUri
        }

        $expected.ApiCollectionConnection = New-ApiCollectionConnection `
            -CollectionUri $expected.CollectionUri `
            -ApiVersion    $expected.ApiVersion `
            -ApiCredential $expected.ApiCredential

        $expected.ApiProjectConnection = New-ApiProjectConnection `
            -ApiCollectionConnection $expected.ApiCollectionConnection `
            -ProjectName $expected.ProjectName `
            -ProjectId $expected.ProjectId `
            -ProjectUri $expected.ProjectUri

        # Act
        $result = Get-ApiProjectConnection

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.CollectionUri | Should -Be $expected.CollectionUri
        $result.ApiVersion | Should -Be $expected.ApiVersion
        $result.ApiCredential.Authorization | Should -Be $expected.ApiCredential.Authorization
        $result.ProjectName | Should -Be $expected.ProjectName

        Should -Invoke -ModuleName $ModuleName -CommandName Get-Project -Exactly -Times 1 -ParameterFilter {
            $null -ne $ApiProjectConnection
        }
    }

    It 'Should create a new API project connection with valid parameters' {
        # Arrange
        $expected = @{
            CollectionUri           = 'https://dev.azure.com/myorg/'
            ApiVersion              = '6.0'
            ApiCredential           = New-ApiCredential
            ProjectName             = 'myproject2'
            ProjectId               = '12345678-1234-5678-1234-567812345678'
            ProjectUri              = 'https://dev.azure.com/myorg/_apis/projects/12345678-1234-5678-1234-567812345678'
            ApiCollectionConnection = $null
            ApiProjectConnection    = $null
        }

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            $expected.CollectionUri
        }

        Mock -ModuleName $ModuleName -CommandName Use-ApiCredential -MockWith {
            $expected.ApiCredential
        }

        Mock -ModuleName $ModuleName -CommandName Use-Project -MockWith {
            $expected.ProjectName
        }

        Mock -ModuleName $ModuleName -CommandName Use-ApiVersion -MockWith {
            $expected.ApiVersion
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            [PSCustomObject] @{
                id   = $expected.ProjectId
                name = $expected.ProjectName
                url  = $expected.ProjectUri
            }
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.ApiProjectConnection
        } -ParameterFilter {
            $Project -match "http[s]?://.*"
        }

        $expected.ApiCollectionConnection = New-ApiCollectionConnection `
            -CollectionUri $expected.CollectionUri `
            -ApiVersion    $expected.ApiVersion `
            -ApiCredential $expected.ApiCredential

        $expected.ApiProjectConnection = New-ApiProjectConnection `
            -ApiCollectionConnection $expected.ApiCollectionConnection `
            -ProjectName $expected.ProjectName `
            -ProjectId $expected.ProjectId `
            -ProjectUri $expected.ProjectUri

        # Act
        $result = Get-ApiProjectConnection `
            -CollectionUri $expected.CollectionUri `
            -ApiCredential $expected.ApiCredential `
            -Project $expected.ProjectName

        # Assert
        $result | Should -BeOfType PSCustomObject
        $result.CollectionUri | Should -Be $expected.CollectionUri
        $result.ApiVersion | Should -Be $expected.ApiVersion
        $result.ApiCredential | Should -Be $expected.ApiCredential
        $result.ProjectName | Should -Be $expected.ProjectName
        $result.ProjectId | Should -Be $expected.ProjectId
    }

    It 'Should throw an error when required parameters are missing' {
        # Arrange
        $expected = @{
            CollectionUri = 'https://dev.azure.com/myorg/'
            ApiCredential = New-ApiCredential
        }

        Mock -ModuleName $ModuleName -CommandName Use-Project -MockWith {
            $null
        }

        # Act & Assert
        { Get-ApiProjectConnection `
                -CollectionUri $expected.CollectionUri `
                -ApiCredential $expected.ApiCredential
        } | Should -Throw
    }
}
