# Setting Up TestCaseManagement Configuration

## Overview

Before using TestCaseManagement features, you need to create a configuration file that defines your Azure DevOps connection settings, sync preferences, and default values for test cases.

## Prerequisites

- Azure DevOps organization and project
- Personal Access Token (PAT) with work item read/write permissions
- PowerShell with AzureDevOpsApi module loaded

## Basic Configuration Setup

### 1. Create Configuration File

```powershell
# Import the module
Import-Module AzureDevOpsApi

# Create basic configuration
New-TcmConfig -CollectionUri "https://dev.azure.com/your-org" -Project "YourProject"
```

This creates a `.tcm-config.yaml` file in the current directory with:

```yaml
azureDevOps:
  collectionUri: "https://dev.azure.com/your-org"
  project: "YourProject"
  pat: "${AZURE_DEVOPS_PAT}"  # Environment variable placeholder

sync:
  direction: "bidirectional"
  conflictResolution: "manual"

testCase:
  defaultAreaPath: "YourProject"
  defaultIterationPath: "YourProject"
  defaultState: "Design"
  defaultPriority: 2
```

### 2. Set Environment Variable

```powershell
# Set your Personal Access Token
$env:AZURE_DEVOPS_PAT = "your-personal-access-token-here"
```

### 3. Verify Configuration

```powershell
# Test the configuration by getting test cases (should return empty if no test cases exist)
Get-TcmTestCase
```

## Advanced Configuration

### Custom Directory Location

```powershell
# Create config in a specific directory
New-TcmConfig `
    -CollectionUri "https://dev.azure.com/your-org" `
    -Project "YourProject" `
    -OutputPath "C:\MyTestCases" `
    -Force
```

### On-Premises Azure DevOps Server

```powershell
# For Azure DevOps Server (on-premises)
New-TcmConfig `
    -CollectionUri "https://tfs.yourcompany.com/tfs/DefaultCollection" `
    -Project "YourProject"
```

### Custom Default Values

After creating the config file, you can edit `.tcm-config.yaml` to customize defaults:

```yaml
azureDevOps:
  collectionUri: "https://dev.azure.com/your-org"
  project: "YourProject"
  pat: "${AZURE_DEVOPS_PAT}"

sync:
  direction: "bidirectional"
  conflictResolution: "local-wins"  # Changed from default "manual"

testCase:
  defaultAreaPath: "YourProject\\Development\\Testing"
  defaultIterationPath: "YourProject\\Sprint 1"
  defaultState: "Ready"
  defaultPriority: 3
```

## Configuration File Location

TestCaseManagement searches for `.tcm-config.yaml` starting from the current directory and moving up parent directories. This means:

- Place the config file in your test cases root directory
- Or place it in a parent directory to share configuration across multiple test case folders
- The search stops at the first `.tcm-config.yaml` file found

## Security Best Practices

- Never commit PATs to version control
- Use environment variables for sensitive credentials
- Consider using Azure Key Vault or other secret management for production scenarios
- Regularly rotate Personal Access Tokens

## Troubleshooting

### Configuration Not Found

```
New-TcmTestCase : Configuration file not found. Please run New-TcmConfig first.
```

**Solution**: Run `New-TcmConfig` in the appropriate directory.

### Invalid Azure DevOps URL

```
Get-TcmTestCase : Unable to connect to Azure DevOps. Please check your configuration.
```

**Solution**: Verify the `collectionUri` and `project` in `.tcm-config.yaml`.

### Authentication Failed

```
Sync-TcmTestCase : Authentication failed. Please check your Personal Access Token.
```

**Solution**:
1. Verify `$env:AZURE_DEVOPS_PAT` is set correctly
2. Ensure the PAT has appropriate permissions (Work Items: Read & Write)
3. Check PAT expiration date

## Next Steps

Once configuration is complete, you can:
- [Create your first test case](02-creating-test-cases.md)
- [Learn about folder organization](03-folder-organization.md)
- [Set up sync workflows](04-sync-workflows.md)
