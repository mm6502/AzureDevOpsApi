BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Use-Project' {
    It 'Should return the provided Project when not null or empty' {
        # Act
        $result = Use-Project -Project 'TestProject'
        # Assert
        $result | Should -Be 'TestProject'
    }

    It 'Should return the global variable when Project is null' {
        # Arrange
        $global:AzureDevOpsApi_Project = 'GlobalProject'
        # Act
        $result = Use-Project -Project $null
        # Assert
        $result | Should -Be 'GlobalProject'
    }

    It 'Should return the global variable when Project is an empty string' {
        # Arrange
        $global:AzureDevOpsApi_Project = 'GlobalProject'
        # Act
        $result = Use-Project -Project ''
        # Assert
        $result | Should -Be 'GlobalProject'
    }
}
