# AzureDevOpsApi Powershell Module

## Description

This module provides functionality to interact with the Azure DevOps REST APIs.
It allows querying, creating and modifying work items and creating release notes.

## Principles

The module operates on credential-based authorization, allowing both Windows
default credentials, username / password credentials and API tokens. It
maintains a centralized configuration through global variables that can be set
once and reused across function calls, while the session lasts. The module
follows a hierarchical approach to data handling, where work items, pull
requests, and their relationships are tracked and can be exported in various
formats. It emphasizes reusability by allowing parameters to be passed down
through the call chain while providing sensible defaults when not specified.

Read more in [Principles](principles.md).

## How to start

### Setup

Install prerequisites and the module itself from the PowerShell Gallery

```powershell
# ImportExcel - For exporting to Excel files
Install-Module -Name 'ImportExcel'

# Install the module
Install-Module -Name 'AzureDevOpsApi'
```

### Usage

#### Basic Functions

``` powershell
Import-Module AzureDevOpsApi

# Set the variables for the Azure DevOps collection and project.
# Windows default credentials are used when not specified.
Set-ApiVariables `
    -Collection 'https://dev.azure.com/my-org/my-project' `
    -Project 'Project42'

# Assuming the work item ids came from a pull request.
$workItemIds = @(373872, 373877, 373870)
Add-WorkItemToReleaseNotesData `
    -Reason 'PullRequest' `
    -WorkItemId $workItemIds `
| Format-Table 'WorkItemId', 'WorkItemType', 'Reasons', 'Relations'
```

Output should look like this:

``` text
WorkItemId WorkItemType Reasons                         Relations
---------- ------------ -------                         ---------
373872     Task         PullRequest                     Child (#373871)
373877     Task         PullRequest                     Child (#373875)
373870     Task         PullRequest                     Child (#373863)
373871     Bug          PullRequest, Parent             Parent (#373872), TestedBy (#373869)
373875     Requirement  PullRequest, Parent             Parent (#373877), Child (#373862), Affects (#373863)
373863     Requirement  PullRequest, Parent, AffectedBy Parent (#373870), TestedBy (#373869), Child (#373862)
373869     Test Case    PullRequest, Tests              Tests (#373871)
373862     Feature      PullRequest, Parent             Parent (#373875)
```

#### Generating Release Notes Data

For example, if we want to generate release notes data for project "Project42",
it is recomended to make 2 files.

1. `project42.release.ps1`, which will greatly simplify the usage by setting
the common parameters for given use case:

    ```powershell
    #requires -version 5
    <#
        .SYNOPSIS
            Runs exemplary compilation of release notes data.

        .PARAMETER DateFrom
            Starting date for the considered PullRequests.

        .PARAMETER DateTo
            Ending date for the considered PullRequests.

        .PARAMETER AsOf
            Gets the Work Items as they were at this date and time.

        .PARAMETER TargetBranch
            Target branch for the PullRequests.
            Default is 'master'.

        .PARAMETER Path
            Path, where the generated file will be saved.
            Can be a direcotry or filename, relative or absolute.
            Default is the user's Desktop.

        .PARAMETER UseConstantFileName
            Flag, whether to use constant file name.
            If $true, 'ReleaseNotes.xlsx' will be the name of generated file.
            Otherwise, name of the file will also contain date and time of creation.

        .PARAMETER Show
            Flag, whether open the exported document in associated application.

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

1. `run.ps1`, which will be used to run the script.

    ```powershell
    [CmdletBinding()]
    param()

    & (Join-Path -Path $PSScriptRoot -ChildPath '.\project42.release.ps1') `
        -DateFrom '2024-01-18Z' `
        -DateTo '2024-04-04Z' `
        -Show
    ```

## Example

This example shows how to set up credentials for different collections and
projects and use them in API calls.

``` powershell
# Set default CollectionUri and Project
Set-ApiVariables `
    -CollectionUri 'https://dev.azure.com/my-org1' `
    -Project 'MyProject1'
    -Authorization 'PAT' `
    -Token 'my-token1'

# Add credentials for another collection and project
Add-ApiCredential `
    -CollectionUri 'https://dev.azure.com/other-org2' `
    -Project 'OtherProject2' `
    -Authorization 'PAT' `
    -Token 'other-token2'

# Get work item by ID from default collection and project
# Note: the CollectionUri and Project are determined from the defaults
Get-WorkItem 123

# Get work item by ID from another collection and project
# Note: the CollectionUri and Project must be specified
Get-WorkItem 234 `
    -CollectionUri 'https://dev.azure.com/other-org2' `
    -Project 'OtherProject2'

# Get work items by their urls
# Note: the CollectionUri and Project are determined from the url
# Note: Portal URLs or API URLs can be used
Get-WorkItem 'https://dev.azure.com/my-org1/MyProject1/_workitems/edit/123'
Get-WorkItem 'https://dev.azure.com/other-org2/OtherProject2/_apis/wit/workitems/234'
```

