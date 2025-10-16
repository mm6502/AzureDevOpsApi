# TestCaseManagement Documentation Improvement Plan

**Date:** October 16, 2025
**Branch:** tcm
**Priority:** High - Blocking new developer onboarding

---

## Executive Summary

This plan addresses critical documentation gaps identified during a comprehensive review from a new developer's perspective. The improvements focus on removing blockers, clarifying confusion points, and enhancing the onboarding experience.

**Current Score:** 7.5/10
**Target Score:** 9.5/10

---

## Critical Issues (Must Fix Before Release)

### 1. ~~Fix Quick Start Example Parameter Name~~ ✅ FIXED
**File:** `Docs/test_case_management.md`
**Issue:** ~~Quick start uses non-existent `-TestCasesRoot` parameter~~
**Resolution:** Added `-TestCasesRoot` as an alias to `-OutputPath` parameter in `New-TcmConfig`
**Impact:** None - documentation now matches function signature
**Priority:** ~~P0 - Blocking~~ **RESOLVED**

**Status:** ✅ **COMPLETED** - Alias added to function, documentation is now correct

---

### 2. ~~Rewrite Examples to Use Only Public Functions~~ ✅ COMPLETED
**Issue:** ~~Examples use private/internal functions that users cannot access~~
**Impact:** ~~Users get "command not found" errors when copy-pasting examples~~
**Priority:** ~~P0 - Blocking~~ **RESOLVED**
**Decision:** Kept private functions internal, rewrote all documentation examples
**Completion Date:** October 16, 2025

**Private Functions Currently Used in Examples:**
- `Resolve-TcmTestCaseFilePathInput` - used extensively in examples
- `Save-TcmTestCaseYaml` - used in advanced scenarios
- `Get-TcmTestCaseConfig` - used in advanced scenarios
- `Sync-TcmTestCaseToRemote` / `Sync-TcmTestCaseFromRemote` - internal helpers

**Actions Required:**

**Step 1: Identify All Usages** ✅
- [x] Search for `Resolve-TcmTestCaseFilePathInput` in all `Docs/**/*.md` files
- [x] Search for `Save-TcmTestCaseYaml` in all `Docs/**/*.md` files
- [x] Search for `Sync-TcmTestCaseToRemote` in all `Docs/**/*.md` files
- [x] Search for `Sync-TcmTestCaseFromRemote` in all `Docs/**/*.md` files
- [x] Search for `Get-TcmTestCaseConfig` in all `Docs/**/*.md` files

**Step 2: Rewrite Examples** ✅
- [ ] Replace pipeline patterns using `Resolve-TcmTestCaseFilePathInput`:
  ```powershell
  # OLD (uses private function):
  Get-ChildItem "*.yaml" | Resolve-TcmTestCaseFilePathInput | Sync-TcmTestCase -Push

  # NEW Pattern 1: Simplest - sync all test cases (RECOMMENDED)
  Sync-TcmTestCase -Push

  # NEW Pattern 2: Specific test case by ID
  Sync-TcmTestCase -InputObject "TC001" -Push

  # NEW Pattern 3: Multiple specific test cases
  Get-TcmTestCase -Id "TC001", "TC002", "TC003" | Sync-TcmTestCase -Push

  # NEW Pattern 4: Filter by file path pattern
  Get-ChildItem "TestCases/Sprint-10/*.yaml" | Sync-TcmTestCase -Push
  ```

  **Important Notes:**
  - `Get-TcmTestCase -Id` does NOT support wildcards (no `-Id "TC*"`)
  - For filtering, use either:
    - Multiple specific IDs: `-Id "TC001", "TC002"`
    - File path filtering: `Get-ChildItem "path/*.yaml" | Sync-TcmTestCase -Push`
  - File discovery automatically excludes `.tcm-config.yaml` and `.tcm-hashes.json`

  **Future Enhancement:** Consider improving `Get-TcmTestCaseConfig` to search parent directories
  for `.tcm-config.yaml` (similar to git's `.git` lookup), allowing subdirectory operations without
  requiring config in each subdirectory.

- [ ] Replace `Save-TcmTestCaseYaml` with manual editing instructions:
  ```powershell
  # OLD (uses private function):
  $testCase | Save-TcmTestCaseYaml -FilePath "TC001.yaml"

  # NEW (public approach):
  # Edit the YAML file directly in your editor, then sync
  # Or use Get-TcmTestCase to read, modify properties, save manually
  ```

- [ ] Replace `Sync-TcmTestCaseToRemote`/`FromRemote` with `Sync-TcmTestCase`:
  ```powershell
  # OLD (uses private function):
  Sync-TcmTestCaseToRemote -InputObject "TC001"

  # NEW (public function):
  Sync-TcmTestCase -InputObject "TC001" -Push
  ```

**Step 3: Update Files** ✅
- [x] `Docs/examples/test-case-management/03-folder-organization.md`
- [x] `Docs/examples/test-case-management/04-sync-workflows.md`
- [x] `Docs/examples/test-case-management/05-conflict-resolution.md`
- [x] `Docs/examples/test-case-management/06-advanced-scenarios.md`
- [x] Deleted auto-generated docs for private functions:
  - `Docs/functions/Sync-TcmTestCaseToRemote.md`
  - `Docs/functions/Sync-TcmTestCaseFromRemote.md`
- [x] Updated `Docs/functions/AzureDevOpsApi.md` index

**Step 4: Add Documentation Note**
- [ ] Add note in `test_case_management.md` explaining internal vs public functions (deferred)
- [ ] Add to "Common Patterns" section explaining the recommended public API (deferred)

**Time Spent:** ~3 hours (completed ahead of schedule)

---

### 3. ~~Document Sync Function Relationships~~ ✅ COMPLETED
**Issue:** ~~Multiple sync functions with unclear relationships~~
**Impact:** ~~Confusion about which function to use~~
**Priority:** ~~P0 - Blocking~~ **RESOLVED**
**Completion Date:** October 16, 2025

**Current Situation:**
- `Sync-TcmTestCase` with `-Push`, `-Pull`, `-Force` parameters (GitStyle)
- `Sync-TcmTestCase` with `-Direction` parameter (Explicit)
- Documentation now uses only `Sync-TcmTestCase` (Issue #2 completed)
- Need to clarify the two parameter set approaches

**Actions Completed:**
- [x] Added "Understanding Sync Operations" section to `test_case_management.md`
- [x] Created comparison showing GitStyle vs Explicit parameter sets
- [x] Added parameter sets documentation to `Sync-TcmTestCase.md`
- [x] Documented when to use each approach in `04-sync-workflows.md`

**New Section Template:**
```markdown
## Understanding Sync Operations

`Sync-TcmTestCase` supports two styles of operation:

### GitStyle Parameters (Recommended)
- **`-Push`** - Send local changes to Azure DevOps
- **`-Pull`** - Get remote changes from Azure DevOps
- **`-Force`** - Overwrite conflicts (use with Push or Pull)

### Explicit Direction Parameter
- **`-Direction ToRemote`** - Equivalent to `-Push`
- **`-Direction FromRemote`** - Equivalent to `-Pull`
- **`-Direction Bidirectional`** - Sync both ways (advanced)

**When to use each:**
- **GitStyle**: Intuitive for Git users, recommended for most scenarios
- **Explicit**: Better for automation scripts where direction is calculated dynamically

**Examples:**
\```powershell
# GitStyle (recommended)
Sync-TcmTestCase -Push
Sync-TcmTestCase -Pull -Force

# Explicit
Sync-TcmTestCase -Direction ToRemote
$direction = if ($localNewer) { "ToRemote" } else { "FromRemote" }
Sync-TcmTestCase -Direction $direction
\```
```

**Files Updated:**
- [x] `Docs/test_case_management.md` - Added "Understanding Sync Operations" section
- [x] `Docs/functions/Sync-TcmTestCase.md` - Added parameter sets explanation
- [x] `Docs/examples/test-case-management/04-sync-workflows.md` - Added syntax comparison

**Time Spent:** ~30 minutes (completed faster than estimated)

---

### 4. ~~Fix Data Model Property References~~ ✅ COMPLETED
**Issue:** ~~Examples show inconsistent property access patterns~~
**Impact:** ~~Users don't know how to access test case data~~
**Priority:** ~~P0 - Blocking~~ **RESOLVED**
**Completion Date:** October 16, 2025
**Time Spent:** ~30 minutes

**Inconsistencies Found:**
- `Get-TcmTestCase.md` shows: `$_.testCase.state`
- `test_case_management.md` shows: `$_.LocalData.state`
- Code implementation uses: `$_.LocalData` for YAML data

**Completed Actions:** ✅
- [x] Document the complete object structure
- [x] Fix all examples to use consistent property paths
- [x] Add "Object Structure Reference" section

**What Was Done:**
- Added comprehensive "Object Structure" section to `test_case_management.md` (~60 lines)
- Fixed `Get-TcmTestCase.md` EXAMPLE 3: `$_.testCase.state` → `$_.LocalData.testCase.state`
- Fixed `test_case_management.md` Quick Start example
- Fixed `readme.md` common patterns section
- Verified all corrections with grep searches - ALL CLEAN ✅

**New Section - Object Structure Reference:**
```markdown
## Test Case Object Structure

Objects returned by `Get-TcmTestCase` have this structure:

```powershell
[PSCustomObject]@{
    PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended'

    # Input identification
    Id = "TC001"                    # Test case ID
    Path = "path/to/TC001.yaml"     # File path

    # Local YAML data (always present if file exists)
    LocalData = @{
        testCase = @{
            id = "TC001"
            title = "Test Title"
            state = "Design"
            priority = 2
            steps = @(...)
            # ... all YAML properties
        }
    }

    # Remote Azure DevOps data (present if synced)
    RemoteData = @{
        id = 12345
        fields = @{
            "System.Title" = "Test Title"
            "System.State" = "Design"
            # ... all work item fields
        }
    }

    # Sync information (when -IncludeSyncStatus used)
    SyncStatus = "synced|local-changes|remote-changes|conflict|new-local|new-remote"
    LocalHash = "abc123..."
    RemoteHash = "abc123..."
}
```

**Accessing Properties:**
```powershell
# Local YAML data
$tc.LocalData.testCase.title
$tc.LocalData.testCase.state
$tc.LocalData.testCase.steps

# Remote work item data (if synced)
$tc.RemoteData.fields["System.Title"]
$tc.RemoteData.fields["System.State"]

# Sync status
$tc.SyncStatus
```
```

**Files to Update:**
- [ ] `Docs/test_case_management.md` - Add object structure section
- [ ] `Docs/functions/Get-TcmTestCase.md` - Fix examples
- [ ] `Docs/examples/test-case-management/02-creating-test-cases.md` - Update examples
- [ ] All other examples using property access

**Estimated Time:** 2 hours

---

## High Priority Issues

### 5. Add PAT Creation Guide
**File:** `Docs/examples/test-case-management/01-setup-configuration.md`
**Issue:** Assumes users know how to create PAT tokens
**Priority:** P1 - New developer blocker

**Actions Required:**
- [ ] Add "Creating a Personal Access Token" subsection
- [ ] Include screenshots or detailed steps
- [ ] Document required permissions (Work Items: Read & Write)
- [ ] Add token security best practices

**New Section Template:**
```markdown
### Creating a Personal Access Token (PAT)

If you don't have a PAT token yet, follow these steps:

1. **Navigate to Azure DevOps** → Click your profile icon (top right) → **Personal access tokens**
2. **Click "+ New Token"**
3. **Configure the token:**
   - Name: `TestCaseManagement` (or your preference)
   - Organization: Select your organization
   - Expiration: Choose duration (90 days recommended)
   - Scopes: Select **Custom defined**
   - Under **Work Items**, check: ✅ Read & write
4. **Click "Create"** and **copy the token immediately** (you won't see it again)
5. **Store securely** in password manager or environment variable

**Required Permissions:**
- ✅ Work Items: Read & Write (required)
- ✅ Project and Team: Read (optional, for validation)

**Security Best Practices:**
- Use environment variables: `$env:AZURE_DEVOPS_PAT = "your-token"`
- Never commit tokens to git
- Set reasonable expiration dates
- Rotate tokens regularly
- Use Azure Key Vault for production scenarios
```

**Estimated Time:** 45 minutes

---

### 6. Add Comprehensive Troubleshooting Section
**File:** New file `Docs/examples/test-case-management/troubleshooting.md`
**Issue:** No central troubleshooting guide
**Priority:** P1 - User frustration

**Actions Required:**
- [ ] Create new troubleshooting document
- [ ] Cover common errors and solutions
- [ ] Include network/connectivity issues
- [ ] Add debugging techniques

**Section Outline:**
```markdown
# Troubleshooting TestCaseManagement

## Authentication Errors

### Error: "401 Unauthorized"
**Cause:** Invalid or expired PAT token
**Solution:**
1. Verify token: `Test-Connection -ComputerName dev.azure.com`
2. Check expiration in Azure DevOps
3. Regenerate token if expired
4. Update `$env:AZURE_DEVOPS_PAT`

### Error: "403 Forbidden"
**Cause:** Insufficient permissions
**Solution:** Ensure PAT has "Work Items: Read & Write"

## Configuration Errors

### Error: "Configuration file not found"
**Cause:** No `.tcm-config.yaml` in directory hierarchy
**Solution:** Run `New-TcmConfig` in your test cases root

### Error: "Invalid YAML syntax"
**Cause:** Malformed YAML file
**Solution:**
1. Use YAML validator: https://www.yamllint.com/
2. Check indentation (2 spaces, no tabs)
3. Quote strings with special characters

## Sync Errors

### Error: "Conflict detected"
**Cause:** Both local and remote modified
**Solution:** Use conflict resolution strategies (see 05-conflict-resolution.md)

### Network timeout during sync
**Cause:** Large files or slow connection
**Solution:**
- Use `-Verbose` to see progress
- Sync smaller batches
- Check network connectivity

## Data Corruption

### Corrupted `.tcm-hashes.json`
**Cause:** Manual editing or sync interruption
**Solution:**
1. Backup the file
2. Delete `.tcm-hashes.json`
3. Run `Sync-TcmTestCase -Pull` to rebuild

## Performance Issues

### Slow sync with 1000+ test cases
**Solution:**
- Sync specific folders instead of all
- Use `-WhatIf` to preview before syncing
- Consider excluding patterns in config

## Debug Mode

Enable verbose output for troubleshooting:
```powershell
$VerbosePreference = 'Continue'
Get-TcmTestCase -Verbose
Sync-TcmTestCase -Verbose -WhatIf
```
```

**Estimated Time:** 2 hours

---

### 7. ~~Remove or Clarify "Future Feature" Examples~~ ✅ COMPLETED
**File:** `Docs/examples/test-case-management/05-conflict-resolution.md`
**Issue:** ~~Shows code for unimplemented features~~
**Priority:** ~~P1 - User confusion~~ **RESOLVED**
**Completion Date:** October 16, 2025

**Actions Completed:**
- [x] Clarified as "Planned Feature - Not Yet Available" (Option 2)
- [x] Added warning note about current status
- [x] Provided workaround instructions
- [x] Documented planned functionality for future reference

**Implementation (Clarify - Chosen Option):**
```markdown
### Strategy 4: Interactive Resolution (Planned Feature)

> ⚠️ **Note:** Interactive conflict resolution is planned for a future release.
> Currently, use manual resolution (Strategy 3) or force push/pull (Strategies 1-2).

**Planned functionality:**
```powershell
# Will be available in future version
Resolve-TcmTestCaseConflict -Id "TC001" -Interactive
# This will open an interactive merge tool
```

**Current workaround:** Use Strategy 3 (Manual Resolution)
```

**Time Spent:** ~10 minutes (completed faster than estimated)

---

### 8. Add Git Integration Guide
**File:** New section in `Docs/examples/test-case-management/readme.md`
**Issue:** No guidance on version control integration
**Priority:** P1 - Workflow unclear

**Actions Required:**
- [ ] Add "Version Control Integration" section to readme
- [ ] Document what should/shouldn't be in git
- [ ] Provide `.gitignore` template
- [ ] Explain team collaboration workflows

**New Section:**
```markdown
## Version Control Integration

### What to Commit to Git

**✅ Always commit:**
- `.tcm-config.yaml` - Configuration (with tokenized PAT)
- `*.yaml` - Test case files
- Folder structure

**❌ Never commit:**
- `.tcm-hashes.json` - Sync state (regenerated automatically)
- Personal Access Tokens (use environment variables)
- `*.tmp` or backup files

### Recommended `.gitignore`

```gitignore
# TestCaseManagement
.tcm-hashes.json
*.tmp
*.bak

# Environment-specific configs
.tcm-config.local.yaml
```

### Team Collaboration Workflow

#### Developer A: Create and Push
```powershell
# 1. Create test case locally
New-TcmTestCase -Id "TC100" -Title "New Feature Test"

# 2. Edit YAML file with test steps
# ...

# 3. Commit to git
git add TestCases/TC100-new-feature.yaml
git commit -m "Add TC100: New Feature Test"

# 4. Push to Azure DevOps
Sync-TcmTestCase -InputObject "TC100" -Push

# 5. Push to git
git push origin main
```

#### Developer B: Pull and Modify
```powershell
# 1. Pull from git
git pull origin main

# 2. Pull from Azure DevOps (in case of direct changes)
Sync-TcmTestCase -Pull

# 3. Modify test case
# Edit TestCases/TC100-new-feature.yaml

# 4. Push changes back
Sync-TcmTestCase -InputObject "TC100" -Push
git commit -am "Update TC100 with additional steps"
git push origin main
```

### Handling Conflicts

When both git and Azure DevOps have conflicts:

1. **Resolve git conflicts first** (standard git workflow)
2. **Then resolve Azure DevOps conflicts** (using TCM conflict resolution)
3. **Commit final resolved version**

See [Conflict Resolution Guide](./05-conflict-resolution.md) for details.
```

**Estimated Time:** 1.5 hours

---

## Medium Priority Improvements

### 9. Add End-to-End Team Workflow Example
**File:** New file `Docs/examples/test-case-management/07-team-workflow.md`
**Priority:** P2 - Enhances understanding

**Actions Required:**
- [ ] Create complete team collaboration scenario
- [ ] Show multi-developer workflow
- [ ] Include conflict scenarios and resolution
- [ ] Add git + Azure DevOps integration

**Estimated Time:** 2 hours

---

### 10. Document Custom Fields Discovery
**File:** `Docs/examples/test-case-management/06-advanced-scenarios.md`
**Priority:** P2 - Advanced users

**Actions Required:**
- [ ] Add "Discovering Custom Fields" subsection
- [ ] Show how to query Azure DevOps for field names
- [ ] Explain naming conventions
- [ ] Show validation techniques

**New Subsection:**
```markdown
### Discovering Available Custom Fields

To find what custom fields are available in your Azure DevOps project:

```powershell
# Get a work item type definition
$workItemType = Get-WorkItemType -Type "Test Case" -CollectionUri $uri -Project $project

# List all fields
$workItemType.fields | Select-Object name, referenceName, type | Format-Table

# Filter for custom fields
$workItemType.fields | Where-Object { $_.referenceName -like "Custom.*" }
```

**Common Custom Fields:**
- `Custom.TestEnvironment` - String
- `Custom.AutomationStatus` - String (Picklist)
- `Custom.EstimatedHours` - Double
- `Custom.TestCategory` - String (Picklist)

**Field Naming Conventions:**
- Custom fields use `Custom.FieldName` format
- System fields use `System.FieldName` format
- Use exact casing as shown in Azure DevOps
```

**Estimated Time:** 1 hour

---

### 11. Add Performance Guidance
**File:** `Docs/examples/test-case-management/06-advanced-scenarios.md`
**Priority:** P2 - Scalability

**Actions Required:**
- [ ] Add "Performance Considerations" section
- [ ] Document batch size recommendations
- [ ] Show progress monitoring techniques
- [ ] Add optimization tips

**New Section:**
```markdown
## Performance Considerations

### Large Test Case Repositories (1000+ Files)

#### Optimize Sync Operations

```powershell
# Bad: Sync all test cases at once (slow)
Get-ChildItem "TestCases/**/*.yaml" -Recurse | Sync-TcmTestCase -Push

# Good: Sync by folder/batch
Get-ChildItem "TestCases/Sprint-Current/*.yaml" | Sync-TcmTestCase -Push

# Good: Sync only changed files
Get-TcmTestCase -IncludeSyncStatus |
    Where-Object { $_.SyncStatus -eq "local-changes" } |
    Sync-TcmTestCase -Push
```

#### Monitor Progress

```powershell
# Use -Verbose for progress tracking
$VerbosePreference = 'Continue'
Sync-TcmTestCase -Push -Verbose

# Show progress manually
$files = Get-ChildItem "TestCases/**/*.yaml" -Recurse
$total = $files.Count
$current = 0

foreach ($file in $files) {
    $current++
    Write-Progress -Activity "Syncing" -Status "$current of $total" -PercentComplete (($current/$total)*100)
    $file | Sync-TcmTestCase -Push
}
```

#### Recommendations

- **Batch size:** 50-100 test cases per sync operation
- **Exclude patterns:** Use `.tcm-config.yaml` to exclude archived folders
- **Parallel processing:** Consider PowerShell jobs for large batches (see examples)
- **Network:** Ensure stable connection for large sync operations
```

**Estimated Time:** 1 hour

---

### 12. Standardize Code Formatting
**Files:** All example files
**Priority:** P3 - Polish

**Actions Required:**
- [ ] Choose standard (4-space indentation for PowerShell)
- [ ] Update all code blocks consistently
- [ ] Ensure YAML examples use 2-space indentation
- [ ] Run through formatter

**Estimated Time:** 1.5 hours

---

## Low Priority Enhancements

### 13. Add Visual Workflow Diagrams
**Priority:** P3 - Nice to have

**Actions Required:**
- [ ] Create workflow diagram for sync operations
- [ ] Create diagram for conflict resolution flow
- [ ] Add architecture diagram showing local/remote relationship
- [ ] Use Mermaid or similar in markdown

**Estimated Time:** 2 hours

---

### 14. Create FAQ Section
**File:** New file `Docs/examples/test-case-management/faq.md`
**Priority:** P3 - Convenience

**Actions Required:**
- [ ] Collect common questions
- [ ] Provide concise answers with links
- [ ] Update as users ask questions

**Estimated Time:** 1 hour

---

### 15. Add Video Tutorial Links
**Priority:** P3 - Enhanced learning

**Actions Required:**
- [ ] Create quick-start video (5 min)
- [ ] Create sync workflow video (10 min)
- [ ] Link from documentation

**Estimated Time:** 4 hours (production)

---

## Implementation Schedule

### Phase 1: Critical Fixes (Day 1-2) - 6.5-8.5 hours
- [x] Issue #1: Fix parameter name ~~(15 min)~~ ✅ **COMPLETED** - Added alias
- [ ] Issue #3: Document sync functions (1 hour)
- [ ] Issue #4: Fix data model references (2 hours)
- [ ] Issue #7: Remove/clarify future features (15 min)
- [ ] Issue #2: Rewrite examples for public functions only (3-4 hours)

### Phase 2: High Priority (Day 2-3) - 6-8 hours
- [ ] Issue #5: Add PAT guide (45 min)
- [ ] Issue #6: Create troubleshooting doc (2 hours)
- [ ] Issue #8: Add git integration guide (1.5 hours)
- [ ] Issue #9: Team workflow example (2 hours)

### Phase 3: Medium Priority (Day 4-5) - 4-6 hours
- [ ] Issue #10: Custom fields documentation (1 hour)
- [ ] Issue #11: Performance guidance (1 hour)
- [ ] Issue #12: Code formatting standardization (1.5 hours)

### Phase 4: Polish (Day 6+) - 7+ hours
- [ ] Issue #13: Visual diagrams (2 hours)
- [ ] Issue #14: FAQ section (1 hour)
- [ ] Issue #15: Video tutorials (4 hours)

**Total Estimated Time:** 23.5-29.5 hours

---

## Success Metrics

### Before Improvements
- Documentation score: 7.5/10
- Time to first working example: 30-60 minutes (with errors)
- Support questions: High (parameter errors, function confusion)

### After Improvements
- Documentation score: 9.5/10
- Time to first working example: 10-15 minutes (no errors)
- Support questions: Low (self-service via docs)

### Validation
- [ ] New developer can complete quick start in <15 minutes
- [ ] Zero blocking errors in documented examples
- [ ] All public functions have clear documentation
- [ ] Troubleshooting guide covers 90% of common issues

---

## Maintenance Plan

### Ongoing
- Review documentation with each new function
- Update troubleshooting guide with user-reported issues
- Keep examples aligned with function signatures
- Run documentation generation after code changes

### Quarterly
- Audit examples for accuracy
- Update version numbers and dates
- Gather feedback from new users
- Improve based on support tickets

---

## Sign-off

**Prepared by:** AI Documentation Review
**Date:** October 16, 2025
**Branch:** tcm
**Next Review:** After Phase 1 completion

---

## Notes for Implementation

1. **Test all examples** after fixes - run through each code block manually
2. **Regenerate function docs** after visibility changes: `.\utils\run.generate.docs.ps1`
3. **Commit incrementally** - one issue per commit for easy rollback
4. **Update CHANGELOG.md** with documentation improvements
5. **Consider user testing** - have fresh developer validate fixes

