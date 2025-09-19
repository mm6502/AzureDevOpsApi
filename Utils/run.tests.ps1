#requires -version 5
#requires -modules 'Pester'

<#
    .SYNOPSIS
        Runs unit tests with and code coverage

    .PARAMETER SkipCodeCoverage
        If $true, skips the code coverage of tests executed.

    .PARAMETER Detailed
        If $true, shows the detailed output of the tests.

    .PARAMETER KeepResults
        If $true, keeps the file with results of the code coverage.
#>

[CmdletBinding()]
param(
    [switch] $SkipCodeCoverage,
    [switch] $Detailed,
    [switch] $KeepResults
)

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Tests\run.ps1') @PSBoundParameters
