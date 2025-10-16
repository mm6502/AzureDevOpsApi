# TestCaseManagement Examples

Detailed examples and walkthroughs for using TestCaseManagement with Azure DevOps.

> **Quick Reference**: See [TestCaseManagement Overview](../../test_case_management.md) for a concise feature summary.

## What You'll Learn

These examples demonstrate practical workflows for managing test cases with a git-like approach:

- Creating and configuring test case repositories
- Authoring test cases in YAML format
- Synchronizing with Azure DevOps using `-Push`, `-Pull`, `-Force`
- Resolving conflicts with 3-way merge detection
- Organizing test cases in folder hierarchies
- Advanced scenarios for custom fields and bulk operations

## Prerequisites

- Azure DevOps organization and project
- Azure DevOps credentials configured (see [credentials examples](../credentials/))
- PowerShell with AzureDevOpsApi module

## Example Walkthroughs

Follow these examples in order for a complete learning path:

### 1. [Setup Configuration](./01-setup-configuration.md)

Create `.tcm-config.yaml` with connection settings, sync preferences, and exclude patterns.

**Topics**: Configuration file structure, connection parameters, sync options

### 2. [Creating Test Cases](./02-creating-test-cases.md)

Create test case YAML files and understand the schema structure.

**Topics**: YAML structure, numeric vs non-numeric IDs, test steps, `New-TcmTestCase`, `Get-TcmTestCase`

### 3. [Folder Organization](./03-folder-organization.md)

Organize test cases in folder hierarchies and map to Azure DevOps area paths.

**Topics**: Folder structures, area path mapping, exclude patterns, moving test cases

### 4. [Sync Workflows](./04-sync-workflows.md)

Master git-like synchronization with `-Push`, `-Pull`, and `-Force` operations.

**Topics**: Push/pull operations, force overwrite, bidirectional sync, sync states, bulk operations

### 5. [Conflict Resolution](./05-conflict-resolution.md)

Understand 3-way merge conflict detection and resolution strategies.

**Topics**: Conflict detection, resolution strategies (Manual, LocalWins, RemoteWins), `Resolve-TcmTestCaseConflict`

### 6. [Advanced Scenarios](./06-advanced-scenarios.md)

Work with custom fields, bulk operations, and performance optimization.

**Topics**: Custom fields, bulk processing, advanced patterns, performance optimization

## Reference

### Core Functions

| Function | Purpose |
|----------|---------|
| `New-TcmConfig` | Create `.tcm-config.yaml` configuration file |
| `New-TcmTestCase` | Create new test case YAML file |
| `Get-TcmTestCase` | Retrieve test cases (hybrid: local YAML + remote API) |
| `Sync-TcmTestCase` | Synchronize with git-like `-Push`, `-Pull`, `-Force` options |
| `Resolve-TcmTestCaseConflict` | Manually resolve sync conflicts |

### Common Patterns

**Query and filter test cases:**

```powershell
Get-TcmTestCase | Where-Object { $_.LocalData.testCase.state -eq "Ready" }
Get-TcmTestCase | Where-Object { $_.SyncStatus -eq "local-changes" }
```

**Sync specific test cases:**

```powershell
"TC001", "TC002" | Sync-TcmTestCase -Push
Get-TcmTestCase | Where-Object { $_.SyncStatus -eq "local-changes" } | Sync-TcmTestCase -Push
```

**Inspect dual data model:**

```powershell
$tc = Get-TcmTestCase -InputObject "12345"
$tc.LocalData   # From YAML file
$tc.RemoteData  # From Azure DevOps API
$tc.SyncStatus  # synced, local-changes, remote-changes, conflict, etc.
```

## Best Practices

- **Version Control**: Commit YAML files and `.tcm-hashes.json` to git
- **Naming Conventions**: Use consistent ID prefixes (TC001, TC002) and descriptive filenames
- **Regular Sync**: Synchronize frequently to minimize conflicts
- **Exclude Patterns**: Configure `.tcm-config.yaml` to skip draft/template files
- **Team Workflow**: Share `.tcm-hashes.json` for team-wide conflict detection

## Troubleshooting

**Common Issues:**

- Connection errors: Verify Azure DevOps credentials are configured correctly
- YAML syntax errors: Use `-Verbose` to see detailed parsing errors
- Sync conflicts: Use `Get-TcmTestCase` to inspect both LocalData and RemoteData
- Missing test cases: Check exclude patterns in `.tcm-config.yaml`

**Debugging:**

- Use `-Verbose` parameter on all cmdlets for detailed output
- Check `.tcm-hashes.json` to see cached sync states
- Review Azure DevOps work item permissions
- Inspect YAML files for syntax errors with online validators

## Related Documentation

- [TestCaseManagement Overview](../../test_case_management.md) - Quick reference guide
- [Function Reference](../../functions/AzureDevOpsApi.md) - Complete cmdlet documentation
- [Azure DevOps REST API](https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items) - Work item API reference
