# AzureDevOpsApi Powershell Module

## Description

This module provides functionality to interact with the Azure DevOps REST APIs.
It allows querying, creating and modifying work items and creating release notes.

## Principles

The module operates on credential-based authorization, allowing both Windows
default credentials, username / password credentials and API tokens. It
maintains a centralized configuration through global variables that can be set
once and reused across function calls, while the session lasts. The module
follows a hierarchical approach to data handling, where work items, pull
requests, and their relationships are tracked and can be exported in various
formats. It emphasizes reusability by allowing parameters to be passed down
through the call chain while providing sensible defaults when not specified.

Read more in [principles](principles.md).

## Work Items and Relations

The module provides comprehensive support for managing work items and their
relationships within Azure DevOps. You can create, update, and query work items,
as well as manage their links to other work items, such as parent-child relationships.
Read more in [methodology](./methodology/work-methodology.md).

## Examples

Comprehensive examples demonstrating common use cases are available in the [examples](./examples/readme.md):

- **[Basic Usage](./examples/basic-usage/01-quick-start.md)** - Getting started with the module
- **[Credentials Management](./examples/credentials/01-multiple-credentials.md)** - Working with multiple Azure DevOps instances
- **[Release Notes Generation](./examples/release-notes/)** - Automating release documentation
- **[Work Items and Relationships](./examples/work-items/readme.md)** - Understanding work item patterns
