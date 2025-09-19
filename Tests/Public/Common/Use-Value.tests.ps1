BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Use-Value' {

    It 'Should return ValueA when it is not null or empty - <name>' -ForEach @(
        @{ Name = '1'; ValueA = 'Test'; Expected = 'Test'     }
        @{ Name = '2'; ValueA = ''    ; Expected = 'Fallback' }
        @{ Name = '3'; ValueA = 1     ; Expected = 1          }
        @{ Name = '4'; ValueA = 0     ; Expected = 'Fallback' }
        @{ Name = '5'; ValueA = @()   ; Expected = 'Fallback' }
        @{ Name = '6'; ValueA = $null ; Expected = 'Fallback' }
    ) {
        # Act
        $result = Use-Value -ValueA $ValueA -ValueB 'Fallback'
        # Assert
        $result | Should -Be $Expected
    }

    It 'Should return null when both ValueA and ValueB are null' {
        # Act
        $result = Use-Value -ValueA $null -ValueB $null
        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should accept pipeline input' {
        # Act
        $result = $null | Use-Value 'Fallback'
        # Assert
        $result | Should -Be 'Fallback'
    }
}
