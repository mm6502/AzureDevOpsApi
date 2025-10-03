# Unit tests using Pester

- [https://pester.dev/](https://pester.dev/)
- [https://pester.dev/docs/commands/mock/](https://pester.dev/docs/commands/mock/)

## Setup

Install Pester if not already installed:

```powershell
Install-Module -Name Pester
```

## Run tests

To run all the tests, execute the following command in the root of the repository:

```powershell
.\Tests\run.ps1
```

To run a specific test file, execute the file itself:

```powershell
.\Tests\Public\Misc\Credentials\Show-ApiCredentialsList.tests.ps1
```

Output should look like this:

```text
Starting discovery in 1 file.
Discovery found 33 tests in 55ms.
Running tests.
[+] Show-ApiCredentialsList.tests.ps1 429ms (308ms|109ms)
Tests completed in 1.33s
Tests Passed: 33, Failed: 0, Skipped: 0 NotRun: 0
```
