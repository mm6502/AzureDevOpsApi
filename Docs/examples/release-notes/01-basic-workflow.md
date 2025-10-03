# Basic Release Notes Workflow

This example demonstrates how to collect work items and their relationships for release notes using the `Add-WorkItemToReleaseNotesData` cmdlet.

## Overview

The module can automatically collect work items and their relationships (parent-child, tests, affects, etc.) starting from a set of work item IDs. This is particularly useful when work items are associated with commits or pull requests.

## Example

```powershell
Import-Module AzureDevOpsApi

# Set the variables for the Azure DevOps collection and project.
# Windows default credentials are used when not specified.
Set-ApiVariables `
    -Collection 'https://dev.azure.com/my-org/my-project' `
    -Project 'Project42'

# Assuming the work item ids came from a pull request.
$workItemIds = @(373872, 373877, 373870)
Add-WorkItemToReleaseNotesData `
    -Reason 'PullRequest' `
    -WorkItemId $workItemIds `
| Format-Table 'WorkItemId', 'WorkItemType', 'Reasons', 'Relations'
```

## Expected Output

```text
WorkItemId WorkItemType Reasons                         Relations
---------- ------------ -------                         ---------
373872     Task         PullRequest                     Child (#373871)
373877     Task         PullRequest                     Child (#373875)
373870     Task         PullRequest                     Child (#373863)
373871     Bug          PullRequest, Parent             Parent (#373872), TestedBy (#373869)
373875     Requirement  PullRequest, Parent             Parent (#373877), Child (#373862), Affects (#373863)
373863     Requirement  PullRequest, Parent, AffectedBy Parent (#373870), TestedBy (#373869), Child (#373862)
373869     Test Case    PullRequest, Tests              Tests (#373871)
373862     Feature      PullRequest, Parent             Parent (#373875)
```

## Key Features

1. **Automatic Relationship Discovery**: The cmdlet automatically follows relationships and collects related work items
2. **Multiple Reasons**: Work items can be included for multiple reasons (e.g., directly from PR and as a parent)
3. **Relationship Tracking**: All relationships between collected work items are tracked and displayed

## Understanding the Output

- **WorkItemId**: The unique identifier of the work item
- **WorkItemType**: The type of work item (Task, Bug, Requirement, Feature, Test Case, etc.)
- **Reasons**: Why this work item was included (PullRequest, Parent, Tests, AffectedBy, etc.)
- **Relations**: Related work items and their relationship types

## Next Steps

- See [Full Script Example](./02-full-script.md) for a complete release notes generation workflow
- See [Work Items Methodology](../work-items/readme.md) for detailed examples of work item relationships
