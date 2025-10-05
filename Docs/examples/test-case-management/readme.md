# TestCaseManagement Examples

This section contains practical examples for using the TestCaseManagement feature to author and synchronize test cases with Azure DevOps using YAML files.

## Overview

TestCaseManagement enables user-friendly authoring of test cases through direct YAML file editing. Create and edit test case files in any text editor, then synchronize them with Azure DevOps. This approach provides:

- **Human-readable format**: YAML files are easy to read, write, and version control
- **Rich editing experience**: Use your favorite editor with syntax highlighting and validation
- **Offline authoring**: Create test cases without Azure DevOps connectivity
- **Version control friendly**: Track changes and collaborate using git
- **Direct editing**: No complex commands - just edit YAML files like any other document
- **Comprehensive documentation**: Step-by-step examples covering all features and scenarios

## Key Concepts

### Direct YAML File Editing

**Primary Method**: Test cases are authored by directly editing YAML files in your preferred text editor. This is the main workflow for creating and maintaining test cases.

### YAML Structure

Test cases use a structured YAML format that maps directly to Azure DevOps work item fields:

```yaml
testCase:
  id: TC001
  title: "User Login Validation"
  areaPath: "Project\\Area\\Component"
  steps:
    - stepNumber: 1
      action: "Navigate to login page"
      expectedResult: "Login form is displayed"
```

### Configuration File

A `.tcm-config.yaml` file defines connection settings, sync preferences, and defaults:

```yaml
azureDevOps:
  collectionUri: "https://dev.azure.com/your-org"
  project: "YourProject"
  pat: "${AZURE_DEVOPS_PAT}"

sync:
  direction: "bidirectional"
  conflictResolution: "manual"
```

### Folder Organization

Test cases are organized in a hierarchical folder structure that can be customized:

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

## Getting Started

### Prerequisites

- Azure DevOps organization and project
- Personal Access Token with work item permissions
- PowerShell with AzureDevOpsApi module

### Quick Start Workflow

1. **[Setup Configuration](./01-setup-configuration.md)** - Create `.tcm-config.yaml`
2. **[Create Test Cases](./02-creating-test-cases.md)** - Edit YAML files directly in your text editor
3. **[Organize Folders](./03-folder-organization.md)** - Structure your test case repository
4. **[Sync Operations](./04-sync-workflows.md)** - Push/pull changes with Azure DevOps
5. **[Handle Conflicts](./05-conflict-resolution.md)** - Resolve sync conflicts when they occur
6. **[Advanced Features](./06-advanced-scenarios.md)** - Use custom fields and bulk operations

## Detailed Examples

### [Setup Configuration](./01-setup-configuration.md)

**Learn how to:**

- Create and configure `.tcm-config.yaml`
- Set up Azure DevOps connection parameters
- Configure sync preferences and defaults
- Manage environment variables for credentials

**Essential first step for using TestCaseManagement.**

### [Creating Test Cases](./02-creating-test-cases.md)

**Learn how to:**

- Author test cases by editing YAML files directly
- Understand the complete YAML structure and schema
- Add test steps, preconditions, and expected results
- Include attachments, custom fields, and tags
- Use your favorite text editor with syntax highlighting

**Core workflow: Direct YAML file editing for user-friendly test case authoring.**

### [Folder Organization](./03-folder-organization.md)

**Learn how to:**

- Organize test cases in flexible folder structures
- Understand how folder organization affects sync operations
- Create nested folder hierarchies for different test types
- Move test cases between folders without breaking sync
- Implement organization patterns for teams and projects

**Best practices for structuring your test case repository.**

### [Sync Workflows](./04-sync-workflows.md)

**Learn how to:**

- Perform push operations to send local changes to Azure DevOps
- Execute pull operations to retrieve remote changes
- Implement bidirectional sync workflows
- Handle bulk synchronization of multiple test cases
- Monitor sync status and resolve common issues

**Complete guide to synchronizing test cases with Azure DevOps.**

### [Conflict Resolution](./05-conflict-resolution.md)

**Learn how to:**

- Detect synchronization conflicts between local and remote test cases
- Understand different conflict resolution strategies
- Use local-wins, remote-wins, and manual resolution approaches
- Handle common conflict scenarios (title changes, step modifications)
- Implement best practices for avoiding conflicts

**Essential skills for collaborative test case management.**

### [Advanced Scenarios](./06-advanced-scenarios.md)

**Learn how to:**

- Work with custom fields and organization-specific work item fields
- Perform bulk operations on multiple test cases
- Implement advanced integration patterns
- Handle parameterized test cases and shared test steps
- Optimize performance for large-scale operations

**Advanced techniques for power users and enterprise deployments.**

## Sync Operations

After authoring test cases through YAML file editing, use these cmdlets for synchronization with Azure DevOps:

- `Sync-TcmTestCase` - Bidirectional sync with conflict detection
- `Get-TcmTestCase` - Retrieve test cases from Azure DevOps
- `Resolve-TcmTestCaseConflict` - Handle sync conflicts

## Advanced Features

- **Custom Fields**: Support for organization-specific work item fields and metadata
- **Bulk Operations**: Process multiple test cases efficiently with batch processing
- **Conflict Resolution**: Manual, local-wins, remote-wins strategies with detailed examples
- **Attachment Sync**: Include screenshots and documents with test steps
- **Parameterized Tests**: Support for test case parameters and shared test steps
- **Performance Optimization**: Techniques for large-scale test case management
- **Integration Patterns**: Advanced Azure DevOps integration and automation

## Best Practices

- **Version Control**: Commit YAML files to git for change tracking
- **Naming Conventions**: Use consistent ID prefixes (TC001, TC002, etc.)
- **Regular Sync**: Keep local and remote test cases synchronized
- **Backup**: Maintain backups before major sync operations
- **Validation**: Use schema validation before syncing

## Troubleshooting

**Common Issues:**

- PAT permissions insufficient for work item operations
- YAML syntax errors preventing sync
- Path separators in area/iteration paths
- Environment variable not set for PAT

**Debugging:**

- Use `-Verbose` parameter on sync cmdlets
- Check Azure DevOps work item permissions
- Validate YAML with online parsers
- Review sync logs for detailed error information

## Related Documentation

- [Function Reference](../../functions/AzureDevOpsApi.md) - Complete cmdlet documentation
- [Azure DevOps REST API](https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items) - Work item API reference
