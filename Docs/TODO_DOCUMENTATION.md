# TCM Documentation - Quick Action Checklist

**Start Date:** October 16, 2025
**Target:** Fix critical issues blocking new developers

---

## 🔥 CRITICAL - Do These First (6-8 hours)

### [ ] 1. Fix Quick Start Parameter (15 min)
**File:** `Docs/test_case_management.md`
**Line:** ~18-20
**Change:**
```diff
- New-TcmConfig -TestCasesRoot "C:\MyProject\TestCases" `
+ New-TcmConfig -OutputPath "C:\MyProject\TestCases" `
               -CollectionUri "https://dev.azure.com/myorg" `
               -Project "MyProject"
```

### [ ] 2. Fix Data Model Examples (2 hours)
**Find/Replace across all docs:**
- `$_.testCase.state` → `$_.LocalData.testCase.state`
- `$_.testCase.title` → `$_.LocalData.testCase.title`

**Add to `test_case_management.md` after Quick Start:**
```markdown
## Object Structure

Test cases returned by Get-TcmTestCase have this structure:
- `$tc.LocalData.testCase.*` - Local YAML properties
- `$tc.RemoteData.fields.*` - Azure DevOps fields
- `$tc.SyncStatus` - Sync state

Example:
```powershell
$tc = Get-TcmTestCase -Id "TC001"
$tc.LocalData.testCase.title    # "Login Test"
$tc.LocalData.testCase.state    # "Design"
$tc.SyncStatus                   # "synced"
```
```

### [ ] 3. Clarify Sync Functions (1 hour)
**Add to `test_case_management.md` before "Core Functions":**
```markdown
## Sync Commands

**Simple (Recommended):**
- `Sync-TcmTestCase -Push` - Send local changes to Azure DevOps
- `Sync-TcmTestCase -Pull` - Get remote changes
- `Sync-TcmTestCase -Push -Force` - Overwrite conflicts

**Advanced:** Use `-Direction Bidirectional|ToRemote|FromRemote` for explicit control
```

### [ ] 4. Fix "Future Feature" Example (15 min)
**File:** `Docs/examples/test-case-management/05-conflict-resolution.md`
**Line:** ~91-96
**Change:**
```diff
- ### Strategy 4: Interactive Resolution (Future Feature)
+ ### Strategy 4: Interactive Resolution (⚠️ Not Yet Implemented)

- ```powershell
- # This feature is planned but not yet implemented
- Resolve-TcmTestCaseConflict -Id "TC001" -Interactive
- ```
+ > **Note:** Interactive conflict resolution is planned for a future release.
+ > Currently use Strategy 3 (manual resolution) or force push/pull.
```

### [ ] 5. Document Function Visibility (2-4 hours)

**Decision Point:** Choose Option A or B

**Option A: Export Private Functions** (Recommended if useful for users)
1. Add to `AzureDevOpsApi.psd1`:
   ```powershell
   FunctionsToExport = @(
       # ... existing ...
       'Resolve-TcmTestCaseFilePathInput',
       'Save-TcmTestCaseYaml'
   )
   ```
2. Run: `.\utils\run.generate.docs.ps1`
3. Add help documentation to those functions

**Option B: Remove from Examples**
1. Find all usages of `Resolve-TcmTestCaseFilePathInput`
2. Replace with direct file path passing
3. Replace `Save-TcmTestCaseYaml` with manual file editing instructions

---

## ⚠️ HIGH PRIORITY - Do Next (6-8 hours)

### [ ] 6. Add PAT Creation Guide (45 min)
**File:** `Docs/examples/test-case-management/01-setup-configuration.md`
**Insert after line ~12 ("Prerequisites" section):**

```markdown
### Creating a Personal Access Token

1. Go to Azure DevOps → Profile (top right) → Personal access tokens
2. Click "+ New Token"
3. Set:
   - Name: `TestCaseManagement`
   - Expiration: 90 days
   - Scopes: **Work Items** → Read & write ✅
4. Click "Create" and copy the token immediately
5. Set environment variable:
   ```powershell
   $env:AZURE_DEVOPS_PAT = "your-token-here"
   ```

**Never commit PAT tokens to version control!**
```

### [ ] 7. Create Troubleshooting Guide (2 hours)
**New File:** `Docs/examples/test-case-management/troubleshooting.md`

**Template:** (See IMPROVEMENT_PLAN.md Issue #6 for full content)

**Cover:**
- 401/403 authentication errors
- Configuration not found
- Invalid YAML syntax
- Conflict errors
- Network timeouts
- Corrupted .tcm-hashes.json
- Debug mode usage

**Link from readme.md**

### [ ] 8. Add Git Integration Guide (1.5 hours)
**File:** `Docs/examples/test-case-management/readme.md`
**Add new section:**

```markdown
## Version Control Integration

### What to Commit
✅ Commit: `.tcm-config.yaml`, `*.yaml` test cases
❌ Never: `.tcm-hashes.json`, PAT tokens

### .gitignore
```
.tcm-hashes.json
*.tmp
*.bak
```

### Team Workflow
1. Create test case locally
2. Commit to git: `git commit -am "Add TC001"`
3. Push to Azure DevOps: `Sync-TcmTestCase -Push`
4. Push to git: `git push`

See [Conflict Resolution](./05-conflict-resolution.md) for handling conflicts.
```

### [ ] 9. Create Team Workflow Example (2 hours)
**New File:** `Docs/examples/test-case-management/07-team-workflow.md`

**Content:**
- Multi-developer scenario
- Git + Azure DevOps integration
- Conflict handling
- Best practices

---

## 📝 MEDIUM PRIORITY - Do Later (4-6 hours)

### [ ] 10. Custom Fields (1 hour)
Add to `06-advanced-scenarios.md` - how to discover custom fields

### [ ] 11. Performance Guide (1 hour)
Add to `06-advanced-scenarios.md` - batch processing, progress monitoring

### [ ] 12. Standardize Formatting (1.5 hours)
Ensure all PowerShell = 4 spaces, YAML = 2 spaces

---

## ✅ Validation After Each Fix

- [ ] Run the code example manually
- [ ] Test with fresh environment
- [ ] Check for typos
- [ ] Verify links work
- [ ] Run: `.\utils\run.generate.docs.ps1`
- [ ] Git commit with clear message

---

## 📊 Progress Tracking

| Issue | Status | Time Spent | Validated |
|-------|--------|------------|-----------|
| #1 Parameter name | ✅ Done | 0.25h | ✅ |
| #2 Function visibility | ✅ Done | 3h | ✅ |
| #3 Sync functions | ✅ Done | 0.5h | ✅ |
| #4 Data model | ⬜ Todo | 0h | ⬜ |
| #7 Future features | 🔄 In Progress | 0h | ⬜ |
| #5 PAT guide | ⬜ Todo | 0h | ⬜ |
| #6 Troubleshooting | ⬜ Todo | 0h | ⬜ |
| #8 Git integration | ⬜ Todo | 0h | ⬜ |
| #9 Team workflow | ⬜ Todo | 0h | ⬜ |

**Legend:** ⬜ Todo | 🔄 In Progress | ✅ Done | ❌ Blocked

---

## 🎯 Success Check

After completing Critical fixes:
- [ ] Quick start works perfectly (no errors)
- [ ] All property paths are correct
- [ ] Function relationships are clear
- [ ] No "future feature" confusion

After completing High Priority:
- [ ] New developer can get PAT easily
- [ ] Troubleshooting guide exists
- [ ] Git workflow is documented
- [ ] Team collaboration is clear

---

## 📞 Need Help?

- Full details: `IMPROVEMENT_PLAN.md`
- Quick summary: `IMPROVEMENT_PLAN_SUMMARY.md`
- Documentation review: Chat history

