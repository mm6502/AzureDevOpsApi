[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Test-TestWorkItem' {

    BeforeAll {
        $testCaseWorkItem = @{
            fields = @{
                'System.WorkItemType' = 'Test Case'
            }
        }

        $requirementWorkItem = @{
            fields = @{
                'System.WorkItemType' = 'Requirement'
                'System.Tags' = 'Test'
            }
        }

        $nonTestWorkItem = @{
            fields = @{
                'System.WorkItemType' = 'Bug'
            }
        }

        $testDisciplineWorkItem = @{
            fields = @{
                'System.WorkItemType' = 'Task'
                'Microsoft.VSTS.Common.Discipline' = 'Test'
            }
        }

        $releaseNotesDataItem = [PSCustomObject]@{
            WorkItem = $testCaseWorkItem
        }
    }

    It 'Should return false for null input' {
        Test-TestWorkItem -WorkItem $null | Should -BeFalse
    }

    It 'Should return true for Test Case work item' {
        Test-TestWorkItem -WorkItem $testCaseWorkItem | Should -BeTrue
    }

    It 'Should return true for Requirement work item with Test tag' {
        Test-TestWorkItem -WorkItem $requirementWorkItem | Should -BeTrue
    }

    It 'Should return false for non-test work item' {
        Test-TestWorkItem -WorkItem $nonTestWorkItem | Should -BeFalse
    }

    It 'Should return true for work item with Test discipline' {
        Test-TestWorkItem -WorkItem $testDisciplineWorkItem | Should -BeTrue
    }

    It 'Should handle ReleaseNotesDataItem input' {
        Test-TestWorkItem -WorkItem $releaseNotesDataItem | Should -BeTrue
    }

    It 'Should return true for Requirement work item with Testing tag' {
        $workItem = @{
            fields = @{
                'System.WorkItemType' = 'Requirement'
                'System.Tags' = 'Feature; Testing'
            }
        }
        Test-TestWorkItem -WorkItem $workItem | Should -BeTrue
    }

    It 'Should return false for Requirement work item without Test or Testing tag' {
        $workItem = @{
            fields = @{
                'System.WorkItemType' = 'Requirement'
                'System.Tags' = 'Feature; Bug'
            }
        }
        Test-TestWorkItem -WorkItem $workItem | Should -BeFalse
    }

    It 'Should be case-insensitive for WorkItemType' {
        $workItem = @{
            fields = @{
                'System.WorkItemType' = 'TEST CASE'
            }
        }
        Test-TestWorkItem -WorkItem $workItem | Should -BeTrue
    }

    It 'Should be case-insensitive for Discipline' {
        $workItem = @{
            fields = @{
                'System.WorkItemType' = 'Task'
                'Microsoft.VSTS.Common.Discipline' = 'TEST'
            }
        }
        Test-TestWorkItem -WorkItem $workItem | Should -BeTrue
    }
}
