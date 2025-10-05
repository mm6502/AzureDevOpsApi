# 03 - Understanding Folder Organization

This example demonstrates how to organize your test case YAML files in a folder structure that makes sense for your project and how the TestCaseManagement system handles folder organization.

## Overview

The TestCaseManagement system allows you to organize your test cases in any folder structure you prefer. Unlike traditional systems that enforce rigid hierarchies, this system is flexible and allows you to reorganize files as your project evolves.

## Recommended Folder Structure

While you can organize files in any way, here are some recommended patterns:

### By Area Path

```
TestCases/
├── Project-Alpha/
│   ├── Authentication/
│   │   ├── 12345-login-validation.yaml
│   │   └── 12346-password-reset.yaml
│   └── User-Management/
│       └── 12347-profile-updates.yaml
├── Project-Beta/
│   └── API-Testing/
│       └── 12348-endpoint-validation.yaml
```

### By Test Type

```
TestCases/
├── Smoke-Tests/
│   ├── 12345-critical-path.yaml
│   └── 12346-basic-functionality.yaml
├── Regression-Tests/
│   ├── 12347-edge-cases.yaml
│   └── 12348-integration-scenarios.yaml
├── Performance-Tests/
│   └── 12349-load-testing.yaml
```

### By Feature or Component

```
TestCases/
├── User-Interface/
│   ├── Login-Form/
│   │   ├── 12345-form-validation.yaml
│   │   └── 12346-responsive-design.yaml
│   └── Dashboard/
│       └── 12347-widget-interactions.yaml
├── Backend-API/
│   ├── Authentication/
│   │   └── 12348-token-validation.yaml
│   └── Data-Processing/
│       └── 12349-batch-operations.yaml
```

## How Folder Organization Works

### Flexible Organization

The system doesn't enforce any specific folder structure. You can:

- Create nested subfolders as deep as needed
- Rename folders without breaking sync
- Move files between folders
- Use any naming convention you prefer

### Sync Behavior

- **Work Item IDs are preserved**: Moving a file to a different folder doesn't change its Azure DevOps Work Item ID
- **Relative paths are ignored**: The system doesn't store or use folder paths for synchronization
- **File discovery is recursive**: The system scans all subfolders automatically

## Working with Folder Organization

### Creating Test Cases in Specific Folders

```powershell
# Create a test case in a specific subfolder
New-TcmTestCase -Title "Login Validation" -OutputPath "Authentication/Login-Tests/TC001.yaml"

# The system will create the folder structure if it doesn't exist
```

### Moving Test Cases Between Folders

```powershell
# You can manually move files between folders
# The sync system will continue to work because it uses Work Item IDs, not paths
Move-Item "TestCases/Old-Folder/12345-test.yaml" "TestCases/New-Folder/12345-test.yaml"
```

### Bulk Operations on Folder Contents

```powershell
# Push all test cases in a specific folder
Get-ChildItem "TestCases/Smoke-Tests/*.yaml" -Recurse | Resolve-TcmTestCaseFilePathInput | Sync-TcmTestCaseToRemote

# Pull all test cases (scans all folders automatically)
Sync-TcmTestCaseFromRemote
```

## Best Practices

### 1. Use Descriptive Folder Names

```powershell
# Good
TestCases/
├── User-Authentication/
├── Payment-Processing/
└── Admin-Functionality/

# Less clear
TestCases/
├── Folder1/
├── Folder2/
└── Misc/
```

### 2. Keep Related Test Cases Together

Group test cases by feature, component, or test type to make them easier to find and manage.

### 3. Use Consistent Naming Conventions

```powershell
# Consistent patterns
TestCases/
├── Web-UI/
│   ├── Login-Page/
│   ├── Dashboard/
│   └── User-Profile/
├── API/
│   ├── REST-Endpoints/
│   └── GraphQL-Queries/
```

### 4. Document Your Organization

Consider adding a README.md in your TestCases folder to explain your organization scheme:

```markdown
# TestCases Organization

## Folder Structure

- `Web-UI/`: Tests for web interface components
- `API/`: Tests for API endpoints and integrations
- `Mobile/`: Tests for mobile application features
- `Performance/`: Load and performance tests

## Naming Convention

Files are named with the pattern: `{WorkItemId}-{DescriptiveName}.yaml`
```

## Advanced Organization Patterns

### Multi-Project Setup

```
TestCases/
├── Project-A/
│   ├── Sprint-1/
│   └── Sprint-2/
├── Project-B/
│   ├── Feature-X/
│   └── Feature-Y/
```

### Test Case Templates

```
TestCases/
├── Templates/
│   ├── Basic-Functional-Test.yaml
│   └── Performance-Test.yaml
├── Active-Tests/
│   ├── 12345-user-login.yaml
│   └── 12346-password-reset.yaml
```

## Troubleshooting

### Files Not Found

If the system can't find your test case files:

1. Check that you're in the correct directory or have set `TestCasesRoot`
2. Ensure files have the `.yaml` extension
3. Verify the file contains valid YAML with a `testCase` section

### Sync Issues After Moving Files

Moving files between folders should not cause sync issues since the system uses Work Item IDs. If you encounter problems:

1. Check that the file still contains the correct `testCase.id` field
2. Ensure the YAML structure is valid
3. Try a manual sync with the specific Work Item ID

## Related Examples

- [01-setup-configuration.md](01-setup-configuration.md) - Setting up your configuration
- [02-creating-test-cases.md](02-creating-test-cases.md) - Creating individual test cases
- [04-sync-workflows.md](04-sync-workflows.md) - Synchronizing with Azure DevOps
