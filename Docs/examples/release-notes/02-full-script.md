# Full Release Notes Script

This example shows how to create a reusable script for generating release notes from Git commits to Excel format.

## Overview

For production use, it's recommended to create dedicated scripts that encapsulate common parameters and settings. This approach:

- Simplifies repeated release notes generation
- Centralizes configuration (collection, project, time zone)
- Provides consistent output formatting

## Script Structure

Create two files:

1. **project42.release.ps1** - Main script with configuration
2. **run.ps1** - Simple runner script with parameters

## project42.release.ps1

```powershell
#requires -version 5
<#
    .SYNOPSIS
        Generate release notes for Project42.

    .PARAMETER DateFrom
        Start date for the release notes period.

    .PARAMETER DateTo
        End date for the release notes period.

    .PARAMETER AsOf
        Point in time for querying work item state.

    .PARAMETER TargetBranch
        The branch to generate release notes for.

    .PARAMETER Path
        Output directory for the Excel file.

    .PARAMETER Show
        Flag to open the generated Excel file.

    .PARAMETER UseConstantFileName
        Use a constant filename instead of timestamped.

    .PARAMETER PassThru
        Flag, whether return the generated file.
        This can be used to hand down the file to another process.
#>

[CmdletBinding()]
param(
    [Nullable[DateTime]] $DateFrom,
    [Nullable[DateTime]] $DateTo,
    [Nullable[DateTime]] $AsOf,
    $TargetBranch = 'master',
    $Path = ([Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)),
    [switch] $Show,
    [switch] $UseConstantFileName,
    [bool] $PassThru = $true
)

Import-Module AzureDevOpsApi -Force

Set-ApiVariables `
    -Collection 'https://dev.azure.com/my-org' `
    -Project 'Project42'

Export-ReleaseNotesFromGitToExcel `
    -TimeZone 'Central Europe Standard Time' `
    -Path $Path `
    -DateFrom $DateFrom `
    -DateTo $DateTo `
    -AsOf $AsOf `
    -TargetBranch $TargetBranch `
    -UseConstantFileName:$UseConstantFileName `
    -PassThru:$PassThru `
    -Show:$Show
```

## run.ps1

```powershell
[CmdletBinding()]
param()

& (Join-Path -Path $PSScriptRoot -ChildPath '.\project42.release.ps1') `
    -DateFrom '2024-01-18Z' `
    -DateTo '2024-04-04Z' `
    -Show
```

## Usage

Simply run the runner script:

```powershell
.\run.ps1
```

Or call the main script directly with custom parameters:

```powershell
.\project42.release.ps1 `
    -DateFrom '2024-01-01' `
    -DateTo '2024-03-31' `
    -TargetBranch 'develop' `
    -Show
```

## Key Features

1. **TimeZone Handling**: Specify the time zone for date filtering
2. **Flexible Date Range**: Filter commits by date range
3. **Point-in-Time Query**: Use `-AsOf` to query work item state at a specific time
4. **Auto-Open**: Use `-Show` flag to automatically open the generated Excel file
5. **Custom Output**: Control output directory and filename

## Output

The script generates an Excel file with:

- Work items associated with commits in the specified date range
- Work item relationships (parent-child, tests, affects, etc.)
- Formatted worksheets for easy review

## Related Examples

- [Basic Workflow](./01-basic-workflow.md) - Understanding the underlying cmdlet
- [Work Items Methodology](../work-items/readme.md) - How relationships are tracked
