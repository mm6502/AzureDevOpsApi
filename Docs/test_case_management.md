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
Get-TcmTestCase | Where-Object { $_.LocalData.state -eq "Ready" }

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

## Sync States

- `synced` - No changes since last sync
- `local-changes` - Only local modified
- `remote-changes` - Only remote modified
- `conflict` - Both changed (requires resolution)
- `new-local` - Exists only locally
- `new-remote` - Exists only remotely

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
