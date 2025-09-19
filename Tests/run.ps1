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

if ($Verbose.IsPresent -and $Verbose -eq $true) {
    $Verbose = $true
}

$WithCodeCoverage = -not ($SkipCodeCoverage.IsPresent -and ($SkipCodeCoverage -ne $true))

function Show-CodeCoverageResult {
    [CmdletBinding()]
    param()

    # Read the coverage report
    $coverageXml = [xml] (Get-Content ($config.CodeCoverage.OutputPath.Value))

    # Find the missed functions
    $missedFunctions = $coverageXml.DocumentElement.SelectNodes(
        "//report/package/class/method[counter[@type='METHOD' and @missed='1']]/@name"
    ).Value `
    | Where-Object { $_ -ne '<script>' } `
    | Sort-Object

    # Write them out if any
    if ($missedFunctions.Count -gt 0) {
        Write-Host -ForegroundColor Magenta "Missed functions:"
        $missedFunctions | Write-Host
    }
}

function Remove-CodeCoverageResult {
    [CmdletBinding()]
    param()

    # Remove the coverage data
    Remove-Item -Path ($config.CodeCoverage.OutputPath.Value)
}

function Show-SkippedTests {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $TestResults
    )

    # Find skipped tests
    $skippedTests = $TestResults.Tests | Where-Object { $_.Result -eq 'Skipped' }

    # Write them out if any
    if ($skippedTests.Count -gt 0) {
        Write-Host -ForegroundColor Yellow "`nSkipped tests:`n"
        foreach ($test in $skippedTests) {
            $testPath = if ($test.Path) { $test.Path -join ' -> ' } else { $test.Name }
            Write-Host -ForegroundColor Yellow "[-] $testPath"
        }
        Write-Host -ForegroundColor Yellow "`nTotal skipped: $($skippedTests.Count)"
    }
}

# Create a Pester configuration object using `New-PesterConfiguration`
$config = New-PesterConfiguration

$rootPath = Join-Path -Path $PSScriptRoot -ChildPath '..'

# Set the test path to specify where your tests are located.
# Can be set to the current directory.
# Pester will look into all subdirectories.
$config.Run.Path = Resolve-Path `
    -Relative `
    -Path (Join-Path -Path $rootPath -ChildPath 'Tests')

# Enable returning test results
$config.Run.PassThru = $true

# Enable Code Coverage
if ($WithCodeCoverage) {
    $config.CodeCoverage.Enabled = $true
    if ($Detailed.IsPresent -and $Detailed -eq $true) {
        $config.Output.Verbosity = 'Detailed'
    }
    $config.CodeCoverage.Path = Resolve-Path `
        -Relative `
        -Path (Join-Path -Path $rootPath -ChildPath 'Public')
}

try {
    # Flag, to indicate that the test is running in batch mode
    # This is used to prevent unloading and reloading of the module for each test
    $global:BatchTests = $true

    # Force module refresh
    $ModuleName = 'AzureDevOpsApi'
    Write-Host -ForegroundColor Yellow "Removing module $($ModuleName)"
    Remove-Module -Force -Name $ModuleName -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Yellow "Importing module $($ModuleName)"
    $moduleFilePath = Join-Path -Path $PSScriptRoot -ChildPath "..\$($ModuleName).psd1"
    Import-Module -Force -Name $moduleFilePath -ArgumentList @($true)

    # Run Pester tests using the configuration you've created
    $testResults = Invoke-Pester -Configuration $config

    # Show skipped tests summary
    Show-SkippedTests -TestResults $testResults
} finally {
    $global:BatchTests = $false
}

# Code Coverage debriefing
if ($WithCodeCoverage) {
    Show-CodeCoverageResult
    if (!$KeepResults.IsPresent -or $KeepResults -eq $false) {
        Remove-CodeCoverageResult
    }
}
