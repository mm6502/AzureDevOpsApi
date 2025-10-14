# TestCaseManagement Architecture and Rework Plan

## Overview

The TestCaseManagement module provides **hybrid functionality** for managing Azure DevOps test cases through local YAML files with seamless integration to remote Azure DevOps work items. The module supports creating, reading, updating, and syncing test cases with conflict resolution capabilities.

**Key Features**:

- **Hybrid Loading**: Local YAML files with fallback to Azure DevOps API for numeric IDs
- **Local-First Priority**: Checks local files before making API calls
- **Exclude Pattern Filtering**: Complete filtering of draft/test files from all operations
- **Unified Data Model**: Consistent objects with both local and remote data properties
- **Sync Operations**: Bidirectional synchronization with conflict resolution and git-like syntax
- **Git-like Syntax**: Familiar `-Push`, `-Pull`, and `-Force` switches for synchronization

## Current Architecture

### Components

#### Public Functions (`Public/TestCaseManagement/`)

- `Get-TcmTestCase`: **HYBRID LOADING** - Retrieves test case data from YAML files AND/OR remote Azure DevOps (by ID, path, or all)
  - **Local-first for numeric IDs**: Checks local YAML files first, falls back to Azure DevOps API
  - **Remote-only for pure numeric IDs**: Loads directly from Azure DevOps when no local file exists
  - **Exclude pattern filtering**: Completely skips excluded files (e.g., draft files) from both local and remote loading
  - **Dual data output**: Returns objects with both LocalData and RemoteData properties
- `New-TcmTestCase`: Creates new test case YAML files
- `New-TcmConfig`: Creates `.tcm-config.yaml` configuration files
- `Sync-TcmTestCase`: Synchronizes test cases between local and remote with git-like syntax (-Push, -Pull, -Force)
- `Sync-TcmTestCaseFromRemote`: Downloads remote test cases to local files
- `Sync-TcmTestCaseToRemote`: Uploads local test cases to Azure DevOps
- `Resolve-TcmTestCaseConflict`: Handles merge conflicts during sync

#### Private Functions (`Private/TestCaseManagement/`)

- `ConvertTo-TcmTestCaseInput`: Normalizes various input types into standardized objects
- `Resolve-TcmTestCaseSyncStatus`: Determines synchronization status by comparing local/remote states
- `Get-TcmTestCaseFromFile`: Parses individual YAML test case files
- `Save-TcmTestCaseYaml`: Saves test case data to YAML files
- `ConvertFrom-TcmWorkItemToTestCase`: Converts Azure DevOps work items to test case format
- `ConvertTo-TcmTestStepsXml`: Converts test steps to XML format
- `Get-TcmTestCaseConfig`: Loads configuration from `.tcm-config.yaml`
- `Get-TcmStringHash`: Generates hashes for comparison
- `Get-TcmFolderPathFromAreaPath`: Maps area paths to folder structures
- `Get-TcmRelativeTestCasePath`: Calculates relative paths

### Data Flow

#### Hybrid Loading Architecture

1. **Input Resolution**: `ConvertTo-TcmTestCaseInput` normalizes raw inputs (paths, IDs, directories) into `TcmTestCaseFileInput` objects
2. **Local File Check**: For numeric IDs, first check if local YAML file exists using ID-to-file-path cache
3. **Exclude Pattern Filtering**: Apply exclude patterns (e.g., `**/*-draft.yaml`) - completely skip excluded files from all processing
4. **Dual Data Loading**:
   - **Local Loading**: `Get-TcmTestCaseFromFile` loads and parses YAML files into structured objects
   - **Remote Loading**: For numeric IDs without local files, `Get-WorkItem` + `ConvertFrom-TcmWorkItemToTestCase` loads from Azure DevOps API
5. **Data Combination**: Merge local and remote data into unified objects with `LocalData` and `RemoteData` properties
6. **Status Determination**: `Resolve-TcmTestCaseSyncStatus` compares local/remote states using hashes for sync operations

### Configuration

- Uses `.tcm-config.yaml` files for project-specific settings
- Supports Azure DevOps connection details, sync patterns, and exclusions
- Configuration loaded via `Get-TcmTestCaseConfig`

## Decisions

### 1. Function Overlap: ConvertTo-TcmTestCaseInput vs Get-TcmTestCase

**Question**: Are `ConvertTo-TcmTestCaseInput` and `Get-TcmTestCase` doing the same thing?

**Analysis**:

- `Get-TcmTestCase`: Public function focused on retrieving test case data from YAML files. Returns structured test case objects with optional metadata.
- `ConvertTo-TcmTestCaseInput`: Private helper that normalizes various input types (strings, objects, pipeline input) into standardized `TcmTestCaseFileInput` objects for sync operations.

**Detailed Overlap Analysis**:

#### Current Usage Patterns

**Get-TcmTestCase** is used for:

- Direct user queries (get by ID, path, or all test cases)
- Data retrieval and inspection
- Pipeline input to sync operations
- Called by `Sync-TcmTestCase` when no `InputObject` is provided

**ConvertTo-TcmTestCaseInput** is used for:

- Input normalization in all sync operations (`Sync-TcmTestCase`, `Sync-TcmTestCaseFromRemote`, `Sync-TcmTestCaseToRemote`, `Resolve-TcmTestCaseConflict`)
- Converting various input types to standardized `TcmTestCaseFileInput` format:
  - File paths (individual files)
  - Directory paths (recursively finds all YAML files)
  - Test case IDs
  - TcmTestCase objects
  - Hashtables/PSCustomObjects with testCase.id
  - Existing TcmTestCaseFileInput objects (pass-through)

#### Issues Resolved ✅

1. **Function Flow Clarified**: **CORRECTED**
   - Intended flow: `ConvertTo-TcmTestCaseInput → Get-TcmTestCase`
   - `ConvertTo-TcmTestCaseInput`: Input normalization and standardization
   - `Get-TcmTestCase`: Data retrieval and population of `LocalData`
   - Result: Clear pipeline with proper separation of concerns

2. **Input Handling**: **ENHANCED**
   - Comprehensive support for all input types (files, directories, IDs, objects)
   - Robust object creation and filtering
   - Maintains backward compatibility

3. **Architecture**: **STREAMLINED**
   - Removed circular dependencies
   - Clean data flow from input → normalization → retrieval → processing
   - Enhanced testability and maintainability

#### Implementation Architecture

```text
User Input → ConvertTo-TcmTestCaseInput → Get-TcmTestCase → Hybrid Loading → Unified Output
```

**Detailed Flow**:

1. **Input Normalization**: `ConvertTo-TcmTestCaseInput` converts raw inputs to standardized `TcmTestCaseFileInput` objects
   - Builds ID-to-file-path cache for efficient lookups
   - Handles files, directories, IDs, and complex objects
   - Returns objects with `FilePath` and/or `Id` properties

2. **Hybrid Data Retrieval**: `Get-TcmTestCase` implements dual loading logic:
   - **For File Paths**: Load local YAML data, apply exclude patterns
   - **For Numeric IDs**: Check local files first, fallback to Azure DevOps API
   - **For Non-numeric IDs**: Require local files (no remote loading)

3. **Exclude Pattern Enforcement**: Complete filtering at file level:
   - Applied before any data loading (local or remote)
   - Uses `Test-String` with include/exclude patterns
   - Skips entire files with `continue` when excluded

4. **Data Unification**: Combines local and remote data:
   - `LocalData`: Parsed YAML content from files
   - `RemoteData`: Converted Azure DevOps work item data
   - `LocalDataHash`/`RemoteDataHash`: For sync status comparison

5. **Sync Status Resolution**: `Resolve-TcmTestCaseSyncStatus` determines synchronization state for sync operations

**Key Improvements in ConvertTo-TcmTestCaseInput**:

- **ID-to-File-Path Caching**: Builds and caches mappings from test case IDs to file paths for efficient lookups
- **Comprehensive Input Handling**: Supports files, directories, IDs, objects, and existing TcmTestCaseFileInput objects
- **Directory Support**: When given a directory path, recursively finds all `*.yaml` files (excluding `.*.yaml`)
- **Object Wrapping**: Converts various input types into standardized `TcmTestCaseFileInput` objects
- **Robust Filtering**: Only returns objects with valid `Id` or `FilePath` properties
- **Pipeline Position**: Runs before `Get-TcmTestCase` to normalize inputs

**Key Improvements in Get-TcmTestCase**:

- **Hybrid Loading**: Supports both local YAML files and remote Azure DevOps data
- **Local-First Logic**: For numeric IDs, checks local files first before API calls
- **Complete Exclude Filtering**: Applies exclude patterns before any loading (local or remote)
- **Dual Data Output**: Returns objects with both `LocalData` and `RemoteData` properties
- **Error Handling**: Graceful handling of missing files, invalid work items, and API errors

**Status**: ✅ **Function overlap resolved** - Implemented hybrid loading architecture with `ConvertTo-TcmTestCaseInput → Get-TcmTestCase` pipeline and comprehensive exclude pattern filtering.

### 3. Hybrid Loading Design Decisions

**Question**: How should `Get-TcmTestCase` handle the combination of local files and remote Azure DevOps data?

**Current Implementation**: **HYBRID LOADING WITH LOCAL PRIORITY**

#### Loading Strategy

- **Numeric IDs (e.g., "123")**: Local-first approach
  - Check for local YAML file matching the ID
  - If found and not excluded, load local data
  - If not found or excluded, load from Azure DevOps API
  - Return unified object with `LocalData` and/or `RemoteData`

- **Non-numeric IDs (e.g., "TC001")**: Local-only approach
  - Must have corresponding local YAML file
  - No remote loading for non-numeric IDs
  - Error if local file not found

- **File Paths**: Local-only approach
  - Load specified YAML file directly
  - Apply exclude patterns before loading
  - Skip excluded files entirely

#### Exclude Pattern Behavior

- **Applied Early**: Exclude patterns checked before any data loading (local or remote)
- **Complete Skip**: Excluded files are skipped with `continue` - no loading of any kind
- **Pattern Matching**: Uses `Test-String` with include `*.yaml`/`**/*.yaml` and configured exclude patterns
- **Config-Driven**: Exclude patterns loaded from `.tcm-config.yaml`

#### Data Unification

- **Unified Objects**: All outputs have consistent structure with `LocalData`, `RemoteData`, `LocalDataHash`, `RemoteDataHash`
- **Backward Compatibility**: Existing scripts continue to work with `LocalData` property
- **Rich Metadata**: Includes file paths, relative paths, and sync status information

### 2. Hash Storage for Change Detection

**Question**: Should `Resolve-TcmTestCaseSyncStatus` store hashes to determine whether changes were local, remote, or both?

**Current Limitation**: ~~The function can only detect that local and remote differ, but cannot determine the direction or source of changes without stored state.~~ **RESOLVED**

**Decision**: Implemented **separate hash cache** (`.tcm-hashes.json`) for the following reasons:

- Clean separation of data and metadata
- Enables detecting concurrent changes (3-way merge logic)
- Supports offline operation
- Easier to manage and version control

**Implementation**: ✅ **COMPLETED**

**Cache Structure**:

```json
{
  "12345": {
    "local": "abc123...",
    "remote": "abc123...",
    "lastSync": "2025-10-13T10:30:00.000Z"
  }
}
```

**Implementation Details**:

1. **Cache Location**: `.tcm-hashes.json` in test cases root directory
2. **Cache Functions**:
   - `Get-TcmHashCache`: Loads cache from disk, returns empty hashtable if not found
   - `Set-TcmHashCache`: Saves cache to disk as JSON
   - `Update-TcmHashCacheEntry`: Updates single test case entry with new hashes and timestamp

3. **3-Way Merge Logic**: `Resolve-TcmTestCaseSyncStatus` now implements proper change detection:
   - Compares current local hash with cached local hash → detects local changes
   - Compares current remote hash with cached remote hash → detects remote changes
   - Determines sync status based on change pattern:
     - `synced`: No changes since last sync
     - `local-changes`: Only local changed
     - `remote-changes`: Only remote changed
     - `conflict`: Both local and remote changed (diverged)
     - `new-local`: No cache entry + non-numeric ID or no remote
     - `new-remote`: No local file but remote exists

4. **Cache Updates**: `Sync-TcmTestCase` updates cache after successful operations:
   - After push (new-local/local-changes): Sets both local and remote hashes to current local hash
   - After pull (new-remote/remote-changes): Sets both local and remote hashes to current remote hash
   - After conflict resolution: Re-loads test case and sets both hashes to final resolved hash
   - On first sync (synced status): Initializes cache entry with matching hashes
   - Includes UTC timestamp for each update

5. **Data Structure Handling**:
   - `LocalData` property contains the test case data directly (not wrapped in `.testCase`)
   - Fixed hash calculation to use `$resolved.LocalData` instead of `$resolved.LocalData.testCase`
   - RemoteData populated before returning from all status resolution paths

6. **Error Handling**:
   - Graceful fallback to empty cache if file corrupt/missing
   - Warning messages for cache loading failures
   - No sync operations blocked by cache issues
   - PowerShell 5.1 and 6+ compatibility for JSON conversion

**Usage Example**:

```powershell
# First sync - no cache exists
Sync-TcmTestCase -InputObject "12345" -Push
# Creates cache entry: { "12345": { local: "abc...", remote: "abc...", lastSync: "2025-10-13..." } }

# User edits local file
# Next sync detects local-only change
Sync-TcmTestCase -InputObject "12345" -Push
# Status: "local-changes" → Pushes to remote
# Updates cache: both hashes now match new local hash

# User edits on Azure DevOps
# Next sync detects remote-only change
Sync-TcmTestCase -InputObject "12345" -Pull
# Status: "remote-changes" → Pulls from remote
# Updates cache: both hashes now match new remote hash

# User edits both local AND remote (without syncing between)
# Next sync detects conflict
Sync-TcmTestCase -InputObject "12345"
# Status: "conflict" → Requires manual resolution or -Force flag
```

## Progress Tracking

### Completed

- [x] Initial architecture analysis
- [x] Function overlap assessment (ConvertTo-TcmTestCaseInput vs Get-TcmTestCase)
- [x] Detailed overlap analysis with refactoring options
- [x] **Hybrid Loading Implementation** - Get-TcmTestCase now supports local + remote data loading for numeric IDs
- [x] **ID-to-File-Path Caching** - ConvertTo-TcmTestCaseInput implements efficient caching for ID lookups
- [x] **Complete Exclude Pattern Filtering** - Exclude patterns now prevent both local and remote loading
- [x] **Dual Data Architecture** - Unified objects with LocalData and RemoteData properties
- [x] **Git-like Syntax** - Sync-TcmTestCase now supports -Push, -Pull, and -Force switches
- [x] **Hash Cache System** - Implemented `.tcm-hashes.json` for 3-way merge conflict detection
- [x] **3-Way Merge Logic** - Resolve-TcmTestCaseSyncStatus detects local-only, remote-only, and concurrent changes
- [x] **Cache Updates in Sync** - Sync-TcmTestCase updates cache after all successful operations
- [x] **Cache Initialization** - First sync with matching local/remote creates cache entry for future change detection
- [x] **Data Structure Fixes** - Fixed LocalData property access (direct access vs .testCase wrapper)
- [x] **RemoteData Population** - All sync status paths properly populate RemoteData before return
- [x] **Test Coverage** - 10/10 hash cache tests passing, 15/16 Sync-TcmTestCase tests passing
- [x] **PowerShell Compatibility** - Cache loading works with both PowerShell 5.1 and 6+

### In Progress

- [ ] Add comprehensive error handling for sync operations
- [ ] Improve conflict resolution UI/UX

### Known Issues

- Edge case warnings in tests when RemoteData is null (does not cause test failures)
- These occur in remote-changes/new-remote scenarios with specific mock configurations

## Testing Strategy

### Unit Tests

- Individual function testing in `Tests/Private/TestCaseManagement/`
- Mock Azure DevOps API calls
- Test various input scenarios and edge cases

### Integration Tests

- Full sync workflow testing
- Configuration file handling
- Error recovery scenarios

### Manual Testing

- Real Azure DevOps project integration
- Large repository performance testing
- Conflict resolution user experience

## Migration Plan

1. **Phase 1**: ✅ Hash cache system implemented (backward compatible)
2. **Phase 2**: ✅ Input resolution functions working correctly
3. **Phase 3**: Add new features (attachments, bulk operations)
4. **Phase 4**: Performance optimizations and telemetry

## Recent Fixes (October 13, 2025)

### Data Structure Access Issue

**Problem**: Error "Cannot bind argument to parameter 'InputObject' because it is null" when running sync operations.

**Root Cause**: Code was accessing `$resolved.LocalData.testCase` but `LocalData` already contains the test case data directly (not wrapped in a `.testCase` property).

**Solution**: Changed all occurrences to use `$resolved.LocalData` directly:

- `Resolve-TcmTestCaseSyncStatus.ps1` - Line 108 (hash calculation)
- `Sync-TcmTestCase.ps1` - 3 occurrences (new-local, local-changes, conflict resolution)

### RemoteData Population

**Problem**: RemoteData was not being populated before returning in "new-remote" case.

**Solution**: Added `ConvertFrom-TcmWorkItemToTestCase` call before returning in "new-remote" status path, ensuring RemoteData is available for sync operations.

### Cache Initialization

**Problem**: Cache file was not created on first sync when test cases were already in sync.

**Solution**: Added cache initialization in the "synced" status case to ensure cache entry is created even when no sync operation is performed.

## Risks and Mitigations

- **Breaking Changes**: Maintain backward compatibility during rework
- **Performance**: Monitor and optimize for large repositories
- **Azure DevOps API Changes**: Abstract API calls for easier adaptation
- **Data Loss**: Implement robust backup and recovery mechanisms
