# TODO

## TestCaseManagement

### Current Config Loading Behavior

- ⚠️ **Config must be in TestCasesRoot:** `Get-TcmTestCaseConfig` looks for `.tcm-config.yaml`
  directly in the specified directory (does NOT search parent directories)
- **Future Enhancement:** Consider implementing parent directory search (like git's `.git` lookup)
  to allow subdirectory operations without requiring config in each subdirectory
