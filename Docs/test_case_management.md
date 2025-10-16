# Test Case Management - Quick Overview

The Test Case Management (TCM) functions provide a **git-like workflow** for managing Azure DevOps test cases through local YAML files with seamless synchronization to remote work items. This is useful for teams that prefer a local-first approach with version control, while still leveraging Azure DevOps for test case execution and tracking.

## Key Concepts

- **Hybrid Loading**: Numeric IDs check local files first, fall back to API; non-numeric IDs are local-only
- **Git-Like Operations**: Use `-Push`, `-Pull`, and `-Force` for synchronization
- **3-Way Merge**: Hash cache (`.tcm-hashes.json`) tracks changes for intelligent conflict detection
- **Dual Data Model**: Objects contain both `LocalData` (YAML) and `RemoteData` (API)

## Quick Start

```powershell
# 1. Create configuration
New-TcmConfig -TestCasesRoot "C:\MyProject\TestCases" `
              -CollectionUri "https://dev.azure.com/myorg" `
              -Project "MyProject"

# 2. Create test case
New-TcmTestCase -Id "TC001" -Title "User Login Test"

# 3. Query test cases
Get-TcmTestCase | Where-Object { $_.LocalData.testCase.state -eq "Ready" }

# 4. Synchronize
Sync-TcmTestCase -Push              # Push local changes
Sync-TcmTestCase -Pull              # Pull remote changes
Sync-TcmTestCase -Push -Force       # Force overwrite conflicts
```

## Core Functions

| Function | Purpose |
|----------|---------|
| `New-TcmConfig` | Create `.tcm-config.yaml` configuration |
| `New-TcmTestCase` | Create test case YAML file |
| `Get-TcmTestCase` | Retrieve from local YAML and/or Azure DevOps |
| `Sync-TcmTestCase` | Synchronize with `-Push`, `-Pull`, `-Force` |
| `Resolve-TcmTestCaseConflict` | Manually resolve conflicts |

## Understanding Sync Operations

`Sync-TcmTestCase` supports two styles of operation to fit different workflows:

### GitStyle Parameters (Recommended)
Most users find this intuitive if familiar with Git:
- **`-Push`** - Send local changes to Azure DevOps
- **`-Pull`** - Get remote changes from Azure DevOps
- **`-Force`** - Overwrite conflicts (use with Push or Pull)

```powershell
# Push your local changes
Sync-TcmTestCase -Push

# Pull remote changes
Sync-TcmTestCase -Pull

# Force overwrite conflicts
Sync-TcmTestCase -Push -Force
```

### Explicit Direction Parameter
Better for automation scripts where direction is dynamic:
- **`-Direction ToRemote`** - Equivalent to `-Push`
- **`-Direction FromRemote`** - Equivalent to `-Pull`
- **`-Direction Bidirectional`** - Sync both ways (advanced)

```powershell
# Dynamic direction based on logic
$direction = if ($localNewer) { "ToRemote" } else { "FromRemote" }
Sync-TcmTestCase -Direction $direction

# Bidirectional sync
Sync-TcmTestCase -Direction Bidirectional
```

**Recommendation:** Use GitStyle parameters (`-Push`/`-Pull`) for interactive work. Use `-Direction` for automation scenarios where the sync direction is calculated at runtime.

## Sync States

- `synced` - No changes since last sync
- `local-changes` - Only local modified
- `remote-changes` - Only remote modified
- `conflict` - Both changed (requires resolution)
- `new-local` - Exists only locally
- `new-remote` - Exists only remotely

## Object Structure

Test case objects returned by `Get-TcmTestCase` have a dual data model structure:

```powershell
[PSCustomObject]@{
    PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended'

    # Local YAML file data
    LocalData = @{
        testCase = @{
            id = "TC001"
            title = "User Login Test"
            state = "Design"
            priority = 2
            assignedTo = "user@example.com"
            steps = @(...)
            # ... other YAML properties
        }
    }

    # Remote Azure DevOps work item data (when synced)
    RemoteData = @{
        id = 12345
        fields = @{
            "System.Title" = "User Login Test"
            "System.State" = "Design"
            "System.WorkItemType" = "Test Case"
            # ... other Azure DevOps fields
        }
    }

    # Sync status information
    SyncStatus = "synced"  # or: local-changes, remote-changes, conflict, etc.
    FilePath = "C:\TestCases\TC001-login.yaml"
    LocalHash = "abc123..."
    RemoteHash = "abc123..."
}
```

### Accessing Properties

```powershell
$tc = Get-TcmTestCase -Id "TC001"

# Local YAML data (always available for local files)
$tc.LocalData.testCase.title      # "User Login Test"
$tc.LocalData.testCase.state      # "Design"
$tc.LocalData.testCase.steps      # Array of test steps

# Remote work item data (available after sync)
$tc.RemoteData.fields["System.Title"]
$tc.RemoteData.fields["System.State"]
$tc.RemoteData.id                 # Numeric work item ID

# Sync metadata
$tc.SyncStatus                    # "synced", "local-changes", etc.
$tc.FilePath                      # Full path to YAML file
```

### Common Patterns

```powershell
# Filter by local state
Get-TcmTestCase | Where-Object { $_.LocalData.testCase.state -eq "Ready" }

# Find test cases with local changes
Get-TcmTestCase -IncludeSyncStatus |
    Where-Object { $_.SyncStatus -eq "local-changes" }

# Access test steps
$tc = Get-TcmTestCase -Id "TC001"
$tc.LocalData.testCase.steps | ForEach-Object {
    Write-Host "Step: $($_.action)"
}
```

## File Structure

```text
TestCases/
├── .tcm-config.yaml          # Configuration
├── .tcm-hashes.json          # Change tracking (auto-generated)
├── authentication/
│   ├── 12345-login.yaml      # Synced (numeric ID)
│   └── TC001-sso.yaml        # Local-only (non-numeric)
└── api/
    └── 12346-api-auth.yaml
```

## Testing

- **100% Test Pass Rate** (39/39 tests)
- Unit tests for all functions
- Integration tests for sync workflows

## Learn More

- **[Examples](examples/test-case-management/)** - Detailed walkthroughs and use cases
- **[Function Reference](functions/Get-TcmTestCase.md)** - Complete cmdlet documentation
