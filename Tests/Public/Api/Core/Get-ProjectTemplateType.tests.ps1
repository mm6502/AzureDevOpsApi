BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ProjectTemplateType' {

    BeforeAll {
        $expected = @{
            Connection     = New-TestApiProjectConnection
            RepositoryId   = 'repo123'
            RepositoryName = 'MyRepository'
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ProjectPropertiesList -MockWith {
            return $expected.ProjectProperties
        }
    }

    It 'Should return the project template type' {
        # Arrange
        $expected = @{
            Connection        = $expected.Connection
            ProjectProperties = @{ value = 'Agile' }
            ProjectType       = 'Agile'
        }

        # Act
        $result = Get-ProjectTemplateType `
            -Project $expected.Connection.ProjectName `
            -CollectionUri $expected.Connection.CollectionUri

        # Assert
        $result | Should -Be $expected.ProjectType
    }

    It 'Should return the project template type from work item types if not found in project properties' {
        # Arrange
        $expected = @{
            Connection        = $expected.Connection
            ProjectProperties = @{ value = $null }
            WorkItemTypes     = @{ referenceName = 'User Story' }
            ProjectType       = 'Agile'
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItemTypesList -MockWith {
            return $expected.WorkItemTypes
        }

        # Act
        $result = Get-ProjectTemplateType `
            -Project $expected.Connection.ProjectName `
            -CollectionUri $expected.Connection.CollectionUri

        # Assert
        $result | Should -Be $expected.ProjectType
    }

    It 'Should return null if project template type is not found' {
        # Arrange
        $expected = @{
            Connection        = $expected.Connection
            ProjectProperties = @{ value = $null }
            WorkItemTypes     = @{ referenceName = 'SomeOtherType' }
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItemTypesList -MockWith {
            return $expected.WorkItemTypes
        }

        # Act
        $result = Get-ProjectTemplateType `
            -Project $expected.Connection.ProjectName `
            -CollectionUri $expected.Connection.CollectionUri `

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should add the project template type property to the input object when piped' {
        # Arrange
        $expected = @{
            Connection        = $expected.Connection
            ProjectProperties = @{ value = 'Agile' }
            ProjectType       = 'Agile'
            InputObject       = [PSCustomObject] @{ Name = 'MyProject' }
        }

        # Act
        $result = $expected.InputObject | Get-ProjectTemplateType

        # Assert
        $result.'System.Process Template' | Should -Be $expected.ProjectType
    }
}
