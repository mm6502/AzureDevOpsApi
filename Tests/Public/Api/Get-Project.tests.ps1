BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-Project' {

    BeforeAll {
        $expected = @{
            Connection = New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
    }

    It 'Should return project details when given a valid project name' {

        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            return [PSCustomObject]@{
                id   = $expected.Connection.ProjectId
                name = $expected.Connection.ProjectName
                url  = $expected.Connection.ProjectUri
            }
        }

        # Act
        $result = Get-Project `
            -Project $expected.Connection.ProjectName `
            -CollectionUri $expected.Connection.CollectionUri `
            -ApiCredential $expected.Connection.ApiCredential

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.id | Should -Be $expected.Connection.ProjectId
        $result.name | Should -Be $expected.Connection.ProjectName
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "$($expected.Connection.ProjectUri)*"
        }
    }

    It 'Should return project details when given a valid project object' {

        # Arrange
        $inputObject = [PSCustomObject] @{
            url = $expected.Connection.ProjectUri
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            return [PSCustomObject]@{
                id   = $expected.Connection.ProjectId
                name = $expected.Connection.ProjectName
                url  = $expected.Connection.ProjectUri
            }
        }

        # Act
        $result = $inputObject | Get-Project `
            -CollectionUri $expected.CollectionUri `
            -ApiCredential $expected.ApiCredential

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.id | Should -Be $expected.Connection.ProjectId
        $result.name | Should -Be $expected.Connection.ProjectName
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "$($expected.Connection.ProjectUri)*"
        }
    }
}
