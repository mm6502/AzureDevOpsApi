BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-JsonCustom' {

    It 'Should convert a single object to JSON' {
        # arrange
        $obj = [PSCustomObject]@{
            Name = 'John'
            Age  = 30
        }

        # act
        $json = ConvertTo-JsonCustom -Value $obj

        # assert
        $json | Should -BeOfType [string]
        $json | Should -Match '"Name"\s*:\s*"John"'
        $json | Should -Match '"Age"\s*:\s*30'
    }

    It 'Should convert an array of objects to JSON' {
        # arrange
        $objs = @(
            [PSCustomObject]@{
                Name = 'John'
                Age  = 30
            },
            [PSCustomObject]@{
                Name = 'Jane'
                Age  = 25
            }
        )

        # act
        $json = ConvertTo-JsonCustom -Value $objs -AsArray

        # assert
        $json | Should -BeOfType [string]
        $json | Should -Match '^\['
        $json | Should -Match ']$'
        $json | Should -Match '"Name"\s*:\s*"John"\s*,\s*"Age"\s*:\s*30'
        $json | Should -Match '"Name"\s*:\s*"Jane"\s*,\s*"Age"\s*:\s*25'
    }

    It 'Should handle null values' {
        # arrange
        $obj = [PSCustomObject]@{
            Name = $null
            Age  = 30
        }

        # act
        $json = ConvertTo-JsonCustom -Value $obj

        # assert
        $json | Should -BeOfType [string]
        $json | Should -Match '"Name"\s*:\s*null'
    }

    It 'Should handle empty strings' {
        # arrange
        $obj = [PSCustomObject]@{
            Name = ''
            Age  = 30
        }

        # act
        $json = ConvertTo-JsonCustom -Value $obj

        # assert
        $json | Should -BeOfType [string]
        $json | Should -Match '"Name"\s*:\s*""'
        $json | Should -Match '"Age"\s*:\s*30'
    }

    It 'Should respect the Depth parameter' {
        # arrange
        $obj = @{
            Name   = 'John'
            Age    = 30
            Nested = @{
                Prop1 = 'Value1'
                Prop2 = @{
                    Prop3 = 'Value3'
                }
            }
        }

        # act
        $json = ConvertTo-JsonCustom -Value $obj -Depth 1 -WarningAction SilentlyContinue

        # assert
        $json | Should -BeOfType [string]
        $json | Should -Match '"Name"\s*:\s*"John"'
        $json | Should -Match '"Age"\s*:\s*30'
        $json | Should -Match '"Prop2"\s*:\s*"System.Collections.Hashtable"\s*'
    }
}
