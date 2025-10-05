BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'ConvertFrom-TcmWorkItemToTestCase' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Error -MockWith { }
    }

    Context 'Work item conversion' {

        It 'Should convert work item to test case format' {
            # Arrange
            $workItem = @{
                id = 123
                fields = @{
                    'System.Title' = 'Test Case Title'
                    'System.AreaPath' = 'Project\Area'
                    'System.IterationPath' = 'Project\Sprint'
                    'System.State' = 'Design'
                    'Microsoft.VSTS.Common.Priority' = 2
                    'System.AssignedTo' = @{ displayName = 'user@example.com' }
                    'System.Description' = 'Test description'
                    'Microsoft.VSTS.TCM.Steps' = '<steps><step><parameterizedString>Action 1</parameterizedString><parameterizedString>Expected 1</parameterizedString></step></steps>'
                }
            }

            # Act
            $result = ConvertFrom-TcmWorkItemToTestCase -WorkItem $workItem

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.title | Should -Be 'Test Case Title'
            $result.areaPath | Should -Be 'Project\Area'
            $result.state | Should -Be 'Design'
        }

        It 'Should handle missing fields gracefully' {
            # Arrange
            $workItem = @{
                id = 123
                fields = @{
                    'System.Title' = 'Test Case Title'
                }
            }

            # Act
            $result = ConvertFrom-TcmWorkItemToTestCase -WorkItem $workItem

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.title | Should -Be 'Test Case Title'
        }
    }
}