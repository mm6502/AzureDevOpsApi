## AzureDevOpsApi — Essentials for AI agents

- Project:

    - PowerShell module.
    - Root files: `AzureDevOpsApi.psd1`, `AzureDevOpsApi.psm1`.
    - Dependency: `ImportExcel` (in `RequiredModules`).

- Key dirs:

    - `Init/` (globals, types),
    - `Public/` (exported cmdlets),
    - `Private/` (helpers),
    - `Tests/`,
    - `Docs/`.

- Loader: `AzureDevOpsApi.psm1` dot-sources `Init/Init.ps1` then all `Private/*.ps1` and `Public/*.ps1`.
  Add exported cmdlets to `Public/`. Has `$ForTests` argument to enable exporting Private functions for
  tests. Usage: `Import-Module .\AzureDevOpsApi.psm1 -ArgumentList @($true)`.

- Important globals in `Init/Globals.ps1`:

    -`$global:ApiCredentialsCache`,
    -`$global:ApiCollectionsCache`,
    -`$global:ApiProjectsCache`,
    -`$global:AzureDevOpsApi_RetryConfig`.

    Treat mutations carefully and update tests.

- Testing:

    - Run individual test files by directly calling them with `Tests/*/<tested-function>.tests.ps1`
      when needed.
    - When needed run all tests with `Tests/run.ps1` (Pester). Use `-SkipCodeCoverage` or `-Detailed`
      as needed. Tests enable batch mode (`$global:BatchTests = $true`).

- Coding:

    - Use spaces for indentation (4 spaces).
    - When calling functions with more than 3 parameters (and not using splatting), use multiline
      formatting for readability, e.g.:
      ```powershell
      My-Function `
          -Param1 $value1 `
          -Param2 $value2 `
          -Param3:$value3 # use the colon notation for switch params
      ```
    - Don't rename/change globals without updating `Init/Globals.ps1` and tests.
    - Put new cmdlets in `Public/` or `Private/` with `CmdletBinding()`, add Pester tests in `Tests/`.
    - Each subfolder in `Tests/` corresponds to a module subfolder (`Public/` or `Private/`),
      and contains `BeforeAll.ps1` for setup and test files in that directory.
    - Test scripts in `Tests/` begin with importing `.\BeforeAll.ps1` file from the same directory for
      basic setup and module initialization, e.g.:
        ```powershell
        BeforeAll {
            . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
        }
        ```
