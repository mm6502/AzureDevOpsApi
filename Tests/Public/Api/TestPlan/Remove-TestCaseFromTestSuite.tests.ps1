[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', '',
    Justification = 'Test code uses parameter names that trigger the rule but are not actual credentials'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Remove-TestCaseFromTestSuite' {

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

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            # DELETE returns no content on success
            return $null
        }
    }

    It 'Should remove single test case from suite' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/TestCase*testCaseIds=$testCaseId*" -and
            $Method -eq 'DELETE'
        }
    }

    It 'Should remove multiple test cases from suite' {
        # Arrange
        $testCaseIds = @(101, 102, 103)

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseIds

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            ($Uri -like "*testCaseIds=101,102,103*" -or $Uri -like "*testCaseIds=101%2C102%2C103*") -and
            $Method -eq 'DELETE'
        }
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
        $null = Remove-TestCaseFromTestSuite `
            -Plan $planObject `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project.name -eq 'MyProject'
        }
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
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
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $suiteObject `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
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
        $null = $suiteObject | Remove-TestCaseFromTestSuite -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project.name -eq 'MyProject'
        }
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
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
        $null = $suiteObject | Remove-TestCaseFromTestSuite -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
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
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Suite $suiteObject `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/*"
        }
    }

    It 'Should use WorkItemId alias for TestCaseId parameter' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -WorkItemId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1
    }

    It 'Should use WorkItemIds alias for TestCaseId parameter' {
        # Arrange
        $testCaseIds = @(101, 102)

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -WorkItemIds $testCaseIds

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*testCaseIds=101,102*" -or $Uri -like "*testCaseIds=101%2C102*"
        }
    }

    It 'Should throw when plan is not specified and suite has no plan property' {
        # Act & Assert
        { Remove-TestCaseFromTestSuite -Suite 123 -TestCaseId 101 } |
            Should -Throw "*Plan must be specified*"
    }

    It 'Should throw when plan is not a valid object or ID' {
        # Act & Assert
        { Remove-TestCaseFromTestSuite -Plan 'invalid' -Suite 123 -TestCaseId 101 } |
            Should -Throw "*Plan must be a test plan object*"
    }

    It 'Should throw when suite is not a valid object or ID' {
        # Act & Assert
        { Remove-TestCaseFromTestSuite -Plan 79 -Suite 'invalid' -TestCaseId 101 } |
            Should -Throw "*Suite must be a test suite object*"
    }

    It 'Should call Get-ApiProjectConnection with correct parameters' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
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

    It 'Should construct correct URI with single test case' {
        # Arrange
        $testCaseId = 101
        $expectedUriPattern = "*_apis/testplan/Plans/$($expected.PlanId)/Suites/$($expected.SuiteId)/TestCase*testCaseIds=$testCaseId*"

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like $expectedUriPattern
        }
    }

    It 'Should construct correct URI with multiple test cases' {
        # Arrange
        $testCaseIds = @(101, 102, 103)

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseIds

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*testCaseIds=101,102,103*" -or $Uri -like "*testCaseIds=101%2C102%2C103*"
        }
    }

    It 'Should handle numeric suite and plan IDs' {
        # Arrange
        $planId = 79
        $suiteId = 80
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $planId `
            -Suite $suiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$planId/Suites/$suiteId/*"
        }
    }

    It 'Should accept PlanId alias for Plan parameter' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -PlanId $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1
    }

    It 'Should accept Id alias for Plan parameter' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Id $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1
    }

    It 'Should accept SuiteId alias for Suite parameter' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -SuiteId $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1
    }

    It 'Should accept TestCaseIds alias for TestCaseId parameter' {
        # Arrange
        $testCaseIds = @(101, 102)

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseIds $testCaseIds

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1
    }

    It 'Should use DELETE HTTP method' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Method -eq 'DELETE'
        }
    }

    It 'Should use API version 7.0' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $ApiVersion -eq '7.0'
        }
    }

    It 'Should pass API credential from connection' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $null -ne $ApiCredential
        }
    }

    It 'Should construct URI without trailing slash' {
        # Arrange
        $testCaseId = 101

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -notmatch '\?/$'
        }
    }

    It 'Should handle pipeline input with plan object directly as parameter' {
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

        # Act - Pass plan object as parameter (not pipeline), since pipeline input only accepts suite objects
        $null = Remove-TestCaseFromTestSuite -Plan $planObject -Suite $expected.SuiteId -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*Plans/$($expected.PlanId)/*"
        }
    }

    It 'Should handle pipeline input with suite object without plan property' {
        # Arrange
        $suiteObject = [PSCustomObject]@{
            id   = $expected.SuiteId
            name = 'Test Suite'
        }
        $testCaseId = 101

        # Act & Assert
        { $suiteObject | Remove-TestCaseFromTestSuite -TestCaseId $testCaseId } |
            Should -Throw "*Plan must be specified*"
    }

    It 'Should correctly join test case IDs with comma separator' {
        # Arrange
        $testCaseIds = @(101, 102, 103, 104, 105)

        # Act
        $null = Remove-TestCaseFromTestSuite `
            -Project $expected.Project `
            -Plan $expected.PlanId `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseIds

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            $Uri -like "*testCaseIds=101,102,103,104,105*" -or $Uri -like "*testCaseIds=101%2C102%2C103%2C104%2C105*"
        }
    }

    It 'Should extract project from plan object if Project parameter is not provided' {
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
        $null = Remove-TestCaseFromTestSuite `
            -Plan $planObject `
            -Suite $expected.SuiteId `
            -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project.name -eq 'MyProject'
        }
    }

    It 'Should extract project from suite object if Project parameter is not provided via pipeline' {
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

        # Act - Use pipeline to pass suite object, which extracts project
        $null = $suiteObject | Remove-TestCaseFromTestSuite -TestCaseId $testCaseId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 1 -ParameterFilter {
            $Project.name -eq 'MyProject'
        }
    }
}
