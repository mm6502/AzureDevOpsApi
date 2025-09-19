# Unit tests using Pester

- [https://pester.dev/](https://pester.dev/)
- [https://pester.dev/docs/commands/mock/](https://pester.dev/docs/commands/mock/)

## Setup

``` powershell
if (-not (Get-InstalledModule -Name Pester)) {
    Install-Module -Name Pester
}
```

## Run tests

``` powershell
.\Tests\run.ps1
```

``` text
Starting discovery in 1 file.
Discovery found 33 tests in 55ms.
Running tests.
[+] .\Tests\AzureDevOpsApi.lib.tests.ps1 429ms (308ms|109ms)
Tests completed in 1.33s
Tests Passed: 33, Failed: 0, Skipped: 0 NotRun: 0
```
