# 04 - Sync Workflows

This example demonstrates the different synchronization workflows available in the TestCaseManagement system: push, pull, and bidirectional sync operations.

## Overview

The TestCaseManagement system supports three main sync workflows:

- **Push**: Send local test case changes to Azure DevOps
- **Pull**: Retrieve test case changes from Azure DevOps
- **Bidirectional**: Two-way synchronization with intelligent conflict resolution

### Choosing Your Syntax

`Sync-TcmTestCase` supports two syntax styles:

**GitStyle (Recommended for interactive use):**
```powershell
Sync-TcmTestCase -Push
Sync-TcmTestCase -Pull
Sync-TcmTestCase -Push -Force
```

**Explicit Direction (Better for automation):**
```powershell
Sync-TcmTestCase -Direction ToRemote
Sync-TcmTestCase -Direction FromRemote
Sync-TcmTestCase -Direction Bidirectional
```

This guide uses GitStyle syntax for clarity. Both approaches are functionally equivalent.

## Push Operations

Pushing sends your local test case changes to Azure DevOps, creating new work items or updating existing ones.

### Push a Single Test Case

```powershell
# Push by test case ID
Sync-TcmTestCase -InputObject "TC001" -Push

# Push by file path
Sync-TcmTestCase -InputObject "TestCases/Authentication/Login-12345.yaml" -Push

# Push with confirmation
Sync-TcmTestCase -InputObject "TC001" -Push -Confirm
```

### Push Multiple Test Cases

```powershell
# Push all test cases in a folder
Get-ChildItem "TestCases/Smoke-Tests/*.yaml" | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}

# Push all test cases recursively
Get-ChildItem "TestCases/**/*.yaml" -Recurse | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}

# Push test cases matching a pattern
Get-ChildItem "TestCases/*-login*.yaml" -Recurse | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}
```

### Force Push (Overwrite Remote Changes)

```powershell
# Force push even if remote has changes
Sync-TcmTestCase -InputObject "TC001" -Push -Force

# Force push multiple test cases
Get-ChildItem "TestCases/*.yaml" | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push -Force
}
```

## Pull Operations

Pulling retrieves changes from Azure DevOps and updates your local YAML files.

### Pull a Single Test Case

```powershell
# Pull by Work Item ID
Sync-TcmTestCase -InputObject 12345 -Pull

# Pull to a specific location (create new file)
Sync-TcmTestCase -InputObject 12345 -Pull
# Note: Use -OutputPath with New-TcmTestCase to control location
```

### Pull All Test Cases with Changes

```powershell
# Pull all test cases that have remote changes
Sync-TcmTestCase -Pull

# This scans all local YAML files and pulls any that have been modified in Azure DevOps
```

### Force Pull (Overwrite Local Changes)

```powershell
# Force pull a specific test case
Sync-TcmTestCase -InputObject 12345 -Pull -Force

# Force pull all test cases with changes
Sync-TcmTestCase -Pull -Force
```

## Understanding Sync Status

Before performing sync operations, you can check the status of your test cases:

```powershell
# Check sync status of a specific test case
Get-TcmTestCase -Id "TC001" -IncludeSyncStatus

# Check sync status of all test cases
Get-ChildItem "TestCases/*.yaml" | ForEach-Object {
    Get-TcmTestCase -InputObject $_.FullName -IncludeSyncStatus
}
```

Possible sync statuses:

- `synced`: Local and remote are in sync
- `local-changes`: Local file has changes not pushed to remote
- `remote-changes`: Remote work item has changes not pulled locally
- `conflict`: Both local and remote have changes
- `new-local`: Test case exists locally but not remotely
- `new-remote`: Test case exists remotely but not locally

## Bidirectional Workflow

The `Sync-TcmTestCase` command provides intelligent bidirectional synchronization with git-like syntax:

```powershell
# Bidirectional sync (default behavior)
Sync-TcmTestCase

# Or using explicit parameters
Sync-TcmTestCase -Direction Bidirectional

# Git-like syntax for push
Sync-TcmTestCase -Push

# Git-like syntax for pull
Sync-TcmTestCase -Pull -Force
```

For manual control, you can use the explicit parameter sets:

```powershell
# Manual bidirectional sync
Write-Host "Pulling changes from Azure DevOps..."
Sync-TcmTestCase -Pull

Write-Host "Pushing local changes to Azure DevOps..."
Get-ChildItem "TestCases/*.yaml" | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}
```

## Common Sync Scenarios

### Scenario 1: Daily Development Workflow

```powershell
# 1. Pull latest changes from team
Sync-TcmTestCase -Pull

# 2. Make your changes to test cases
# Edit YAML files...

# 3. Push your changes
Get-ChildItem "TestCases/My-Changes/*.yaml" | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}
```

### Scenario 2: Importing Existing Test Cases

```powershell
# Import specific test cases from Azure DevOps
Sync-TcmTestCase -InputObject 12345 -Pull
Sync-TcmTestCase -InputObject 12346 -Pull

# Edit the imported test cases
# ...

# Push back to Azure DevOps
Sync-TcmTestCase -InputObject "12345" -Push
Sync-TcmTestCase -InputObject "12346" -Push
```

### Scenario 3: Bulk Operations

```powershell
# Create multiple test cases locally
New-TcmTestCase -Title "Test Case 1" -OutputPath "Bulk/TC001.yaml"
New-TcmTestCase -Title "Test Case 2" -OutputPath "Bulk/TC002.yaml"
# ... create more test cases

# Push all at once
Get-ChildItem "Bulk/*.yaml" | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}
```

### Scenario 4: Team Collaboration

```powershell
# As a team lead: Pull all changes from team members
Sync-TcmTestCase -Pull

# Review changes
Get-TcmTestCase -IncludeSyncStatus | Where-Object { $_.SyncStatus -eq "remote-changes" }

# As a team member: Push your work
Get-ChildItem "TestCases/My-Feature/*.yaml" | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}
```

## Sync Best Practices

### 1. Pull Before Push

Always pull changes before pushing to avoid conflicts:

```powershell
# Good practice
Sync-TcmTestCase -Pull  # Pull first
Sync-TcmTestCase -InputObject "TC001" -Push  # Then push
```

### 2. Use Force Sparingly

Only use `-Force` when you're sure you want to overwrite changes:

```powershell
# Check status first
$tc = Get-TcmTestCase -Id "TC001" -IncludeSyncStatus

# Only then decide to force
if ($tc.SyncStatus -eq "conflict") {
    Sync-TcmTestCase -InputObject "TC001" -Push -Force
}
```

### 3. Backup Before Bulk Operations

```powershell
# Create backup before bulk sync
Copy-Item "TestCases" "TestCases-Backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Recurse

# Perform bulk operation
Get-ChildItem "TestCases/*.yaml" -Recurse | ForEach-Object {
    Sync-TcmTestCase -InputObject $_.FullName -Push
}
```

### 4. Test with WhatIf First

```powershell
# See what would happen without making changes
Sync-TcmTestCase -InputObject "TC001" -Push -WhatIf
Sync-TcmTestCase -InputObject 12345 -Pull -WhatIf
```

## Troubleshooting Sync Issues

### Sync Fails with Authentication Error

```powershell
# Check your configuration
Get-Content ".tcm-config.yaml"

# Reconfigure if needed
New-TcmConfig -CollectionUri "https://dev.azure.com/your-org" -Project "YourProject"
```

### Test Case Not Found

```powershell
# For push operations
Get-TcmTestCase -Id "TC001"  # Verify the test case exists locally

# For pull operations
# Verify the Work Item ID exists in Azure DevOps
```

### Permission Issues

Ensure your Azure DevOps PAT has the following permissions:

- Work Items: Read, Create, Edit
- Test Management: Read, Write

## Related Examples

- [01-setup-configuration.md](01-setup-configuration.md) - Setting up your configuration
- [02-creating-test-cases.md](02-creating-test-cases.md) - Creating test cases
- [03-folder-organization.md](03-folder-organization.md) - Organizing test cases in folders
- [05-conflict-resolution.md](05-conflict-resolution.md) - Handling sync conflicts
