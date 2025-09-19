#requires -version 5
[CmdletBinding()]
param(
    # Allows to read test data by relative path to the test file
    $RootPath = $PSScriptRoot
)

# Flag to indicate that the test is running
$global:Pester = $true

# Reload the module
$ModuleName = 'AzureDevOpsApi'
if (-not $global:BatchTests) {
    Write-Host -ForegroundColor Yellow "Removing module $($ModuleName)"
    Remove-Module -Force -Name $ModuleName -ErrorAction SilentlyContinue
}
if (-not (Get-Module -Name $ModuleName)) {
    Write-Host -ForegroundColor Yellow "Importing module $($ModuleName)"
    Import-Module -Force -Name (Join-Path -Path $PSScriptRoot -ChildPath "..\$($ModuleName).psd1") -ArgumentList @($true)
}

# Import helper functions
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Helpers\Import-TestData.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Helpers\Repair-PSTypeName.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Helpers\New-TestApiCollectionConnection.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Helpers\New-TestApiProjectConnection.ps1')

# Disable progress bar during tests
$ProgressPreference = 'SilentlyContinue'
Mock -ModuleName $ModuleName -CommandName Write-Progress -MockWith { }
