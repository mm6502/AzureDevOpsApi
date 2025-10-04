[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', '',
    Justification = 'Test code uses parameter names that trigger the rule but are not actual credentials'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Add-TestCaseToTestSuite' {

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
            Project    = 'MyProject'
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @(
                [PSCustomObject]@{
                    testCase = [PSCustomObject]@{
                        id   = 101
                        name = 'Test Case 1'
                    }
                }
            )
        }
    }

    It 'Should add single test case to suite' {
        # Arrange
        $testCaseId = 101

        # Act
        $result = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/TestCase*" -and
            $Method -eq 'POST'
        }
        $result.testCase.id | Should -Be $testCaseId
    }

    It 'Should add multiple test cases to suite' {
        # Arrange
        $testCaseIds = @(101, 102, 103)

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return $testCaseIds | ForEach-Object {
                [PSCustomObject]@{
                    testCase = [PSCustomObject]@{
                        id   = $_
                        name = "Test Case $_"
                    }
                }
            }
        }

        # Act
        $result = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseIds

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Body -and $Method -eq 'POST'
        }
        $result.Count | Should -Be 3
        $result[0].testCase.id | Should -Be 101
        $result[1].testCase.id | Should -Be 102
        $result[2].testCase.id | Should -Be 103
    }

    It 'Should accept plan object with id and project properties' {
        # Arrange
        $planObject = [PSCustomObject]@{
            id      = $expected.PlanId
            name    = 'Test Plan'
            project = [PSCustomObject]@{
                id   = 'project-guid'
                name = 'MyProject'
            }
        }
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -Plan $planObject `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project.name -eq 'MyProject'
        }
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/*"
        }
    }

    It 'Should accept suite object with id property' {
        # Arrange
        $suiteObject = [PSCustomObject]@{
            id   = $expected.SuiteId
            name = 'Test Suite'
        }
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $suiteObject `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*Suites/$($expected.SuiteId)/*"
        }
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
        $testCaseId = 101

        # Act
        $null = $suiteObject | Add-TestCaseToTestSuite -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project.name -eq 'MyProject'
        }
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/*"
        }
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
        $testCaseId = 101

        # Act
        $null = $suiteObject | Add-TestCaseToTestSuite -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/*"
        }
    }

    It 'Should extract plan from suite object when plan parameter is not provided' {
        # Arrange
        $suiteObject = [PSCustomObject]@{
            id      = $expected.SuiteId
            name    = 'Test Suite'
            plan    = [PSCustomObject]@{
                id   = $expected.PlanId
                name = 'Test Plan'
            }
        }
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Suite $suiteObject `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/*"
        }
    }

    It 'Should use WorkItemId alias for TestCaseId parameter' {
        # Arrange
        $testCaseId = 101

        # Act
        $result = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -WorkItemId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1
        $result.testCase.id | Should -Be $testCaseId
    }

    It 'Should use WorkItemIds alias for TestCaseId parameter' {
        # Arrange
        $testCaseIds = @(101, 102)

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return $testCaseIds | ForEach-Object {
                [PSCustomObject]@{
                    testCase = [PSCustomObject]@{ id = $_ }
                }
            }
        }

        # Act
        $result = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -WorkItemIds $testCaseIds

        # Assert
        $result.Count | Should -Be 2
    }

    It 'Should throw when plan is not specified and suite has no plan property' {
        # Act & Assert
        { Add-TestCaseToTestSuite -Suite 123 -TestCaseId 101 } |
            Should -Throw "*Plan must be specified*"
    }

    It 'Should throw when plan is not a valid object or ID' {
        # Act & Assert
        { Add-TestCaseToTestSuite -Plan 'invalid' -Suite 123 -TestCaseId 101 } |
            Should -Throw "*Plan must be a test plan object*"
    }

    It 'Should throw when suite is not a valid object or ID' {
        # Act & Assert
        { Add-TestCaseToTestSuite -Plan 79 -Suite 'invalid' -TestCaseId 101 } |
            Should -Throw "*Suite must be a test suite object*"
    }

    It 'Should call Get-ApiProjectConnection with correct parameters' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -CollectionUri 'https://dev.azure.com/contoso' `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $CollectionUri -eq 'https://dev.azure.com/contoso' -and
            $Project -eq $expected.Project
        }
    }

    It 'Should format body correctly with single test case' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Body -and
            ($Body | ConvertFrom-Json)[0].workItem.id -eq $testCaseId
        }
    }

    It 'Should format body correctly with multiple test cases' {
        # Arrange
        $testCaseIds = @(101, 102, 103)

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseIds

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            if (-not $Body) { return $false }
            $bodyArray = $Body | ConvertFrom-Json
            $bodyArray.Count -eq 3 -and
            $bodyArray[0].workItem.id -eq 101 -and
            $bodyArray[1].workItem.id -eq 102 -and
            $bodyArray[2].workItem.id -eq 103
        }
    }

    It 'Should construct correct URI' {
        # Arrange
        $testCaseId = 101
        $expectedUriPattern = "*_apis/testplan/Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/TestCase*"

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like $expectedUriPattern
        }
    }

    It 'Should handle numeric suite and plan IDs' {
        # Arrange
        $planId = 79
        $suiteId = 80
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $planId `
            -Suite $suiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$planId/Suites/$suiteId/*"
        }
    }

    It 'Should accept PlanId alias for Plan parameter' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -PlanId $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1
    }

    It 'Should accept SuiteId alias for Suite parameter' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -SuiteId $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1
    }

    It 'Should accept TestCaseIds alias for TestCaseId parameter' {
        # Arrange
        $testCaseIds = @(101, 102)

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return $testCaseIds | ForEach-Object {
                [PSCustomObject]@{
                    testCase = [PSCustomObject]@{ id = $_ }
                }
            }
        }

        # Act
        $result = Add-TestCaseToTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseIds $testCaseIds

        # Assert
        $result.Count | Should -Be 2
    }
}
