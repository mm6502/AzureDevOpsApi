[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemRefsListByTimePeriod' {

    BeforeAll {
        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
    }

    BeforeEach {

        $testConnection = New-TestApiProjectConnection

        $testParams = [PSCustomObject] @{
            Project       = $testConnection.Project
            CollectionUri = $testConnection.CollectionUri
            ApiCredential = $testConnection.ApiCredential
            DateFrom = (Get-Date).AddDays(-7)
            DateTo = Get-Date
            WorkItemTypes = @('Bug', 'Task')
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $testConnection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-WorkItemsQuery -MockWith {
            return [PSCustomObject] @{
                workItems = @(
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/1' },
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/2' },
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/3' }
                )
            }
        }
    }

    It 'Should call Invoke-WorkItemsQuery with correct parameters' {
        # Arrange
        $expectedQuery = 'Mocked WIQL Query'

        Mock -ModuleName $ModuleName -CommandName New-WiqlQueryByTimePeriod -MockWith {
            return $expectedQuery
        }

        # Act
        $result = Get-WorkItemRefsListByTimePeriod @testParams

        # Assert
        $result.Count | Should -Not -Be $null
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WorkItemsQuery -ParameterFilter {
            $CollectionUri -eq $testParams.CollectionUri -and
            $Query -eq $expectedQuery
        }
    }

    It 'Should use default values when optional parameters are not provided' {
        # Arrange
        $minimalParams = @{
            Project = 'TestProject'
            DateFrom = (Get-Date).AddDays(-7)
        }

        # Act
        Get-WorkItemRefsListByTimePeriod @minimalParams

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WorkItemsQuery -ParameterFilter {
            $Query -like '*Requirement*' -and
            $Query -like '*Bug*' -and
            $Query -like '*Task*'
        }
    }

    It 'Should return unique work item references' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-WorkItemsQuery -MockWith {
            return [PSCustomObject] @{
                workItems = @(
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/1' }
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/1' }
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/2' }
                )
            }
        }

        # Act
        $result = Get-WorkItemRefsListByTimePeriod @testParams

        # Assert
        $result.Count | Should -Be 2
        $result[0].url | Should -Be 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/1'
        $result[1].url | Should -Be 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/2'
    }

    It 'Should handle null or empty work item URLs' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-WorkItemsQuery -MockWith {
            return [PSCustomObject] @{
                workItems = @(
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/1' }
                    [PSCustomObject] @{ url = $null }
                    [PSCustomObject] @{ url = '' }
                    [PSCustomObject] @{ url = 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/2' }
                )
            }
        }

        # Act
        $result = Get-WorkItemRefsListByTimePeriod @testParams

        # Assert
        $result.Count | Should -Be 2
        $result[0].url | Should -Be 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/1'
        $result[1].url | Should -Be 'https://dev.azure.com/testorg/TestProject/_apis/wit/workitems/2'
    }
}
