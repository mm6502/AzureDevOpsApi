# AzureDevOpsApi

AzureDevOpsApi is a PowerShell module that provides a thin, well-tested wrapper
around the Azure DevOps REST APIs. It focuses on making common automation tasks
straightforward from PowerShell scripts and pipelines: querying and updating
work items, inspecting repositories and commits, enumerating pull requests,
and generating release notes in Excel or Markdown formats.

Key features:

- Query work items and work item relations.
- List and inspect repositories, commits and diffs.
- Retrieve pull requests and their statuses.
- Export release notes data to Excel and Markdown.

Compatibility:

- PowerShell 7.4+ (cross-platform) is recommended. Many cmdlets will also work
on Windows PowerShell 5.1.
- Supports Azure DevOps Services (dev.azure.com) and on-premises Azure DevOps
Server (with appropriate API compatibility).

## Quick links

- [Documentation overview](./Docs/readme.md)
- [Functions reference](./Docs/functions/)

## Quick start

Install the module from the PowerShell Gallery (this is a one-time step).

```powershell
Install-Module -Name AzureDevOpsApi
```

Import the module into your session.

```powershell
Import-Module -Name AzureDevOpsApi
```

Set the default connection parameters for the current session. For brevity,
this example uses a Personal Access Token (PAT) for authorization.

```powershell
Set-ApiVariables `
    -CollectionUri 'https://dev.azure.com/my-org' `
    -Project 'MyProject' `
    -Authorization 'PAT' `
    -Token 'my-personal-access-token'
```

Then getting a work item by ID (uses session defaults for CollectionUri, Project and Authorization)

```powershell
Get-WorkItem 123
```

should write out plain work item object as returned from the Azure DevOps REST API

<pre style="white-space: pre; text-overflow: ellipsis; overflow: hidden;">
id        : 123
rev       : 42
fields    : @{System.AreaPath=MyProject; System.TeamProject=MyProject; System.IterationPath=MyProject;...}
relations : {@{rel=System.LinkTypes.Related; url=https://dev.azure.com/my-org/cca29da0-0985-4714-bf09-...}
_links    : @{self=; workItemUpdates=; workItemRevisions=; workItemComments=; html=; workItemType=; fi...}
url       : https://dev.azure.com/my-org/cca29da0-0985-4714-bf09-eed3dfc290ea/_apis/wit/workItems/123
</pre>

For more examples, see the [documentation overview](./Docs/readme.md).

License

- [EUPL-1.2](LICENSE.txt)
