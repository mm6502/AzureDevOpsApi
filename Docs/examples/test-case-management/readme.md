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

### 7. [Troubleshooting](./troubleshooting.md)

Diagnose and fix common issues with authentication, configuration, sync errors, and performance.

**Topics**: Authentication errors (401, 403), configuration issues, sync conflicts, data corruption, performance tuning, debug mode

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

## Git Integration

TestCaseManagement is designed to work seamlessly with Git version control, enabling team collaboration and change tracking for test cases.

### What to Commit to Git

**✅ DO commit these files:**

```gitignore
# Test case YAML files
TestCases/**/*.yaml

# Configuration
.tcm-config.yaml

# Hash tracking for sync state (essential for team collaboration)
.tcm-hashes.json
```

**Why commit `.tcm-hashes.json`?**
- Tracks sync state between local YAML and Azure DevOps
- Enables 3-way merge conflict detection across team
- Prevents false conflicts when multiple developers work simultaneously
- Small file that changes incrementally

### What NOT to Commit

**❌ DON'T commit these files:**

```gitignore
# Temporary files
*.tmp
*.bak

# Editor-specific files
.vscode/
.vs/
*.swp

# OS-specific files
.DS_Store
Thumbs.db

# Draft/work-in-progress test cases (optional)
TestCases/Drafts/
TestCases/**/*.draft.yaml
```

### Recommended .gitignore Template

Add this to your repository's `.gitignore`:

```gitignore
# TestCaseManagement - DO commit .tcm-config.yaml and .tcm-hashes.json

# Drafts and templates (optional - adjust to your workflow)
**/Drafts/
**/*.draft.yaml
**/*.template.yaml

# Backup files
*.bak
*.backup.yaml

# Editor and IDE
.vscode/
.vs/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
desktop.ini
```

### Team Collaboration Workflow

**Scenario:** Multiple developers working on test cases simultaneously

**1. Initial Setup (each developer):**

```powershell
# Clone repository
git clone https://your-repo.git
cd your-repo/TestCases

# Verify config exists
Get-Content .\.tcm-config.yaml

# Set up credentials (each developer uses their own PAT)
$env:AZURE_DEVOPS_PAT = "your-personal-pat-token"
```

**2. Before Starting Work:**

```powershell
# Pull latest from Git
git pull origin main

# Sync from Azure DevOps to get latest test case updates
Sync-TcmTestCase -Pull

# Check sync status
Get-TcmTestCase | Where-Object { $_.SyncStatus -ne "synced" }
```

**3. Making Changes:**

```powershell
# Edit test cases locally
code TestCases/TC001-login.yaml

# Or create new ones
New-TcmTestCase -Id "TC050" -Title "New Login Test"
```

**4. Before Committing:**

```powershell
# Push your changes to Azure DevOps first
Sync-TcmTestCase -Push

# Verify sync
Get-TcmTestCase | Select-Object Id, SyncStatus
```

**5. Commit to Git:**

```powershell
# Stage changes
git add TestCases/
git add .tcm-hashes.json  # Important!

# Commit
git commit -m "Added TC050: New login test with MFA validation"

# Push to remote
git push origin main
```

### Handling Git Merge Conflicts

**Scenario:** Two developers modified the same test case

**When Git reports conflict in YAML file:**

```powershell
# 1. Resolve the YAML file conflict manually in your editor
code TestCases/TC001-login.yaml

# 2. After resolving YAML, push to Azure DevOps
Sync-TcmTestCase -Id "TC001" -Push -Force

# 3. Mark as resolved in Git
git add TestCases/TC001-login.yaml
git add .tcm-hashes.json

git commit -m "Resolved conflict in TC001"
```

**When Git reports conflict in `.tcm-hashes.json`:**

```powershell
# This is normal when multiple developers sync simultaneously

# 1. Accept Git merge (usually auto-resolved)
git add .tcm-hashes.json

# 2. Re-sync to update hash tracking
Sync-TcmTestCase -Pull
Sync-TcmTestCase -Push

# 3. Commit updated hashes
git add .tcm-hashes.json
git commit -m "Updated sync hashes after merge"
```

### Git + Azure DevOps Synchronization

**Understanding the two layers:**

```
Local YAML Files (Git)
       ↕ (Sync-TcmTestCase)
Azure DevOps Work Items (API)
```

**Best practice workflow:**

1. **Git = Source of Truth** for file structure and version history
2. **Azure DevOps = Live Data** for active test execution and reporting
3. **Sync regularly** to keep both in sync

**Typical day:**

```powershell
# Morning: Get latest from team
git pull
Sync-TcmTestCase -Pull

# Work on test cases...
# Edit, create, modify YAML files

# Before lunch: Push your work
Sync-TcmTestCase -Push
git add .
git commit -m "Morning work: Updated smoke tests"
git push

# Afternoon: Continue...
git pull  # Get team's changes
Sync-TcmTestCase -Pull  # Get Azure DevOps updates
```

### Branch Workflows

**Feature branch workflow:**

```powershell
# Create feature branch
git checkout -b feature/new-api-tests

# Work on test cases
New-TcmTestCase -Id "TC100" -Title "API Authentication Test"
Sync-TcmTestCase -Id "TC100" -Push

# Commit to feature branch
git add TestCases/TC100-api-auth.yaml
git add .tcm-hashes.json
git commit -m "Add API authentication tests"
git push origin feature/new-api-tests

# Create pull request for review...
```

**After PR merge:**

```powershell
# Switch back to main
git checkout main
git pull

# Sync hashes (may show "remote-changes" for new test cases)
Sync-TcmTestCase -Pull

# Everything should be synced now
Get-TcmTestCase | Select-Object Id, SyncStatus
```

### Common Git Scenarios

**Scenario: Accidentally committed without pushing to Azure DevOps**

```powershell
# Your Git commit is ahead of Azure DevOps

# Fix: Push to Azure DevOps
Sync-TcmTestCase -Push

# Update hashes in Git
git add .tcm-hashes.json
git commit -m "Update sync hashes"
git push
```

**Scenario: Need to rollback test case to previous version**

```powershell
# Option 1: Git rollback (affects local YAML only)
git checkout HEAD~1 -- TestCases/TC001-login.yaml
Sync-TcmTestCase -Id "TC001" -Push -Force  # Overwrite Azure DevOps

# Option 2: Pull from Azure DevOps (if Azure DevOps has good version)
Sync-TcmTestCase -Id "TC001" -Pull -Force  # Overwrite local

# Commit whichever you chose
git add TestCases/TC001-login.yaml .tcm-hashes.json
git commit -m "Rolled back TC001 to previous version"
```

**Scenario: New team member onboarding**

```powershell
# 1. Clone repo
git clone https://your-repo.git
cd your-repo/TestCases

# 2. Set up credentials (see PAT creation guide)
$env:AZURE_DEVOPS_PAT = "new-team-member-pat"

# 3. Initial sync from Azure DevOps
Sync-TcmTestCase -Pull

# Now ready to work!
Get-TcmTestCase
```

### Integration with CI/CD

**Automated validation in pipeline:**

```yaml
# Example: Azure Pipelines YAML
steps:
- task: PowerShell@2
  displayName: 'Validate Test Cases'
  inputs:
    targetType: 'inline'
    script: |
      Import-Module AzureDevOpsApi

      # Check all YAML files are valid
      Get-TcmTestCase | ForEach-Object {
        if (-not $_.LocalData) {
          Write-Error "Invalid YAML: $($_.FilePath)"
          exit 1
        }
      }

      Write-Host "✅ All test cases are valid"

- task: PowerShell@2
  displayName: 'Sync to Azure DevOps'
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  env:
    AZURE_DEVOPS_PAT: $(AzureDevOpsPAT)  # Secure variable
  inputs:
    targetType: 'inline'
    script: |
      Import-Module AzureDevOpsApi
      Sync-TcmTestCase -Push -Verbose
```

### Best Practices Summary

✅ **DO:**
- Commit `.tcm-hashes.json` to enable team conflict detection
- Sync to Azure DevOps before committing to Git
- Pull from Git and Azure DevOps before starting work
- Use feature branches for major test case additions
- Document your test case changes in commit messages

❌ **DON'T:**
- Commit without syncing to Azure DevOps (creates drift)
- Manually edit `.tcm-hashes.json` (auto-generated file)
- Use `-Force` without understanding what you're overwriting
- Ignore Git merge conflicts in YAML files
- Share PAT tokens between team members

## Troubleshooting

For detailed troubleshooting help, see **[Troubleshooting Guide](./troubleshooting.md)**.

**Quick Diagnostics:**

```powershell
# Check PAT token
$env:AZURE_DEVOPS_PAT

# Verify config exists
Test-Path .\.tcm-config.yaml

# Enable verbose output
$VerbosePreference = 'Continue'
Get-TcmTestCase -Verbose
```

**Common Issues:**

- **401 Unauthorized**: PAT token missing or expired → Check `$env:AZURE_DEVOPS_PAT`
- **403 Forbidden**: PAT lacks "Work Items: Read & write" permission
- **Config not found**: No `.tcm-config.yaml` in current or parent directories
- **Invalid YAML**: Indentation errors (must use 2 spaces) or unquoted special characters
- **Sync conflicts**: Both local and remote changed → Use `-Force` with `-Push` or `-Pull`
- **Slow performance**: Syncing 1000+ test cases → Sync by folder or only changed files

See the [full troubleshooting guide](./troubleshooting.md) for detailed solutions and debugging steps.

## Related Documentation

- [TestCaseManagement Overview](../../test_case_management.md) - Quick reference guide
- [Function Reference](../../functions/AzureDevOpsApi.md) - Complete cmdlet documentation
- [Azure DevOps REST API](https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items) - Work item API reference
