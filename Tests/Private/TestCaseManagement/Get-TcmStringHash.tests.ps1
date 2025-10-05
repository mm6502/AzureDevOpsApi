BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'Get-TcmStringHash' {

    Context 'Hash calculation' {

        It 'Should return consistent hash for same input' {
            # Arrange
            $inputObject = @{
                title = "Test Case"
                steps = @(
                    @{ stepNumber = 1; action = "Do something" },
                    @{ stepNumber = 2; action = "Do something else" }
                )
            }

            # Act
            $hash1 = Get-TcmStringHash -InputObject $inputObject
            $hash2 = Get-TcmStringHash -InputObject $inputObject

            # Assert
            $hash1 | Should -Not -BeNullOrEmpty
            $hash2 | Should -Not -BeNullOrEmpty
            $hash1 | Should -Be $hash2
        }

        It 'Should return different hash for different input' {
            # Arrange
            $input1 = @{ title = "Test Case 1" }
            $input2 = @{ title = "Test Case 2" }

            # Act
            $hash1 = Get-TcmStringHash -InputObject $input1
            $hash2 = Get-TcmStringHash -InputObject $input2

            # Assert
            $hash1 | Should -Not -Be $hash2
        }

        It 'Should normalize object properties for consistent hashing' {
            # Arrange
            $input1 = @{ z = "last"; a = "first" }
            $input2 = @{ a = "first"; z = "last" }

            # Act
            $hash1 = Get-TcmStringHash -InputObject $input1
            $hash2 = Get-TcmStringHash -InputObject $input2

            # Assert
            $hash1 | Should -Be $hash2
        }

        It 'Should handle string input' {
            # Arrange
            $inputString = "test string"

            # Act
            $hash = Get-TcmStringHash -InputString $inputString

            # Assert
            $hash | Should -Not -BeNullOrEmpty
            $hash | Should -BeOfType [string]
        }

        It 'Should sort arrays for consistent hashing' {
            # Arrange
            $input1 = @{ items = @("c", "a", "b") }
            $input2 = @{ items = @("a", "b", "c") }

            # Act
            $hash1 = Get-TcmStringHash -InputObject $input1
            $hash2 = Get-TcmStringHash -InputObject $input2

            # Assert
            $hash1 | Should -Be $hash2
        }
    }
}