[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', '',
    Justification = 'Test code uses parameter names that trigger the rule but are not actual credentials'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TestSuiteTestCasesList' {

    BeforeEach {
        # Reset retry configuration to ensure consistent test environment
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount            = 3
            RetryDelay            = 1.0
            DisableRetry          = $false
            MaxRetryDelay         = 30.0
            UseExponentialBackoff = $true
            UseJitter             = $true
        }
    }

    BeforeAll {
        $expected = @{
            Connection = New-TestApiProjectConnection
            PlanId     = 79
            SuiteId    = 80
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
    }

    It 'Should return test cases for a test suite' {
        # Arrange
        $testCase1Id = 101
        $testCase2Id = 102

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @(
                @{
                    testCase         = @{
                        id       = $testCase1Id
                        name     = 'Test Case 1'
                        workItem = @{
                            id = $testCase1Id
                        }
                    }
                    pointAssignments = @()
                },
                @{
                    testCase         = @{
                        id       = $testCase2Id
                        name     = 'Test Case 2'
                        workItem = @{
                            id = $testCase2Id
                        }
                    }
                    pointAssignments = @()
                }
            )
        }

        # Act
        $result = Get-TestSuiteTestCasesList `
            -Project 'myproject' `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId

        # Assert
        $result.Count | Should -Be 2
        $result[0].testCase.id | Should -Be $testCase1Id
        $result[0].testCase.name | Should -Be 'Test Case 1'
        $result[1].testCase.id | Should -Be $testCase2Id
        $result[1].testCase.name | Should -Be 'Test Case 2'
    }

    It 'Should accept suite object with plan property' {
        # Arrange
        $suiteObject = [PSCustomObject]@{
            id      = $expected.SuiteId
            name    = 'Test Suite'
            plan    = [PSCustomObject]@{
                id   = $expected.PlanId
                name = 'Test Plan'
            }
            project = [PSCustomObject]@{
                id   = 'project-guid'
                name = 'MyProject'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @{
                testCase = @{
                    id   = 101
                    name = 'Test Case 1'
                }
            }
        }

        # Act
        $result = Get-TestSuiteTestCasesList -Suite $suiteObject

        # Assert
        $result.testCase.id | Should -Be 101
    }

    It 'Should accept suite object from pipeline' {
        # Arrange
        $suiteObject = [PSCustomObject]@{
            id      = $expected.SuiteId
            name    = 'Test Suite'
            plan    = [PSCustomObject]@{
                id   = $expected.PlanId
                name = 'Test Plan'
            }
            project = [PSCustomObject]@{
                id   = 'project-guid'
                name = 'MyProject'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @()
        }

        # Act
        $null = $suiteObject | Get-TestSuiteTestCasesList

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1
    }

    It 'Should throw when plan is not specified' {
        # Act & Assert
        { Get-TestSuiteTestCasesList -Suite 123 } | Should -Throw "*Plan must be specified*"
    }

    It 'Should throw when plan is not a valid object or ID' {
        # Act & Assert
        { Get-TestSuiteTestCasesList -Plan 'invalid' -Suite 123 } | Should -Throw "*Plan must be a test plan object*"
    }

    It 'Should throw when suite is not a valid object or ID' {
        # Act & Assert
        { Get-TestSuiteTestCasesList -Plan 79 -Suite 'invalid' } | Should -Throw "*Suite must be a test suite object*"
    }

    It 'Should return empty array for empty suite' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @()
        }

        # Act
        $result = Get-TestSuiteTestCasesList `
            -Project 'myproject' `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId

        # Assert
        $result.Count | Should -Be 0
    }

    It 'Should handle suite with numeric ID as string' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @()
        }

        # Act
        $null = Get-TestSuiteTestCasesList `
            -Project 'myproject' `
            -Plan "79" `
            -Suite "80"

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1
    }

    It 'Should extract project from plan object' {
        # Arrange
        $planObject = [PSCustomObject]@{
            id      = $expected.PlanId
            name    = 'Test Plan'
            project = [PSCustomObject]@{
                id   = 'project-guid'
                name = 'MyProject'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @()
        }

        # Act
        $null = Get-TestSuiteTestCasesList -Plan $planObject -Suite $expected.SuiteId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project -eq $planObject.project
        }
    }

    It 'Should extract project from suite object' {
        # Arrange
        $project = [PSCustomObject]@{
            id   = 'project-guid'
            name = 'MyProject'
        }
        $suiteObject = [PSCustomObject]@{
            id      = $expected.SuiteId
            name    = 'Test Suite'
            plan    = [PSCustomObject]@{
                id      = $expected.PlanId
                name    = 'Test Plan'
                project = $project
            }
            project = $project
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @()
        }

        # Act
        $null = Get-TestSuiteTestCasesList -Suite $suiteObject

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project -eq $suiteObject.project
        }
    }
}
