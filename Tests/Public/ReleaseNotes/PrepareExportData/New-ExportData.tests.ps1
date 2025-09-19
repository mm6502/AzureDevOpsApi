BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-ExportData' {
    It 'Should create a new export data object with correct properties' {
        # Act
        $result = New-ExportData

        # Assert
        $result | Should -BeOfType [PSCustomObject]
        $result.PSObject.TypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.ExportData'
        $result.PSObject.Properties.Name | Should -Contain "Release"
        $result.PSObject.Properties.Name | Should -Contain "Console"
        $result.PSObject.Properties.Name | Should -Contain "Relations"
        $result.PSObject.Properties.Name | Should -Contain "WorkItems"
    }

    It 'Should initialize properties with correct default values' {
        # Act
        $result = New-ExportData

        # Assert
        $result.Release | Should -BeNullOrEmpty
        $null -eq $result.Console | Should -Not -Be $true
        $result.Console | Should -HaveCount 0
        $null -eq $result.Relations | Should -Not -Be $true
        $result.Relations | Should -HaveCount 0
        $null -eq $result.WorkItems | Should -Not -Be $true
        $result.WorkItems | Should -HaveCount 0
    }

    It 'Should return a new object on each call' {
        # Act
        $result1 = New-ExportData
        $result2 = New-ExportData

        # Assert
        $result1 | Should -Not -Be $result2
    }

    It 'Should allow adding items to array properties' {
        # Arrange
        $result = New-ExportData

        # Act
        $result.Console += 'Test Console Item'
        $result.Relations += 'Test Relation Item'
        $result.WorkItems += 'Test Work Item'

        # Assert
        $result.Console | Should -Contain 'Test Console Item'
        $result.Relations | Should -Contain 'Test Relation Item'
        $result.WorkItems | Should -Contain 'Test Work Item'
    }

    It 'Should allow setting the Release property' {
        # Arrange
        $result = New-ExportData

        # Act
        $result.Release = 'Test Release'

        # Assert
        $result.Release | Should -Be 'Test Release'
    }
}
