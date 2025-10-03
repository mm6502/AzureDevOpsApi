# Work Items and Relationships Examples

This section contains detailed examples of how work items and their relationships are tracked in Azure DevOps for release notes generation.

## Overview

The AzureDevOpsApi module automatically discovers and tracks work item relationships when generating release notes. Understanding these relationships is crucial for proper work item management and accurate release notes.

## Background

The module follows the **CMMI process template** conventions for work item relationships. Key relationship types include:

- **Parent-Child**: Hierarchical relationships (Feature → Requirement → Task)
- **Tests / TestedBy**: Test Case relationships with requirements and bugs
- **Affects / AffectedBy**: Impact relationships between requirements
- **Predecessor / Successor**: Sequential dependencies when requirements are replaced

For complete background, see:

- [Work Methodology](../../methodology/work-methodology.md) - Process overview and relationship diagrams
- [CMMI Process Template](https://learn.microsoft.com/en-us/azure/devops/boards/work-items/guidance/cmmi-process?view=azure-devops) - Microsoft documentation

## Detailed Examples

The methodology documentation contains comprehensive examples with diagrams showing how work items are collected:

### [Feature 1](../../methodology/feature-1.md)

**Demonstrates:**

- Basic work item types (Feature, Requirement, Task, Test Case, Bug, Change Request)
- Parent-Child relationships
- Tests / TestedBy relationships
- Affects / AffectedBy relationships

**Key Scenarios:**

- How Test Cases affect release notes inclusion
- Impact of the Tests / TestedBy relationship on data collection
- Cross-requirement relationships with Affects / AffectedBy

### [Feature 2.1](../../methodology/feature-2.1.md)

**Demonstrates:**

- Predecessor / Successor relationships
- **Incorrect pattern**: Forgotten Test Case linked to predecessor

**Key Scenarios:**

- What happens when a requirement is replaced
- How predecessor relationships pull in successor requirements
- Common mistake: Not updating Test Case links when creating successors

### [Feature 2.2](../../methodology/feature-2.2.md)

**Demonstrates:**

- Predecessor / Successor relationships
- **Correct pattern**: Test Case properly re-linked to successor

**Key Scenarios:**

- Proper handling of requirement replacement
- How to correctly update Test Case relationships
- Impact on release notes when relationships are properly maintained

## Practical Usage

When working with these relationship patterns:

1. **Start from commits**: Release notes typically begin with work items associated with commits or pull requests
2. **Follow relationships**: The module automatically follows configured relationship types
3. **Track reasons**: Each work item tracks why it was included (PullRequest, Parent, Tests, etc.)
4. **Review relationships**: The output shows all relationships between collected work items

## Example Integration

See how these patterns are used in practice:

- [Basic Release Notes Workflow](../release-notes/01-basic-workflow.md) - Using `Add-WorkItemToReleaseNotesData`
- [Full Script Example](../release-notes/02-full-script.md) - Complete release notes generation

## Notes

- Numbers in brackets in methodology examples indicate creation order
- Release notes generation starts from work items associated with commits
- Relationships are tracked directionally (as shown by arrows in diagrams)
- Parent-Child relationships are shown as dashed lines in diagrams
- Related relationships are never tracked automatically
