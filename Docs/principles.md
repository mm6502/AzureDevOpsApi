# Principles

The module operates on credential-based authentication, allowing both Windows
default credentials, username / password credentials and API tokens. It
maintains a centralized configuration through global variables that can be set
once and reused across function calls. The module follows a hierarchical
approach to data handling, where work items, pull requests, and their
relationships are tracked and can be exported in various formats. It
emphasizes reusability by allowing parameters to be passed down through the
call chain while providing sensible defaults when not specified.

The module also includes comprehensive retry logic to handle transient failures
and ensure resilient API operations. Read more in [Retry Logic and Resilience](retry_logic.md).

## Credentials

The credentials can be either

- Windows default credentials,
- username / password credentials,
- Personal Access Tokens (PAT).

When no specific credentials are
provided, the module defaults to using Windows default credentials.

## How does it work?

The module uses a credential cache system where API credentials can be
registered using [Set-ApiVariables](functions\Set-ApiVariables.md) or
[Add-ApiCredential](functions\Add-ApiCredential.md) functions.

When making API calls, the collection Uri and project are matched with the
appropriate cached credentials. This allows working with:

- using different credentials for different projects
- multiple Azure DevOps collections simultaneously.

For convenience, the CollectionUri and Project can have set default values
via [Set-ApiVariables](functions\Set-ApiVariables.md). These defaults
are later used when the CollectionUri and Project are not specified.

## Example

This example shows how to set up credentials for different collections and
projects and use them in API calls.

``` powershell
# Set default CollectionUri and Project
Set-ApiVariables `
    -CollectionUri 'https://dev.azure.com/my-org1' `
    -Project 'MyProject1'
    -Authorization 'PAT' `
    -Token 'my-token1'

# Add credentials for another collection and project
Add-ApiCredential `
    -CollectionUri 'https://dev.azure.com/other-org2' `
    -Project 'OtherProject2' `
    -Authorization 'PAT' `
    -Token 'other-token2'

# Get work item by ID from default collection and project
# (Note: the CollectionUri and Project are determined from the defaults)
Get-WorkItem 123

# Get work item by ID from another collection and project
# (Note: the CollectionUri and Project must be specified)
Get-WorkItem 234 `
    -CollectionUri 'https://dev.azure.com/other-org2' `
    -Project 'OtherProject2'

# Get work items by their urls
# (Note: the CollectionUri and Project are determined from the url)
Get-WorkItem 'https://dev.azure.com/my-org1/MyProject1/_workitems/edit/123'
Get-WorkItem 'https://dev.azure.com/other-org2/OtherProject2/_workitems/edit/234'
```
