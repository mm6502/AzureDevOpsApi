# AzureDevOpsApi Examples

This directory contains practical examples demonstrating how to use the AzureDevOpsApi PowerShell module.

## Example Categories

| Category | Description | Complexity |
|----------|-------------|------------|
| Basic Usage | Quick start and fundamental operations | ⭐ Beginner |
| Credentials | Multi-instance credential management | ⭐⭐ Intermediate |
| Release Notes | Automated release notes generation | ⭐⭐⭐ Advanced |
| Work Items | Relationship patterns and methodology | ⭐⭐⭐ Advanced |

## Quick Navigation

### [Basic Usage](./basic-usage/01-quick-start.md)

Get started quickly with the module:

- Setting up connection parameters
- Querying work items
- Basic cmdlet usage

**Start here if you're new to the module.**

### [Credentials Management](./credentials/01-multiple-credentials.md)

Learn how to manage multiple Azure DevOps connections:

- Setting default credentials
- Working with multiple collections and projects
- Different authorization methods (PAT, Windows, Basic)
- URL-based credential selection

**Essential for working with multiple Azure DevOps instances.**

### [Release Notes Generation](./release-notes/)

Comprehensive examples for generating release notes:

- **[Basic Workflow](./release-notes/01-basic-workflow.md)** - Understanding `Add-WorkItemToReleaseNotesData`
- **[Full Script](./release-notes/02-full-script.md)** - Production-ready release notes script

**Perfect for automating release documentation.**

### [Work Items and Relationships](./work-items/readme.md)

Detailed examples of work item relationship patterns:

- Parent-Child relationships
- Tests / Tested By relationships
- Affects / Affected By relationships
- Predecessor / Successor relationships
- Common patterns and anti-patterns

**Critical for understanding how work items are collected for release notes.**

## Prerequisites

All examples assume:

- PowerShell 7.4+ (or Windows PowerShell 5.1 for most cmdlets)
- AzureDevOpsApi module installed
- Valid Azure DevOps credentials

## Additional Resources

- [Main README](../../../README.md) - Module overview and quick start
- [Documentation Overview](../readme.md) - Complete documentation
- [Function Reference](../functions/AzureDevOpsApi.md) - All available cmdlets
- [Principles](../principles.md) - Module design principles
- [Methodology](../methodology/work-methodology.md) - Work item methodology
