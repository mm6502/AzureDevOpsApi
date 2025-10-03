# Quick Start Example

This example demonstrates the basic usage of the AzureDevOpsApi module to query a work item.

## Prerequisites

- AzureDevOpsApi module installed
- Valid Azure DevOps credentials (PAT token or Windows credentials)

## Example

```powershell
Import-Module AzureDevOpsApi

# Set the variables for the Azure DevOps collection and project.
# Windows default credentials are used when not specified.
Set-ApiVariables `
    -Collection 'https://dev.azure.com/my-org/my-project' `
    -Project 'Project42'

# Get work item by ID
Get-WorkItem 123
```

## Expected Output

```text
id        : 123
rev       : 42
fields    : @{System.AreaPath=MyProject; System.TeamProject=MyProject; System.IterationPath=MyProject;...}
relations : {@{rel=System.LinkTypes.Related; url=https://dev.azure.com/my-org/cca29da0-0985-4714-bf09-...}
_links    : @{self=; workItemUpdates=; workItemRevisions=; workItemComments=; html=; workItemType=; fi...}
url       : https://dev.azure.com/my-org/cca29da0-0985-4714-bf09-eed3dfc290ea/_apis/wit/workItems/123
```

## Notes

- The `Set-ApiVariables` cmdlet sets default connection parameters for the current session
- These defaults are used by all subsequent API calls unless explicitly overridden
- When not specifying authorization parameters, Windows default credentials are used
