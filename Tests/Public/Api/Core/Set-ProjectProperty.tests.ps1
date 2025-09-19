BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe "Set-ProjectProperty" {

    BeforeAll {
        # Mock dependencies
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionConnection -MockWith {
            return New-TestApiCollectionConnection
        }

        Mock -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -MockWith {
            return ConvertTo-JsonCustom @PSBoundParameters
        }

        Mock -ModuleName $ModuleName -CommandName Join-Uri -MockWith {
            return "https://dev.azure.com/org/project/properties"
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            return @{
                Status = "Success"
            }
        }
    }

    Context "Parameter validation" {
        It "Should accept a project name" {
            # Act
            Set-ProjectProperty -Project "TestProject" -Property @{ Key = "Value" }

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
                 $Project -eq "TestProject"
            }
        }

        It "Should accept empty properties" {
            # Act & Assert
            { Set-ProjectProperty -Project "TestProject" -Property @{} } | Should -Not -Throw
        }
    }

    Context "Property handling" {
        It "Should create 'add' operations for non-null values" {
            # Arrange
            $properties = @{ TestKey = "TestValue" }

            # Act
            Set-ProjectProperty -Project "TestProject" -Property $properties

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -Times 1 -ParameterFilter {
                $a = $Value -is [System.Collections.IEnumerable]
                $b = $Value[0].op -eq "add"
                $c = $Value[0].path -eq "/TestKey"
                $d = $Value[0].value -eq "TestValue"
                return $a -and $b -and $c -and $d
            }
        }

        It "Should create 'remove' operations for null values" {
            # Arrange
            $properties = @{ TestKey = $null }

            # Act
            Set-ProjectProperty -Project "TestProject" -Property $properties

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -Times 1 -ParameterFilter {
                $a = $Value -is [System.Collections.IEnumerable]
                $b = $Value[0].op -eq "remove"
                $c = $Value[0].path -eq "/TestKey"
                $d = (-not $Value[0].ContainsKey("value"))
                return $a -and $b -and $c -and $d
            }
        }

        It "Should handle multiple properties" {
            # Arrange
            $properties = @{
                Key1 = "Value1"
                Key2 = $null
                Key3 = "Value3"
            }

            # Act
            Set-ProjectProperty -Project "TestProject" -Property $properties

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-JsonCustom -Times 1 -ParameterFilter {
                $a = $Value -is [System.Collections.IEnumerable]
                $b = $Value.Count -eq 3
                return $a -and $b
            }
        }
    }

    Context "API interaction" {
        It "Should append preview suffix to API version if not present" {
            # Act
            Set-ProjectProperty -Project "TestProject" -Property @{ Key = "Value" }

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
                $ApiVersion -like "*-preview*"
            }
        }

        It "Should use PATCH method for API call" {
            # Act
            Set-ProjectProperty -Project "TestProject" -Property @{ Key = "Value" }

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
                $Method -eq "PATCH"
            }
        }

        It "Should use correct content type for JSON patch" {
            # Act
            Set-ProjectProperty -Project "TestProject" -Property @{ Key = "Value" }

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
                $ContentType -eq "application/json-patch+json"
            }
        }
    }

    Context "Edge cases" {
        It "Should handle null Project parameter" {
            # Act
            { Set-ProjectProperty -Project $null -Property @{ Key = "Value" } } | Should -Not -Throw

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
                 $null -eq $Project
            }
        }

        It "Should handle empty string Project parameter" {
            # Act
            { Set-ProjectProperty -Project "" -Property @{ Key = "Value" } } | Should -Not -Throw

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
                $Project -eq ""
            }
        }

        It "Should handle null Property parameter" {
            # Act & Assert
            { Set-ProjectProperty -Project "TestProject" -Property $null } | Should -Not -Throw
        }
    }
}