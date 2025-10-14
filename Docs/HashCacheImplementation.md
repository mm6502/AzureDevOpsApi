# Hash Cache System Implementation Summary

## Overview

Implemented a comprehensive hash cache system for the TestCaseManagement module that enables proper 3-way merge conflict detection and git-like synchronization workflows.

## What Was Implemented

### 1. Cache Management Functions (Private)

#### `Get-TcmHashCache`
- **Location**: `Private/TestCaseManagement/Get-TcmHashCache.ps1`
- **Purpose**: Loads the hash cache from `.tcm-hashes.json`
- **Features**:
  - Returns empty hashtable if cache file doesn't exist
  - Gracefully handles corrupt cache files with warnings
  - Compatible with both PowerShell 5.1 and 6+

#### `Set-TcmHashCache`
- **Location**: `Private/TestCaseManagement/Set-TcmHashCache.ps1`
- **Purpose**: Saves the hash cache to disk
- **Features**:
  - Creates directory structure if needed
  - Overwrites existing cache file
  - Saves as formatted JSON

#### `Update-TcmHashCacheEntry`
- **Location**: `Private/TestCaseManagement/Update-TcmHashCacheEntry.ps1`
- **Purpose**: Updates a single test case entry in the cache
- **Features**:
  - Creates new entry if doesn't exist
  - Allows updating local hash, remote hash, or both
  - Automatically updates lastSync timestamp with UTC time

### 2. Enhanced Sync Status Resolution

#### `Resolve-TcmTestCaseSyncStatus` (Updated)
- **Location**: `Private/TestCaseManagement/Resolve-TcmTestCaseSyncStatus.ps1`
- **What Changed**: Implemented 3-way merge logic using hash cache
- **New Behavior**:
  - Loads cache and compares current hashes with cached hashes
  - Detects which side(s) changed since last sync
  - Returns more accurate sync status values:
    - `synced`: No changes detected
    - `local-changes`: Only local changed since last sync
    - `remote-changes`: Only remote changed since last sync
    - `conflict`: **Both** local and remote changed (diverged)
    - `new-local`: No cache entry and not synced yet
    - `new-remote`: Remote exists but no local file

### 3. Cache Updates in Sync Operations

#### `Sync-TcmTestCase` (Updated)
- **Location**: `Public/TestCaseManagement/Sync-TcmTestCase.ps1`
- **What Changed**: Added cache updates after successful sync operations
- **New Behavior**:
  - After **push** (new-local or local-changes): Sets both local and remote hashes to current local hash
  - After **pull** (new-remote or remote-changes): Sets both local and remote hashes to current remote hash
  - After **conflict resolution**: Re-loads test case and sets both hashes to final resolved hash

### 4. Test Coverage

#### `Get-TcmHashCache.tests.ps1`
- **Location**: `Tests/Private/TestCaseManagement/Get-TcmHashCache.tests.ps1`
- **Coverage**: 10 comprehensive tests covering all cache functions:
  - Empty cache scenarios
  - Loading existing cache
  - Handling corrupt cache files
  - Creating new cache files
  - Updating cache entries
  - Partial updates (local-only or remote-only)
  - Timestamp updates

## Cache File Structure

The cache is stored as `.tcm-hashes.json` in the test cases root directory:

```json
{
  "12345": {
    "local": "abc123def456...",
    "remote": "abc123def456...",
    "lastSync": "2025-10-13T10:30:00.0000000Z"
  },
  "67890": {
    "local": "xyz789abc123...",
    "remote": "xyz789abc123...",
    "lastSync": "2025-10-13T11:00:00.0000000Z"
  }
}
```

## How It Works

### Before Cache (Old Behavior)
- Could only detect that local ≠ remote
- Couldn't determine which side changed
- No way to detect conflicts (both sides changed)

### With Cache (New Behavior)
1. **Load cache** to get last-known hashes
2. **Calculate current hashes** for local and remote
3. **Compare with cache**:
   - Current local hash ≠ cached local hash → local changed
   - Current remote hash ≠ cached remote hash → remote changed
4. **Determine status**:
   - Both unchanged → `synced`
   - Only local changed → `local-changes`
   - Only remote changed → `remote-changes`
   - Both changed → `conflict`
5. **After successful sync**: Update cache with new hashes

## Usage Example

```powershell
# First sync - creates cache entry
PS> Sync-TcmTestCase -InputObject "12345" -Push
→ Pushing new test case '12345' to Azure DevOps...
# Cache now: { "12345": { local: "abc...", remote: "abc...", lastSync: "..." } }

# User edits local file (remote unchanged)
PS> Sync-TcmTestCase -InputObject "12345"
→ Pushing changes for test case '12345' to Azure DevOps...
# Status detected: local-changes (only local hash differs from cache)
# Cache updated: both hashes set to new local hash

# Meanwhile, colleague edits on Azure DevOps
# User tries to sync again
PS> Sync-TcmTestCase -InputObject "12345"
⚠ Conflict detected for test case '12345'. Local and remote versions have diverged.
# Status detected: conflict (both hashes differ from cache)
# User must resolve manually or use -Force

# Resolve with force pull
PS> Sync-TcmTestCase -InputObject "12345" -Pull -Force
← Pulling changes for test case '12345' from Azure DevOps...
# Cache updated: both hashes set to remote hash
```

## Testing

All tests pass successfully:

```powershell
PS> & .\Tests\Private\TestCaseManagement\Get-TcmHashCache.tests.ps1
Tests Passed: 10, Failed: 0, Skipped: 0 NotRun: 0
```

## Documentation Updates

- Updated `Docs/TestCaseManagement-Architecture.md` with:
  - Detailed implementation section for hash cache system
  - Cache structure documentation
  - 3-way merge logic explanation
  - Usage examples
  - Marked as completed in progress tracking

## Key Benefits

1. **Accurate Conflict Detection**: Can now detect when both local and remote have changed since last sync
2. **Git-like Workflow**: Enables familiar push/pull patterns with proper conflict handling
3. **No Breaking Changes**: Works transparently - existing code continues to function
4. **Offline Support**: Cache persists between sessions, enabling offline status checks
5. **Clean Separation**: Cache stored separately from test case data files

## Files Modified

### Created (3 files)
- `Private/TestCaseManagement/Get-TcmHashCache.ps1`
- `Private/TestCaseManagement/Set-TcmHashCache.ps1`
- `Private/TestCaseManagement/Update-TcmHashCacheEntry.ps1`
- `Tests/Private/TestCaseManagement/Get-TcmHashCache.tests.ps1`

### Modified (3 files)
- `Private/TestCaseManagement/Resolve-TcmTestCaseSyncStatus.ps1`
- `Public/TestCaseManagement/Sync-TcmTestCase.ps1`
- `Docs/TestCaseManagement-Architecture.md`

## Next Steps

Recommended follow-ups:

1. Add integration tests for the full sync workflow with cache
2. Consider adding cache cleanup for deleted test cases
3. Add cache statistics/diagnostics command
4. Consider caching strategy for non-numeric IDs (currently only used for numeric Azure DevOps work item IDs)

## Recent Fixes (October 13, 2025)

### Issue: LocalData Structure Access

**Problem**: Getting error "Cannot bind argument to parameter 'InputObject' because it is null" when running sync operations like `'550281' | Sync-TcmTestCase -TestCasesRoot .\TestCases\`.

**Root Cause**: The code was incorrectly accessing `$resolved.LocalData.testCase` when calculating hashes. However, `LocalData` already contains the test case data directly (not wrapped in a `.testCase` property). The YAML file structure has `testCase:` as the root key, but when loaded, the content under `testCase:` becomes the `LocalData` value.

**Files Fixed**:

1. `Resolve-TcmTestCaseSyncStatus.ps1` (Line 108):
   - Changed: `$localHash = Get-TcmStringHash -InputObject $TestCaseData.testCase`
   - To: `$localHash = Get-TcmStringHash -InputObject $TestCaseData`

2. `Sync-TcmTestCase.ps1` (3 locations):
   - new-local case: `$resolved.LocalData.testCase` → `$resolved.LocalData`
   - local-changes case: `$resolved.LocalData.testCase` → `$resolved.LocalData`
   - conflict resolution: `$updatedTestCase.LocalData.testCase` → `$updatedTestCase.LocalData`

### Issue: RemoteData Not Populated

**Problem**: RemoteData was null in "new-remote" case, causing issues in subsequent sync operations.

**Solution**: Added `ConvertFrom-TcmWorkItemToTestCase` conversion before returning in the "new-remote" status path in `Resolve-TcmTestCaseSyncStatus.ps1`.

### Issue: Cache Not Created on First Sync

**Problem**: Cache file was not being created when running sync on already-synced test cases.

**Solution**: Added cache initialization in the "synced" status case in `Sync-TcmTestCase.ps1` to ensure cache entry is created even when no sync operation is performed.

**Result**: ✅ All issues resolved. Command `'550281' | Sync-TcmTestCase -TestCasesRoot .\TestCases\` now works correctly and creates the cache file.
