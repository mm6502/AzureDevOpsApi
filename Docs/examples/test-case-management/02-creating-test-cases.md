# Creating Test Cases

## Overview

TestCaseManagement enables user-friendly authoring of test cases through direct YAML file editing. Create and edit test case files in any text editor, then synchronize them with Azure DevOps. This approach provides:

- **Human-readable format**: YAML files are easy to read, write, and version control
- **Offline authoring**: Create test cases without Azure DevOps connectivity
- **Rich editing experience**: Use your favorite editor with syntax highlighting and validation
- **Version control friendly**: Track changes and collaborate using git

## YAML File Structure

Test cases are authored as YAML files with a structured format that maps directly to Azure DevOps work item fields. Each file represents one test case.

### Basic Test Case Structure

Create a new file (e.g., `TC001-login-validation.yaml`) with this structure:

```yaml
testCase:
  # Required fields
  id: TC001
  title: "User Login Validation"

  # Work item fields (use defaults from .tcm-config.yaml)
  areaPath: "YourProject"
  iterationPath: "YourProject"
  state: "Design"
  priority: 2

  # Optional fields
  assignedTo: ""
  tags: []
  description: ""
  preconditions: ""
  automationStatus: "Not Automated"
  customFields: {}

  # Test steps
  steps:
    - stepNumber: 1
      action: ""
      expectedResult: ""
      attachments: []
```

### Complete Test Case Example

```yaml
testCase:
  id: TC002
  title: "Complete Login Flow Test"
  areaPath: "YourProject\\Authentication"
  iterationPath: "YourProject\\Sprint 1"
  state: "Design"
  priority: 1
  assignedTo: "tester@company.com"
  tags:
    - "smoke-test"
    - "authentication"
    - "critical"

  description: |
    Test the complete user authentication flow from login to logout.
    This test ensures users can successfully authenticate and access the system.

  preconditions: |
    - User account exists in the system
    - Application is accessible via web browser
    - Valid credentials are available for testing

  automationStatus: "Not Automated"

  customFields:
    customField1: "value1"
    customField2: "value2"

  steps:
    - stepNumber: 1
      action: "Navigate to login page"
      expectedResult: "Login form is displayed with username and password fields"
      attachments: []

    - stepNumber: 2
      action: "Enter valid username and password"
      expectedResult: "Credentials are accepted without error messages"
      attachments: []

    - stepNumber: 3
      action: "Click 'Login' button"
      expectedResult: "User is redirected to dashboard and session is established"
      attachments:
        - path: "./screenshots/login-success.png"
          azureId: ""

    - stepNumber: 4
      action: "Click 'Logout' button"
      expectedResult: "User session is terminated and login page is displayed"
      attachments: []
```

## Creating Test Case Files

### Manual File Creation

1. **Create a new YAML file** in your preferred text editor
2. **Use the structure above** as a template
3. **Fill in the required fields** (id, title)
4. **Add test steps** with clear actions and expected results
5. **Save with .yaml extension** using the naming convention: `{ID}-{title}.yaml`

### File Naming Convention

Use consistent naming for easy identification:

```text
TC001-login-validation.yaml
TC002-password-reset.yaml
TC003-user-profile-update.yaml
```

### Directory Organization

Organize test cases in folders that match your Azure DevOps area structure:

```text
test-cases/
├── authentication/
│   ├── TC001-login-validation.yaml
│   └── TC002-password-reset.yaml
├── user-management/
│   ├── TC003-profile-update.yaml
│   └── TC004-account-deletion.yaml
└── .tcm-config.yaml
```

## Field Reference

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier (e.g., "TC001") |
| `title` | string | Descriptive test case title |

### Work Item Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `areaPath` | string | From config | Azure DevOps area path |
| `iterationPath` | string | From config | Sprint/iteration path |
| `state` | string | "Design" | Work item state |
| `priority` | integer | 2 | Priority (1-4) |
| `assignedTo` | string | "" | Assigned user email |
| `tags` | array | [] | String tags for categorization |

### Test Content Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Detailed test case description |
| `preconditions` | string | Required setup or conditions |
| `automationStatus` | string | "Not Automated", "Planned", "Automated" |
| `customFields` | object | Organization-specific custom fields |

### Test Steps

Each step in the `steps` array has:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `stepNumber` | integer | Yes | Sequential step number |
| `action` | string | Yes | What the tester should do |
| `expectedResult` | string | Yes | Expected outcome |
| `attachments` | array | No | Screenshots or documents |

## Editing Test Cases

### Using Your Favorite Editor

Edit YAML files directly in any text editor with YAML syntax highlighting:

- **VS Code**: Install "YAML" extension for syntax highlighting and validation
- **Notepad++**: Use YAML syntax highlighting
- **Vim/Emacs**: Built-in YAML support available

### Validation Tips

- **Check indentation**: YAML uses 2-space indentation
- **Quote strings**: Use quotes for strings with special characters
- **Validate syntax**: Use online YAML validators or editor extensions
- **Test locally**: Use PowerShell cmdlets to validate before syncing

### Common Editing Patterns

#### Adding Test Steps

```yaml
steps:
  - stepNumber: 1
    action: "First action"
    expectedResult: "Expected result"
  - stepNumber: 2
    action: "Second action"
    expectedResult: "Another result"
```

#### Adding Attachments

```yaml
steps:
  - stepNumber: 3
    action: "Take screenshot"
    expectedResult: "Screenshot captured"
    attachments:
      - path: "./screenshots/step3-result.png"
        azureId: ""
```

#### Using Custom Fields

```yaml
customFields:
  severity: "High"
  testType: "Functional"
  browserSupport: "Chrome, Firefox, Safari"
```

## PowerShell Automation (Optional)

While direct YAML editing is the primary method, PowerShell cmdlets are available for automation and bulk operations.

### Creating from Template

```powershell
# Create a basic test case template
New-TcmTestCase -Id "TC003" -Title "Template Test Case"
```

### Bulk Operations

```powershell
# Create multiple test cases at once
$testCases = @(
    @{ Id = "TC004"; Title = "Test Case 4" },
    @{ Id = "TC005"; Title = "Test Case 5" }
)

foreach ($tc in $testCases) {
    New-TcmTestCase -Id $tc.Id -Title $tc.Title
}
```

### Converting Existing Files

```powershell
# Import and modify existing test case
$existing = Get-TcmTestCase -Id "TC001"
# Edit the YAML file directly, then sync
```

## Best Practices

### Writing Effective Test Cases

- **Clear titles**: Make test case purpose obvious from the title
- **Detailed steps**: Break down complex actions into clear, sequential steps
- **Measurable results**: Write expected results that can be clearly verified
- **Preconditions**: Document any required setup or prerequisites
- **Consistent formatting**: Use consistent YAML structure across all files

### Organization

- **Logical grouping**: Group related test cases in subdirectories
- **Naming consistency**: Use consistent ID prefixes and naming patterns
- **Version control**: Commit YAML files to track changes over time
- **Documentation**: Include comments in YAML for complex test cases

### Quality Assurance

- **Peer review**: Have other team members review test case YAML files
- **Validation**: Use YAML validators to check syntax
- **Testing**: Test sync operations before committing to Azure DevOps
- **Updates**: Keep test cases current as requirements change

## Troubleshooting

### Common YAML Issues

- **Indentation errors**: Ensure consistent 2-space indentation
- **Missing quotes**: Quote strings containing special characters
- **Invalid characters**: Avoid tabs, use spaces only
- **Syntax validation**: Use online YAML validators for complex files

### File Organization Issues

- **Path separators**: Use forward slashes (/) in file paths, backslashes (\\) in Azure DevOps paths
- **Case sensitivity**: YAML is case-sensitive, be consistent
- **Encoding**: Save files as UTF-8 without BOM

### Sync Issues

- **ID conflicts**: Ensure unique IDs across all test case files
- **Path validation**: Verify area and iteration paths exist in Azure DevOps
- **Permissions**: Ensure PAT has work item create/edit permissions

## Next Steps

Once you've created test cases:

- [Learn about folder organization](03-folder-organization.md)
- [Set up synchronization with Azure DevOps](04-sync-workflows.md)
- [Handle sync conflicts](05-conflict-resolution.md)
