[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemRefsListByChangeset' {
    BeforeAll {
        $expected = [PSCustomObject] @{
            Connection = New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            $expected.Connection
        }
    }

    It 'Should call Invoke-Api with correct parameters' {
        # Arrange
        $expectedChangesetId = 123
        $expectedChangeset = [PSCustomObject] @{
            changesetId = $expectedChangeset
            url         = "$($expected.Connection.CollectionUri)/_apis/tfvc/changesets/$($id)"
        }

        Mock -ModuleName $ModuleName -CommandName Get-Changeset -MockWith {
            $expectedChangeset
        }
        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByChangeset_Workitem_Internal -MockWith {
        }

        # Act
        Get-WorkItemRefsListByChangeset `
            -CollectionUri $expected.Connection.CollectionUri `
            -Project $expected.Connection.ProjectId `
            -Changeset $expectedChangesetId

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByChangeset_Workitem_Internal -ParameterFilter {
            $z = $Changeset -eq $expectedChangeset
            $z
        }
    }

    It 'Should return work item references when Invoke-Api returns results' {
        # Arrange
        $expected = [PSCustomObject] @{
            Connection = New-TestApiProjectConnection
            ChangesetIds = @(1, 2)
            WorkItemRefs = @(
                [PSCustomObject] @{ id = 1; url = 'https://example.com/1' }
                [PSCustomObject] @{ id = 2; url = 'https://example.com/2' }
            )
        }

        $expectedChangeset1 = [PSCustomObject] @{
            changesetId = 1
            url         = "$($expected.Connection.CollectionUri)/_apis/tfvc/changesets/1"
        }

        $expectedChangeset2 = [PSCustomObject] @{
            changesetId = 2
            url         = "$($expected.Connection.CollectionUri)/_apis/tfvc/changesets/2"
        }

        Mock -ModuleName $ModuleName -CommandName Get-Changeset -MockWith {
            $expectedChangeset1, $expectedChangeset2
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByChangeset_Workitem_Internal -MockWith {
            $expected.WorkItemRefs
        }

        # Act
        $result = @(
            Get-WorkItemRefsListByChangeset `
                -CollectionUri $expected.Connection.CollectionUri `
                -Changeset $expected.ChangesetIds `
        )

        # Assert
        $result | Should -HaveCount 2
        $result1 = $result | Where-Object { $_.id -eq 1 }
        $result2 = $result | Where-Object { $_.id -eq 2 }
        $result1.id | Should -Be 1
        $result1.url | Should -Be 'https://example.com/1'
        $result2.id | Should -Be 2
        $result2.url | Should -Be 'https://example.com/2'
    }

    It 'Should return an empty array when no work items are found' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith { return @() }

        # Act
        $result = Get-WorkItemRefsListByChangeset `
            -CollectionUri $mockCollectionUri `
            -Changeset $mockChangesetIds

        # Assert
        $result | Should -BeNullOrEmpty
    }
}
