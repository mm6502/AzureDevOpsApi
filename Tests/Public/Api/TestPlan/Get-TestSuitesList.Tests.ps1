[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', '',
    Justification = 'Test code uses parameter names that trigger the rule but are not actual credentials'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TestSuitesList' {

    BeforeEach {
        # Reset retry configuration to ensure consistent test environment
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount             = 3
            RetryDelay             = 1.0
            DisableRetry           = $false
            MaxRetryDelay          = 30.0
            UseExponentialBackoff  = $true
            UseJitter              = $true
        }
    }

    BeforeAll {
        $expected = @{
            Connection = New-TestApiProjectConnection
            PlanId     = 79
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
    }

    It 'Should return test suites for a test plan' {
        # Arrange
        $expected = @{
            Connection  = $expected.Connection
            PlanId      = $expected.PlanId
            Suite1Id    = 80
            Suite1Name  = 'Root Suite'
            Suite2Id    = 81
            Suite2Name  = 'Static Suite 1'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith {
            return @(
                @{
                    id        = $expected.Suite1Id
                    name      = $expected.Suite1Name
                    suiteType = 'staticTestSuite'
                    revision  = 1
                },
                @{
                    id        = $expected.Suite2Id
                    name      = $expected.Suite2Name
                    suiteType = 'staticTestSuite'
                    revision  = 1
                }
            )
        }

        # Act
        $result = Get-TestSuitesList -Project 'myproject' -Plan $expected.PlanId

        # Assert
        $result.Count | Should -Be 2
        $result[0].id | Should -Be $expected.Suite1Id
        $result[0].name | Should -Be $expected.Suite1Name
        $result[1].id | Should -Be $expected.Suite2Id
        $result[1].name | Should -Be $expected.Suite2Name
    }

    It 'Should accept plan object with id property' {
        # Arrange
        $planObject = [PSCustomObject]@{
            id      = $expected.PlanId
            name    = 'Test Plan'
            project = [PSCustomObject]@{
                id   = 'project-guid'
                name = 'MyProject'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith {
            return @{
                id        = 80
                name      = 'Suite 1'
                suiteType = 'staticTestSuite'
            }
        }

        # Act
        $result = Get-TestSuitesList -Plan $planObject

        # Assert
        $result.id | Should -Be 80
    }

    It 'Should extract project from plan object' {
        # Arrange
        $planObject = [PSCustomObject]@{
            id      = $expected.PlanId
            project = [PSCustomObject]@{
                name = 'ExtractedProject'
            }
        }

        $capturedProject = $null
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            param($CollectionUri, $Project)
            $script:capturedProject = $Project
            return $expected.Connection
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith { }

        # Act
        Get-TestSuitesList -Plan $planObject

        # Assert
        $script:capturedProject | Should -Be $planObject.project
    }

    It 'Should accept plan object from pipeline' {
        # Arrange
        $planObject = [PSCustomObject]@{
            id      = $expected.PlanId
            name    = 'Test Plan'
            project = 'MyProject'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith {
            return @{
                id   = 80
                name = 'Suite 1'
            }
        }

        # Act
        $result = $planObject | Get-TestSuitesList

        # Assert
        $result.id | Should -Be 80
    }

    It 'Should require Plan parameter' {
        # Arrange
        $command = Get-Command -Name Get-TestSuitesList -Module $ModuleName

        # Act
        $mandatoryParams = $command.Parameters['Plan'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }

        # Assert
        $mandatoryParams | Should -Not -BeNullOrEmpty
    }

    It 'Should handle null or empty Project' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith { }

        # Act & Assert
        { Get-TestSuitesList -Project $null -Plan $expected.PlanId } | Should -Not -Throw
        { Get-TestSuitesList -Project '' -Plan $expected.PlanId } | Should -Not -Throw
    }

    It 'Should handle custom CollectionUri' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith { }

        # Act & Assert
        { Get-TestSuitesList `
                -Project 'myproject' `
                -Plan $expected.PlanId `
                -CollectionUri 'https://dev.azure.com/myorg/'
        } | Should -Not -Throw
    }

    It 'Should pass Expand parameter to query string' {
        # Arrange
        $expectedExpand = 'Children'
        Mock -ModuleName $ModuleName -CommandName Add-QueryParameter -MockWith {
            param($Uri, $Parameters)
            $Parameters['expand'] | Should -Be $expectedExpand
            return $Uri
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith { }

        # Act
        Get-TestSuitesList -Project 'myproject' -Plan $expected.PlanId -Expand $expectedExpand

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Add-QueryParameter -Times 1
    }

    It 'Should pass AsTreeView parameter to query string' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Add-QueryParameter -MockWith {
            param($Uri, $Parameters)
            $Parameters['asTreeView'] | Should -Be $true
            return $Uri
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith { }

        # Act
        Get-TestSuitesList -Project 'myproject' -Plan $expected.PlanId -AsTreeView

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Add-QueryParameter -Times 1
    }

    It 'Should validate Expand parameter values' {
        # Act & Assert
        { Get-TestSuitesList -Project 'myproject' -Plan $expected.PlanId -Expand 'InvalidValue' } | Should -Throw
    }

    It 'Should construct correct URI with Plan ID' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith {
            param($Uri, $ApiCredential, $ApiVersion)
            # Verify the URI contains the PlanId
            $Uri | Should -Match "_apis/testplan/Plans/$($expected.PlanId)/suites"
        }

        # Act
        Get-TestSuitesList -Project 'myproject' -Plan $expected.PlanId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -Times 1
    }

    It 'Should return suites with plan property' {
        # Arrange
        $testPlanId = 123
        $testPlanName = 'Test Plan'

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPagedWithContinuationToken -MockWith {
            return @(
                [PSCustomObject]@{
                    id        = 1
                    name      = 'Suite 1'
                    suiteType = 'staticTestSuite'
                    plan      = @{
                        id   = $testPlanId
                        name = $testPlanName
                    }
                },
                [PSCustomObject]@{
                    id        = 2
                    name      = 'Suite 2'
                    suiteType = 'staticTestSuite'
                    plan      = @{
                        id   = $testPlanId
                        name = $testPlanName
                    }
                }
            )
        }

        # Act
        $result = Get-TestSuitesList -Project 'myproject' -Plan $testPlanId

        # Assert
        $result | Should -HaveCount 2
        $result | ForEach-Object {
            $_.plan.id | Should -Be $testPlanId
            $_.PSObject.Properties.Name | Should -Contain 'plan'
        }
    }
}
