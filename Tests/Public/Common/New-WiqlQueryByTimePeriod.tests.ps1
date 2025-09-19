[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-WiqlQueryByTimePeriod' {

    BeforeAll {
        $DateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.fffZ'
        $DateAttribute = 'ChangedDate'
    }

    It 'Should return a valid WIQL query for a given time period' {
        # Arrange
        $startDate = (Get-Date).AddDays(-7)
        $endDate = (Get-Date)

        # Act
        $result = New-WiqlQueryByTimePeriod -DateFrom $startDate -DateTo $endDate

        # Assert
        $result | Should -BeLike 'SELECT `[System.Id]*'
        $pattern = "*.$($DateAttribute)] >= '$($startDate.ToUniversalTime().ToString($DateTimeFormat))'*"
        $result | Should -BeLike $pattern
        $pattern = "*.$($DateAttribute)] <= '$($endDate.ToUniversalTime().ToString($DateTimeFormat))'*"
        $result | Should -BeLike $pattern
    }

    It 'Should handle null start date' {
        # Arrange
        $endDate = Get-Date
        $global:AzureDevOpsApi_DefaultFromDate = $null

        # Act
        $result = New-WiqlQueryByTimePeriod -DateTo $endDate

        # Assert
        $result | Should -BeLike 'SELECT `[System.Id]*'
        $pattern = "*.$($DateAttribute)] <= '$($endDate.ToUniversalTime().ToString($DateTimeFormat))'*"
        $result | Should -BeLike $pattern
        $result | Should -Not -BeLike "*.$($DateAttribute)] >=*"
    }

    It 'Should handle default end date to current date' {
        # Arrange
        $startDate = (Get-Date).AddDays(-7)

        # Act
        $result = New-WiqlQueryByTimePeriod -DateFrom $startDate

        # Assert
        $result | Should -BeLike 'SELECT `[System.Id]*'
        $pattern = "*.$($DateAttribute)] >= '$($startDate.ToUniversalTime().ToString($DateTimeFormat))'*"
        $result | Should -BeLike $pattern
        $result | Should -BeLike "*.$($DateAttribute)] <=*"
    }

    It 'Should handle both start and end dates as null' {
        # Arrange
        $global:AzureDevOpsApi_DefaultFromDate = Get-Date

        # Act
        $result = New-WiqlQueryByTimePeriod

        # Assert
        $result | Should -BeLike 'SELECT `[System.Id]*'
        $result | Should -BeLike "*.$($DateAttribute)] >=*"
        $result | Should -BeLike "*.$($DateAttribute)] <=*"
    }
}
