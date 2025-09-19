[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)][CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ChangesetsList' {

    BeforeEach {

        $expected = @{
            Connection = New-TestApiProjectConnection
            DateTime   = [datetime]::Parse('2023-05-01T10:00:00Z').ToUniversalTime()
            Changeset1 = $null
        }

        $expected.Changeset1 = [PSCustomObject] @{
            changesetId = 1
            author      = @{displayName = 'Test User' }
            createdDate = $expected.DateTime
            comment     = 'Test changeset'
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            return $expected.Connection
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            $expected.Changeset1
        }
    }

    Context 'Filtering' {
        It 'Applies fromDate filter correctly' {
            # Arrange
            $fromDate = $expected.DateTime.AddDays(1)

            # Act
            $result = Get-ChangesetsList -FromDate $fromDate

            # Assert
            Should -Invoke -ModuleName $ModuleName Invoke-ApiListPaged -ParameterFilter {
                $Uri -like "*fromDate=$($fromDate.ToString('yyyy-MM-dd'))*"
            }
        }

        It 'Applies toDate filter correctly' {
            # Arrange
            $toDate = $expected.DateTime.AddDays(1)

            # Act
            $result = Get-ChangesetsList -ToDate $toDate

            # Assert
            Should -Invoke -ModuleName $ModuleName Invoke-ApiListPaged -ParameterFilter {
                $Uri -like "*toDate=$($toDate.ToString('yyyy-MM-dd'))*"
            }
        }

        It 'Applies author filter correctly' {
            # Act
            $result = Get-ChangesetsList -Author 'testuser'

            # Assert
            Should -Invoke -ModuleName $ModuleName Invoke-ApiListPaged -ParameterFilter {
                $Uri -like "*author=testuser*"
            }
        }
    }

    Context 'Output' {
        It 'Returns correct changeset objects' {
            # Act
            $result = @(Get-ChangesetsList)

            # Assert
            $result.Count | Should -Be 1
            $result[0].changesetId | Should -Be 1
        }
    }
}

