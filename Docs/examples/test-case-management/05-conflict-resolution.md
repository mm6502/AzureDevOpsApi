# 05 - Conflict Resolution

This example demonstrates how to handle synchronization conflicts that occur when both local and remote test cases have been modified.

## Overview

Conflicts happen when:

- You modify a local test case
- Someone else modifies the same test case in Azure DevOps
- You try to sync without resolving the differences

The TestCaseManagement system provides tools to detect and resolve these conflicts.

## Understanding Conflict Types

### Sync Status Values

- `synced`: Local and remote are identical
- `local-changes`: Local file has modifications not pushed
- `remote-changes`: Remote work item has modifications not pulled
- `conflict`: Both local and remote have different modifications
- `new-local`: Test case exists locally but not remotely
- `new-remote`: Test case exists remotely but not locally

## Detecting Conflicts

### Check Sync Status

```powershell
# Check status of a specific test case
Get-TcmTestCase -Id "TC001" -IncludeSyncStatus

# Check status of all test cases
Get-ChildItem "TestCases/*.yaml" -Recurse | Resolve-TcmTestCaseFilePathInput | Get-TcmTestCase -IncludeSyncStatus

# Filter for conflicts only
Get-ChildItem "TestCases/*.yaml" -Recurse | Resolve-TcmTestCaseFilePathInput | Get-TcmTestCase -IncludeSyncStatus | Where-Object { $_.SyncStatus -eq "conflict" }
```

### Manual Sync Operations

```powershell
# Attempting to push when there's a conflict
Sync-TcmTestCaseToRemote -InputObject "TC001"
# This will fail with a conflict error

# Attempting to pull when there's a conflict
Sync-TcmTestCaseFromRemote -Id 12345
# This will also fail with a conflict error
```

## Conflict Resolution Strategies

### Strategy 1: Use Local Version (Overwrite Remote)

```powershell
# Force push your local changes, overwriting remote
Sync-TcmTestCaseToRemote -InputObject "TC001" -Force

# This resolves the conflict by making remote match local
```

### Strategy 2: Use Remote Version (Overwrite Local)

```powershell
# Force pull remote changes, overwriting local
Sync-TcmTestCaseFromRemote -Id 12345 -Force

# This resolves the conflict by making local match remote
```

### Strategy 3: Manual Resolution

For complex conflicts, you need to manually decide which changes to keep:

```powershell
# 1. Get both versions
$local = Get-TcmTestCase -Id "TC001" -IncludeMetadata
$remote = Get-WorkItem -WorkItem 12345 -CollectionUri "https://dev.azure.com/org" -Project "Project"

# 2. Compare differences manually
# Look at $local.testCase and $remote.fields

# 3. Edit the local YAML file to incorporate desired changes

# 4. Push the resolved version
Sync-TcmTestCaseToRemote -InputObject "TC001"
```

### Strategy 4: Interactive Resolution (Future Feature)

```powershell
# This feature is planned but not yet implemented
Resolve-TcmTestCaseConflict -Id "TC001" -Interactive
```

## Common Conflict Scenarios

### Scenario 1: Title Changed in Both Places

**Local YAML:**
```yaml
testCase:
  id: 12345
  title: "User Login Validation"
  # ... other fields
```

**Remote Work Item:**
- Title: "Login Form Validation"

**Resolution:**
```powershell
# Option A: Keep local title
Sync-TcmTestCaseToRemote -InputObject "TC001" -Force

# Option B: Keep remote title
Sync-TcmTestCaseFromRemote -Id 12345 -Force

# Option C: Choose a new title
# Edit the YAML file, then push
(Get-Content "TestCases/TC001.yaml" -Raw) -replace "User Login Validation", "User Authentication" | Set-Content "TestCases/TC001.yaml"
Sync-TcmTestCaseToRemote -InputObject "TC001"
```

### Scenario 2: Test Steps Modified

**Local YAML:**
```yaml
steps:
  - stepNumber: 1
    action: "Navigate to login page"
    expectedResult: "Login form appears"
  - stepNumber: 2
    action: "Enter credentials"
    expectedResult: "User is logged in"
```

**Remote Work Item:**
- Step 1: "Go to login page" → "Login page loads"
- Step 2: "Enter username and password" → "Authentication succeeds"

**Resolution:**
```powershell
# Review both versions
$local = Get-TcmTestCase -Id "TC001"
$remote = Get-WorkItem -WorkItem 12345

# Edit local YAML to merge the best of both
# Then push
Sync-TcmTestCaseToRemote -InputObject "TC001"
```

### Scenario 3: State Changed

**Local:** `state: "Ready"`
**Remote:** `state: "Closed"`

**Resolution:**
```powershell
# If remote state is correct
Sync-TcmTestCaseFromRemote -Id 12345 -Force

# If local state is correct
Sync-TcmTestCaseToRemote -InputObject "TC001" -Force
```

## Best Practices for Avoiding Conflicts

### 1. Pull Before Editing

```powershell
# Always pull latest changes before making edits
Sync-TcmTestCaseFromRemote

# Then make your changes
# Edit YAML files...

# Push when done
Sync-TcmTestCaseToRemote -InputObject "YourChanges"
```

### 2. Work on Different Test Cases

```powershell
# Assign different test cases to different team members
# This reduces the chance of conflicts
```

### 3. Use Branches (for Git-based workflows)

```powershell
# Create a branch for your changes
git checkout -b feature/new-test-cases

# Make changes, then merge
git add TestCases/
git commit -m "Add new test cases"
git push origin feature/new-test-cases

# Merge after review
```

### 4. Regular Sync Schedule

```powershell
# Set up a regular sync routine
# Pull in the morning
Sync-TcmTestCaseFromRemote

# Push at end of day
Get-ChildItem "TestCases/MyWork/*.yaml" | Resolve-TcmTestCaseFilePathInput | Sync-TcmTestCaseToRemote
```

## Advanced Conflict Resolution

### Using Git for Conflict Resolution

```powershell
# If your test cases are in Git, you can use Git's merge tools
git add TestCases/
git commit -m "Work in progress"

# Pull and handle merge conflicts
git pull --no-ff

# Resolve conflicts in YAML files using Git's mergetool
git mergetool

# Complete the merge
git commit
```

### Bulk Conflict Resolution

```powershell
# Find all conflicts
$conflicts = Get-ChildItem "TestCases/*.yaml" -Recurse | Resolve-TcmTestCaseFilePathInput | Get-TcmTestCase -IncludeSyncStatus | Where-Object { $_.SyncStatus -eq "conflict" }

# Resolve each conflict (example: prefer local)
foreach ($conflict in $conflicts) {
    Sync-TcmTestCaseToRemote -InputObject $conflict.Id -Force
}
```

### Backup Before Resolution

```powershell
# Always backup before resolving conflicts
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item "TestCases" "TestCases-Backup-$timestamp" -Recurse -Force

# Then resolve conflicts
Sync-TcmTestCaseToRemote -InputObject "TC001" -Force
```

## Troubleshooting

### Conflict Resolution Fails

```powershell
# Check if the test case still exists
Get-TcmTestCase -Id "TC001"

# Verify your permissions
# Ensure you have edit permissions on the work item

# Check network connectivity
Test-NetConnection "dev.azure.com" -Port 443
```

### Unexpected Conflicts

If you get conflicts when you shouldn't:

```powershell
# Check the actual differences
$local = Get-TcmTestCase -Id "TC001" -IncludeMetadata
$remote = Get-WorkItem -WorkItem 12345

# Compare timestamps
$local.history.lastModifiedAt
$remote.fields.'System.ChangedDate'
```

### Force Doesn't Work

```powershell
# Check your Azure DevOps permissions
# Ensure your PAT has the correct scopes:
# - Work Items: Read & Write
# - Project and Team: Read
```

## Related Examples

- [03-folder-organization.md](03-folder-organization.md) - Organizing test cases
- [04-sync-workflows.md](04-sync-workflows.md) - Basic sync operations
- [06-advanced-scenarios.md](06-advanced-scenarios.md) - Advanced features
