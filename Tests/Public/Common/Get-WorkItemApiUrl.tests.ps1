BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemApiUrl' {
    BeforeAll {
        $expected = [PSCustomObject] @{
            CollectionUri = 'https://dev.azure.com/myorg'
            Project = 'MyProject'
            WorkItem = [PSCustomObject] @{
                id = 123
                url = 'https://dev.azure.com/myorg/MyProject/_apis/wit/workitems/123'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith { $expected.CollectionUri }
        Mock -ModuleName $ModuleName -CommandName Use-Project -MockWith { $expected.Project }
    }

    It 'Should return null when work item is null' {
        # Act
        $result = Get-WorkItemApiUrl -WorkItem $null

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should return url from work item object' {
        # Act
        $result = Get-WorkItemApiUrl -WorkItem $expected.WorkItem

        # Assert
        $result | Should -Be $expected.WorkItem.url
    }

    It 'Should construct url from work item id' {
        # Act
        $result = Get-WorkItemApiUrl -WorkItem 123

        # Assert
        $result | Should -Be "$($expected.CollectionUri)/$($expected.Project)/_apis/wit/workitems/123"
    }

    It 'Should handle pipeline input' {
        # Act
        $result = $expected.WorkItem | Get-WorkItemApiUrl

        # Assert
        $result | Should -Be $expected.WorkItem.url
    }

    It 'Should use provided collection and project' {
        # Arrange
        $customCollection = 'https://custom.azure.com/org'
        $customProject = 'CustomProject'

        # Act
        $null = Get-WorkItemApiUrl -CollectionUri $customCollection -Project $customProject -WorkItem 123

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Use-CollectionUri -ParameterFilter {
            $CollectionUri -eq $customCollection
        }
        Should -Invoke -ModuleName $ModuleName -CommandName Use-Project -ParameterFilter {
            $Project -eq $customProject
        }
    }

    It 'Should handle null pipeline input' {
        # Act
        $result = $null | Get-WorkItemApiUrl

        # Assert
        $result | Should -BeNullOrEmpty
    }
}
