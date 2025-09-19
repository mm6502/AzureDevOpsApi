BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItem' {

    BeforeEach {

        $connection = New-TestApiProjectConnection

        $workItem123 = [PSCustomObject] @{
            id     = 123
            rev    = 4
            url    = Join-Uri -Base $connection.ProjectUri -Relative '_apis/wit/workitems', 123
            fields = [PSCustomObject] @{ 'System.Title' = 'Work Item 123' }
            _links = [PSCUstomObject] @{
                html = [PSCustomObject] @{
                    href = Join-Uri -Base $connection.ProjectUri -Relative '_workitems/edit', 123
                }
            }
        }

        $workItem456 = [PSCustomObject] @{
            id     = 456
            rev    = 7
            url    = Join-Uri -Base $connection.ProjectUri -Relative '_apis/wit/workitems', 456
            fields = [PSCustomObject] @{ 'System.Title' = 'Work Item 456' }
            _links = [PSCUstomObject] @{
                html = [PSCustomObject] @{
                    href = Join-Uri -Base $connection.ProjectUri -Relative '_workitems/edit', 456
                }
            }
        }

        $expected = [PSCustomObject] @{
            WorkItem123 = $workItem123
            WorkItem456 = $workItem456
            WorkItems   = @($workItem123, $workItem456)
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "*/workitems/$($expected.WorkItem123.id)*"
        } -MockWith {
            return $expected.WorkItem123
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "*/workitems/$($expected.WorkItem456.id)*"
        } -MockWith {
            return $expected.WorkItem456
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            throw "Not Expected Call"
        }
    }

    Context 'General' {

        It 'Should use default values when CollectionUri and ApiCredential are not provided' {
            # Act
            $null = Get-WorkItem -WorkItem $expected.WorkItem123.id
            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -ParameterFilter {
                $CollectionUri -eq $null -and $ApiCredential -eq $null
            }
        }

        It 'Should use provided CollectionUri and ApiCredential' {
            # Arrange
            $customUri = 'https://custom.azure.com/org'

            # Act
            $null = Get-WorkItem `
                -WorkItem $expected.WorkItem123.id `
                -CollectionUri $customUri

            # Assert
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -ParameterFilter {
                $CollectionUri -eq $customUri
            }
        }

        It 'Should return a work item when given a valid ID' {
            # Act
            $result = Get-WorkItem -WorkItem $expected.WorkItem123.id

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be $expected.WorkItem123
        }

        It 'Should handle multiple work item IDs as an array' {
            # Arrange
            $workItemIds = $expected.WorkItems.id

            # Act
            $results = Get-WorkItem -WorkItem $workItemIds

            # Assert
            $results.Count | Should -Be 2
            $results[0].id | Should -Be 123
            $results[1].id | Should -Be 456
        }

        It 'Should handle multiple work item IDs as pipeline' {
            # Arrange
            $workItemIds = $expected.WorkItems.id

            # Act
            $results = $workItemIds | Get-WorkItem

            # Assert
            $results.Count | Should -Be 2
            $results[0].id | Should -Be 123
            $results[1].id | Should -Be 456
        }
    }

    Context 'Given a work item ID' {
        It 'Should return the work item' {
            # Act
            $results = Get-WorkItem -WorkItem $expected.WorkItem123.id

            # Assert
            $results | Should -Not -BeNullOrEmpty
            $results | Should -Be $expected.WorkItem123
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Exactly -Times 1 -ParameterFilter {
                $Uri -like "*/workitems/$($expected.WorkItem123.id)*"
            }
        }
    }

    Context 'Given a work item Uri' {
        It 'Should return the work item from Api uri' {
            # Act
            $results = Get-WorkItem -WorkItem $expected.WorkItem123.url

            # Assert
            $results | Should -Not -BeNullOrEmpty
            $results | Should -Be $expected.WorkItem123
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Exactly -Times 1 -ParameterFilter {
                $Uri -like "*/workitems/$($expected.WorkItem123.id)*"
            }
        }

        It 'Should return the work item from Web url' {
            # Act
            $results = Get-WorkItem -WorkItem $expected.WorkItem123._links.html.href

            # Assert
            $results | Should -Not -BeNullOrEmpty
            $results | Should -Be $expected.WorkItem123
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Exactly -Times 1 -ParameterFilter {
                $Uri -like "*/workitems/$($expected.WorkItem123.id)*"
            }
        }
    }

    Context 'Given a work item Object' {
        It 'Should return the same work item' {
            # Act
            $results = @(Get-WorkItem -WorkItem $expected.WorkItem123)

            # Assert
            $results | Should -Not -BeNullOrEmpty
            $results | Should -Be $expected.WorkItem123
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Exactly -Times 0
        }
    }

    Context 'Given a work item Object and AsOf parameter' {
        It 'Should read the work item again' {
            # Arrange
            $date = '2024-05-04'
            $asOf = $date + 'Z'

            # Act
            $results = Get-WorkItem -WorkItem $expected.WorkItem123 -AsOf $asOf

            # Assert
            $results | Should -Not -BeNullOrEmpty
            $results | Should -Be $expected.WorkItem123
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Exactly -Times 1 -ParameterFilter {
                $Uri -like "*/workitems/$($expected.WorkItem123.id)*" -and
                $Uri -like "*asof=$($date)*"
            }
        }
    }

    Context 'Given a work item Ref' {
        It 'Should return the work item' {
            # Arrange
            $ref = [PSCustomObject] @{
                id  = $expected.WorkItem123.id
                url = $expected.WorkItem123.url
            }

            # Act
            $results = Get-WorkItem -WorkItem $ref

            # Assert
            $results | Should -Not -BeNullOrEmpty
            $results | Should -Be $expected.WorkItem123
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Exactly -Times 1 -ParameterFilter {
                $Uri -like "*/workitems/$($expected.WorkItem123.id)*"
            }
        }
    }
}
