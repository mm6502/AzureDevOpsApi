# Managing Multiple Credentials

This example shows how to set up and use credentials for different Azure DevOps collections and projects within the same PowerShell session.

## Overview

The AzureDevOpsApi module supports:

- Setting default credentials for a collection and project
- Adding credentials for multiple collections and projects
- Automatic credential selection based on context

## Example

```powershell
# Set default CollectionUri and Project
Set-ApiVariables `
    -CollectionUri 'https://dev.azure.com/my-org1' `
    -Project 'MyProject1' `
    -Authorization 'PAT' `
    -Token 'my-token1'

# Add credentials for another collection and project
Add-ApiCredential `
    -CollectionUri 'https://dev.azure.com/other-org2' `
    -Project 'OtherProject2' `
    -Authorization 'PAT' `
    -Token 'other-token2'

# Get work item by ID from default collection and project
# Note: the CollectionUri and Project are determined from the defaults
Get-WorkItem 123

# Get work item by ID from another collection and project
# Note: the CollectionUri and Project must be specified
Get-WorkItem 234 `
    -CollectionUri 'https://dev.azure.com/other-org2' `
    -Project 'OtherProject2'

# Get work items by their urls
# Note: the CollectionUri and Project are determined from the url
# API URL
Get-WorkItem 'https://dev.azure.com/my-org1/MyProject1/_apis/wit/workitems/123'
# Portal URL can be used as well
Get-WorkItem 'https://dev.azure.com/my-org1/MyProject1/_workitems/edit/123'
```

## Key Points

1. **Default Credentials**: Use `Set-ApiVariables` to set the default collection and project for the session
2. **Additional Credentials**: Use `Add-ApiCredential` to add credentials for other collections/projects
3. **Implicit Selection**: When you don't specify CollectionUri/Project, defaults are used
4. **Explicit Selection**: Specify CollectionUri and Project parameters to use different credentials
5. **URL-based Selection**: When passing a work item URL, credentials are automatically selected based on the URL

## Authorization Methods

The module supports multiple authorization methods:

- **PAT** (Personal Access Token) - Recommended for most scenarios
- **Windows** - Windows integrated authentication
- **Basic** - Username and password (less secure, not recommended)
