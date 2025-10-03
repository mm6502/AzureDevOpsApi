[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', '',
    Justification = 'Test code uses parameter names that trigger the rule but are not actual credentials'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TestPlansList' {

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
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }
    }

    It 'Should return test plans for a project' {
        # Arrange
        $expected = @{
            Connection = $expected.Connection
            Plan1Id    = 11
            Plan1Name  = 'Test Plan 1'
            Plan2Id    = 19
            Plan2Name  = 'Test Plan 2'
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            return @(
                @{
                    id       = $expected.Plan1Id
                    name     = $expected.Plan1Name
                    state    = 'Active'
                    revision = 1
                },
                @{
                    id       = $expected.Plan2Id
                    name     = $expected.Plan2Name
                    state    = 'Active'
                    revision = 1
                }
            )
        }

        # Act
        $result = Get-TestPlansList -Project 'myproject'

        # Assert
        $result.Count | Should -Be 2
        $result[0].id | Should -Be $expected.Plan1Id
        $result[0].name | Should -Be $expected.Plan1Name
        $result[1].id | Should -Be $expected.Plan2Id
        $result[1].name | Should -Be $expected.Plan2Name
    }

    It 'Should handle null or empty Project' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { }

        # Act & Assert
        { Get-TestPlansList -Project $null } | Should -Not -Throw
        { Get-TestPlansList -Project '' } | Should -Not -Throw
    }

    It 'Should handle custom CollectionUri' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { }

        # Act & Assert
        { Get-TestPlansList `
                -Project 'myproject' `
                -CollectionUri 'https://dev.azure.com/myorg/'
        } | Should -Not -Throw
    }

    It 'Should pass Owner parameter to query string' {
        # Arrange
        $expectedOwner = 'owner@example.com'
        Mock -ModuleName $ModuleName -CommandName Add-QueryParameter -MockWith {
            param($Uri, $Parameters)
            $Parameters['owner'] | Should -Be $expectedOwner
            return $Uri
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { }

        # Act
        Get-TestPlansList -Project 'myproject' -Owner $expectedOwner

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Add-QueryParameter -Times 1
    }

    It 'Should pass FilterActivePlans parameter to query string' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Add-QueryParameter -MockWith {
            param($Uri, $Parameters)
            $Parameters['filterActivePlans'] | Should -Be $true
            return $Uri
        }
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith { }

        # Act
        Get-TestPlansList -Project 'myproject' -FilterActivePlans

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Add-QueryParameter -Times 1
    }

    It 'Should pass Top and Skip parameters' {
        # Arrange
        $expectedTop = 50
        $expectedSkip = 100
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            param($Uri, $ApiCredential, $ApiVersion, $Top, $Skip, $AsHashTable)
            $Top | Should -Be $expectedTop
            $Skip | Should -Be $expectedSkip
        }

        # Act
        Get-TestPlansList -Project 'myproject' -Top $expectedTop -Skip $expectedSkip

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1
    }
}
