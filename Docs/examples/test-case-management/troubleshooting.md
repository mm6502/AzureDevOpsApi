# Troubleshooting TestCaseManagement

This guide covers common issues and their solutions when working with the TestCaseManagement feature.

## Quick Diagnostics

Before diving into specific errors, try these quick checks:

```powershell
# Test your credentials (recommended - uses Test-ApiCredential)
Test-ApiCredential

# Or test a specific PAT token
Test-ApiCredential -Token "your-pat-token" -CollectionUri "https://dev.azure.com/myorg"

# Check if PAT token is set
$env:AZURE_DEVOPS_PAT

# Verify connectivity to Azure DevOps
Test-NetConnection -ComputerName dev.azure.com -Port 443

# Check if config exists
Test-Path .\.tcm-config.yaml

# Enable verbose output for any command
$VerbosePreference = 'Continue'
Get-TcmTestCase -Verbose
```

---

## Authentication Errors

### Error: "401 Unauthorized"

**Symptoms:**
```
Invoke-RestMethod: The remote server returned an error: (401) Unauthorized.
```

**Common Causes:**
1. PAT token is missing or not set
2. PAT token has expired
3. PAT token is invalid or malformed
4. Environment variable not loaded

**Solutions:**

**1. Verify token is set:**
```powershell
# Check if token exists
if ([string]::IsNullOrEmpty($env:AZURE_DEVOPS_PAT)) {
    Write-Host "❌ PAT token not set" -ForegroundColor Red
} else {
    Write-Host "✅ PAT token is set (length: $($env:AZURE_DEVOPS_PAT.Length))" -ForegroundColor Green
}
```

**2. Test token manually:**

```powershell
# Use the built-in Test-ApiCredential function (recommended)
$result = Test-ApiCredential -Token $env:AZURE_DEVOPS_PAT -CollectionUri "https://dev.azure.com/YOUR-ORG"

if ($result.Success) {
    Write-Host "✅ Token is valid" -ForegroundColor Green
    Write-Host "   Connected as: $($result.User.displayName)" -ForegroundColor Green
} else {
    Write-Host "❌ Token test failed: $($result.ErrorMessage)" -ForegroundColor Red
    Write-Host "   Status code: $($result.StatusCode)" -ForegroundColor Red
}
```

**3. Check token expiration in Azure DevOps:**
1. Go to Azure DevOps → Click profile icon → Personal access tokens
2. Find your token in the list
3. Check "Expires" column
4. If expired, create a new token

**4. Regenerate token:**
```powershell
# After creating new token in Azure DevOps:
$env:AZURE_DEVOPS_PAT = "your-new-token-here"

# Make it persistent (user scope):
[Environment]::SetEnvironmentVariable(
    "AZURE_DEVOPS_PAT",
    "your-new-token-here",
    [EnvironmentVariableTarget]::User
)

# Restart PowerShell and verify
$env:AZURE_DEVOPS_PAT
```

---

### Error: "403 Forbidden"

**Symptoms:**
```
Invoke-RestMethod: The remote server returned an error: (403) Forbidden.
```

**Cause:** PAT token doesn't have required permissions

**Solution:**

**1. Verify required permissions:**
- Minimum: **Work Items: Read & write** ✅

**2. Edit token permissions:**
1. Go to Azure DevOps → Profile icon → Personal access tokens
2. Find your token and click **Edit** (or **...** menu → Edit)
3. Expand **Work Items** section
4. Check **Read & write** ✅
5. Click **Save**
6. **No need to regenerate** - changes apply immediately

**3. Test again:**
```powershell
# Try your operation again
Get-TcmTestCase
```

**Note:** If editing permissions doesn't work, create a new token with correct permissions.

---

## Configuration Errors

### Error: "Configuration file not found"

**Symptoms:**
```
Exception: No .tcm-config.yaml file found in current directory or parent directories
```

**Cause:** No `.tcm-config.yaml` file exists in the current directory or any parent directory

**Solutions:**

**1. Check if config exists:**
```powershell
# Search current directory and parents
$dir = Get-Location
while ($dir) {
    $configPath = Join-Path $dir ".tcm-config.yaml"
    if (Test-Path $configPath) {
        Write-Host "✅ Found: $configPath" -ForegroundColor Green
        Get-Content $configPath
        break
    }
    $dir = Split-Path $dir -Parent
}
```

**2. Create configuration:**
```powershell
# Navigate to your test cases root
cd C:\MyProject\TestCases

# Create config
New-TcmConfig -CollectionUri "https://dev.azure.com/myorg" -Project "MyProject"

# Verify
Get-Content .\.tcm-config.yaml
```

**3. Specify config explicitly (if in different location):**
```powershell
# Not directly supported - config must be in TestCasesRoot or parent
# Move your working directory to where config exists
cd C:\MyProject\TestCases
Get-TcmTestCase
```

---

### Error: "Invalid YAML syntax"

**Symptoms:**
```
Exception: Error parsing YAML file: ...
ConvertFrom-Yaml: ...
```

**Common Causes:**
1. Incorrect indentation (must use 2 spaces, no tabs)
2. Missing quotes around special characters
3. Malformed YAML structure
4. Invalid data types

**Solutions:**

**1. Validate YAML online:**
- Copy file contents
- Go to https://www.yamllint.com/
- Paste and check for errors

**2. Common YAML mistakes:**

```yaml
# ❌ Wrong: Tabs used for indentation
testCase:
	title: My Test

# ✅ Correct: 2 spaces
testCase:
  title: My Test

# ❌ Wrong: Special characters unquoted
testCase:
  title: Test: Login & Logout

# ✅ Correct: Quote strings with special chars
testCase:
  title: "Test: Login & Logout"

# ❌ Wrong: Inconsistent indentation
testCase:
  steps:
  - action: Click
    expected: Page loads
   - action: Verify  # Wrong indentation

# ✅ Correct: Consistent 2-space indentation
testCase:
  steps:
  - action: Click
    expected: Page loads
  - action: Verify
```

**3. Check specific file:**
```powershell
# Read and validate YAML
$yamlPath = "TestCases/TC001-login.yaml"
try {
    $content = Get-Content $yamlPath -Raw
    $parsed = ConvertFrom-Yaml $content
    Write-Host "✅ Valid YAML" -ForegroundColor Green
    $parsed | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ Invalid YAML: $($_.Exception.Message)" -ForegroundColor Red
}
```

**4. Regenerate file:**
```powershell
# If file is corrupted, recreate it
Remove-Item "TestCases/TC001-login.yaml"
New-TcmTestCase -Id "TC001" -Title "Login Test"
```

---

## Sync Errors

### Error: "Conflict detected"

**Symptoms:**
```
WARNING: Conflict detected for TC001: Both local and remote have changes
SyncStatus: conflict
```

**Cause:** Both local YAML file and Azure DevOps work item have been modified

**Solutions:**

**1. View conflict details:**
```powershell
# Get test case with sync status
$tc = Get-TcmTestCase -Id "TC001"

# Check what changed
$tc | Select-Object Id, SyncStatus, LocalHash, RemoteHash

# View local data
$tc.LocalData.testCase

# View remote data
$tc.RemoteData.fields
```

**2. Choose conflict resolution strategy:**

**Strategy A: Force push (keep local):**
```powershell
Sync-TcmTestCase -Id "TC001" -Push -Force
```

**Strategy B: Force pull (keep remote):**
```powershell
Sync-TcmTestCase -Id "TC001" -Pull -Force
```

**Strategy C: Manual resolution:**
```powershell
# 1. Edit local file manually
code TestCases/TC001-login.yaml

# 2. Merge changes from remote if needed
$tc = Get-TcmTestCase -Id "TC001"
$tc.RemoteData.fields | Format-List

# 3. Push merged version
Sync-TcmTestCase -Id "TC001" -Push -Force
```

**See also:** `05-conflict-resolution.md` for detailed strategies

---

### Error: "Network timeout during sync"

**Symptoms:**
```
Exception: The operation has timed out.
```

**Common Causes:**
1. Large files
2. Slow network connection
3. Syncing too many files at once
4. Azure DevOps service issues

**Solutions:**

**1. Sync in smaller batches:**
```powershell
# Instead of syncing all at once
Get-TcmTestCase | Sync-TcmTestCase -Push  # Can timeout

# Sync by folder
Get-TcmTestCase -Path "TestCases/Sprint01/*.yaml" | Sync-TcmTestCase -Push
Get-TcmTestCase -Path "TestCases/Sprint02/*.yaml" | Sync-TcmTestCase -Push

# Or sync one at a time with progress
$testCases = Get-TcmTestCase
$total = $testCases.Count
$current = 0

foreach ($tc in $testCases) {
    $current++
    Write-Progress -Activity "Syncing test cases" -Status "$current of $total" -PercentComplete (($current / $total) * 100)
    $tc | Sync-TcmTestCase -Push
}
```

**2. Use verbose mode to monitor progress:**
```powershell
$VerbosePreference = 'Continue'
Get-TcmTestCase | Sync-TcmTestCase -Push -Verbose
```

**3. Check network connectivity:**
```powershell
# Test connection
Test-NetConnection -ComputerName dev.azure.com -Port 443

# Check if proxy is causing issues
[System.Net.WebRequest]::DefaultWebProxy
```

**4. Check Azure DevOps status:**
- Visit: https://status.dev.azure.com/
- Check for ongoing incidents

---

## Data Corruption

### Error: "Corrupted .tcm-hashes.json"

**Symptoms:**
```
Exception: Invalid JSON in .tcm-hashes.json
ConvertFrom-Json: ...
```

**Cause:** Hash file was manually edited, sync interrupted, or file system error

**Solutions:**

**1. Backup current hash file:**
```powershell
Copy-Item .\.tcm-hashes.json .\.tcm-hashes.json.backup
```

**2. Delete corrupted file:**
```powershell
Remove-Item .\.tcm-hashes.json
```

**3. Rebuild hashes from remote:**
```powershell
# Pull from Azure DevOps to rebuild hashes
Sync-TcmTestCase -Pull

# This will recreate .tcm-hashes.json with correct data
```

**4. Verify rebuild:**
```powershell
# Check hash file exists and is valid JSON
if (Test-Path .\.tcm-hashes.json) {
    $hashes = Get-Content .\.tcm-hashes.json | ConvertFrom-Json
    Write-Host "✅ Hash file rebuilt with $($hashes.PSObject.Properties.Count) entries" -ForegroundColor Green
}
```

**Prevention:**
- Never manually edit `.tcm-hashes.json`
- Add to `.gitignore` (file is auto-generated)
- Don't interrupt sync operations

---

### Error: "Test case YAML file corrupted"

**Symptoms:**
```
Unable to parse YAML file
Invalid data in test case file
```

**Solutions:**

**1. Restore from Azure DevOps:**
```powershell
# Delete local file
Remove-Item TestCases/TC001-login.yaml

# Pull from remote
Sync-TcmTestCase -Id "TC001" -Pull

# This downloads fresh copy from Azure DevOps
```

**2. Restore from git (if using version control):**
```powershell
# Check file history
git log -- TestCases/TC001-login.yaml

# Restore from previous commit
git checkout HEAD~1 -- TestCases/TC001-login.yaml
```

**3. Recreate manually:**
```powershell
# If no backup exists, get data from Azure DevOps
$workItem = Get-WorkItem -Id 12345 -CollectionUri "https://dev.azure.com/myorg" -Project "MyProject"

# Create new file
New-TcmTestCase -Id "TC001" -Title $workItem.fields["System.Title"]

# Edit and add details manually
code TestCases/TC001-login.yaml
```

---

## Performance Issues

### Issue: "Slow sync with 1000+ test cases"

**Symptoms:**
- Sync operations take many minutes
- High memory usage
- PowerShell becomes unresponsive

**Solutions:**

**1. Sync only what changed:**
```powershell
# Instead of syncing everything
Get-TcmTestCase | Sync-TcmTestCase -Push

# Sync only files with local changes
Get-TcmTestCase | Where-Object { $_.SyncStatus -eq "local-changes" } | Sync-TcmTestCase -Push

# Sync only files with remote changes
Get-TcmTestCase | Where-Object { $_.SyncStatus -eq "remote-changes" } | Sync-TcmTestCase -Pull
```

**2. Use folder-based sync:**
```powershell
# Sync specific folders instead of all
Get-TcmTestCase -Path "TestCases/Sprint-Current/*.yaml" | Sync-TcmTestCase -Push
```

**3. Exclude archived folders in config:**
```yaml
# .tcm-config.yaml
sync:
  excludePatterns:
    - "**/Archive/**"
    - "**/Old/**"
    - "**/*.backup.yaml"
```

**4. Process in batches with progress:**
```powershell
$batchSize = 50
$testCases = Get-TcmTestCase | Where-Object { $_.SyncStatus -ne "synced" }
$batches = [Math]::Ceiling($testCases.Count / $batchSize)

for ($i = 0; $i -lt $batches; $i++) {
    $batch = $testCases | Select-Object -Skip ($i * $batchSize) -First $batchSize
    Write-Host "Processing batch $($i + 1) of $batches..." -ForegroundColor Cyan
    $batch | Sync-TcmTestCase -Push
    Start-Sleep -Seconds 2  # Brief pause between batches
}
```

**5. Consider parallel processing (advanced):**
```powershell
# Use PowerShell jobs for large operations
$testCases = Get-TcmTestCase
$testCases | ForEach-Object -Parallel {
    Import-Module AzureDevOpsApi
    $_ | Sync-TcmTestCase -Push
} -ThrottleLimit 5
```

---

## Debug Mode

### Enable detailed logging

```powershell
# Enable verbose output
$VerbosePreference = 'Continue'

# Enable debug output (very detailed)
$DebugPreference = 'Continue'

# Run commands
Get-TcmTestCase -Verbose -Debug
Sync-TcmTestCase -Push -Verbose -Debug

# Reset to normal
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'
```

### Use -WhatIf for testing

```powershell
# Preview what would happen without actually doing it
Sync-TcmTestCase -Push -WhatIf

# Shows what would be synced without making changes
```

### Inspect objects directly

```powershell
# Get detailed object information
$tc = Get-TcmTestCase -Id "TC001"
$tc | Format-List *
$tc | ConvertTo-Json -Depth 10

# Check specific properties
$tc.LocalData | ConvertTo-Json -Depth 10
$tc.RemoteData | ConvertTo-Json -Depth 10
$tc.SyncStatus
```

---

## Common Scenarios

### "I can't find my test cases"

**Check:**
1. Are you in the right directory?
2. Does config exist in current or parent directory?
3. Are YAML files where you expect them?

```powershell
# Find config
Get-ChildItem -Recurse -Filter ".tcm-config.yaml"

# Find all YAML test case files
Get-ChildItem -Recurse -Filter "*.yaml" | Where-Object { $_.Directory.Name -ne ".git" }

# Check what Get-TcmTestCase sees
Get-TcmTestCase | Select-Object Id, FilePath, SyncStatus
```

### "Sync says everything is up to date but I know there are changes"

**Possible causes:**
1. Hash file out of sync
2. File modified but not saved
3. Looking at different environment

```powershell
# Force recalculate hashes
Remove-Item .\.tcm-hashes.json
Sync-TcmTestCase -Pull  # Rebuilds hashes

# Verify file timestamps
Get-ChildItem TestCases/*.yaml | Select-Object Name, LastWriteTime | Sort-Object LastWriteTime -Descending

# Check sync status
Get-TcmTestCase | Select-Object Id, SyncStatus, LocalHash, RemoteHash
```

### "How do I completely reset and start fresh?"

**⚠️ Warning: This deletes local changes!**

```powershell
# 1. Backup your work first!
$backupPath = "C:\Backup\TestCases_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -Path TestCases -Destination $backupPath -Recurse
Write-Host "✅ Backup created at: $backupPath" -ForegroundColor Green

# 2. Delete local files (except config)
Get-ChildItem TestCases/*.yaml | Remove-Item

# 3. Delete hash file
Remove-Item .\.tcm-hashes.json -ErrorAction SilentlyContinue

# 4. Pull fresh from Azure DevOps
Sync-TcmTestCase -Pull

# 5. Verify
Get-TcmTestCase | Select-Object Id, SyncStatus
```

---

## Getting Help

### Before asking for help, collect this information:

```powershell
# 1. Module version
Get-Module AzureDevOpsApi | Select-Object Name, Version

# 2. PowerShell version
$PSVersionTable

# 3. Config content (hide PAT!)
$config = Get-Content .\.tcm-config.yaml | ConvertFrom-Yaml
$config.azureDevOps.pat = "***HIDDEN***"
$config | ConvertTo-Json

# 4. Error details
# Copy the full error message including stack trace

# 5. What you tried
# List the commands you ran
```

### Resources

- **Module Documentation:** `Docs/test_case_management.md`
- **Examples:** `Docs/examples/test-case-management/`
- **Function Reference:** `Docs/functions/`
- **PAT Setup:** `Docs/examples/credentials/00-creating-pat-token.md`
- **GitHub Issues:** [Repository URL]/issues

---

## Quick Reference

| Problem | Quick Fix |
|---------|-----------|
| 401 Unauthorized | Check `$env:AZURE_DEVOPS_PAT` is set and valid |
| 403 Forbidden | Verify PAT has "Work Items: Read & write" |
| Config not found | Run `New-TcmConfig` in test cases root |
| Invalid YAML | Check indentation (2 spaces), quote special chars |
| Conflicts | Use `-Force` with `-Push` or `-Pull` |
| Slow sync | Sync only changed files or specific folders |
| Corrupted hashes | Delete `.tcm-hashes.json` and run `Sync -Pull` |

---

**Still stuck?** Enable verbose mode and check the detailed output:
```powershell
$VerbosePreference = 'Continue'
Your-Command -Verbose
```
