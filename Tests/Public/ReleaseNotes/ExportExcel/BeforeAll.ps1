#requires -version 5
[CmdletBinding()]
param(
    # allows to read test data by relative path to the test file
    $RootPath = $PSScriptRoot
)

. (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1') -RootPath $RootPath

if (-not (Get-Module -Name ImportExcel)) {
    Import-Module ImportExcel
}
