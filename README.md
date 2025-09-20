# AzureDevOpsApi

AzureDevOpsApi is a PowerShell module that provides a thin, well-tested wrapper around the Azure DevOps REST APIs. It focuses on making common automation tasks straightforward from PowerShell scripts and pipelines: querying and updating work items, inspecting repositories and commits, enumerating pull requests, and generating release notes in Excel or Markdown formats.

Key features:

- Query work items and work item relations.
- List and inspect repositories, commits and diffs.
- Retrieve pull requests and their statuses.
- Export release notes data to Excel and Markdown.

Compatibility:

- PowerShell 7.4+ (cross-platform) is recommended. Many cmdlets will also work on Windows PowerShell 5.1.
- Supports Azure DevOps Services (dev.azure.com) and on-premises Azure DevOps Server (with appropriate API compatibility).

## Quick links

- [Documentation overview](./Docs/readme.md)
- [Functions reference](./Docs/functions/)

## Quick start

First, you need to install the module.

```powershell
# Install from the PowerShell Gallery
Install-Module -Name AzureDevOpsApi
```

Import the module into your session.

```powershell
# Import the module into your session
Import-Module -Name AzureDevOpsApi
```

Set the default connection parameters for the current session. For brevity, this example uses a Personal Access Token (PAT) for authentication.

```powershell
# Set defaults for your organization and project
Set-ApiVariables -CollectionUri 'https://dev.azure.com/my-org' -Project 'MyProject' -Authorization 'PAT' -Token 'my-personal-access-token'
```

Example usage

```powershell
# Get a work item by ID (uses session defaults when not specified)
Get-WorkItem -WorkItem 123

# Export release notes
Export-ReleaseNotesFromGitToExcel -Repository 'MyRepo' -FromDate '2025-12-15' -ToDate '2025-12-31'
```

License

- [EUPL-1.2](LICENSE.txt)
