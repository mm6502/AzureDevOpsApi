# Principles

The module operates on credential-based authorization, allowing both Windows
default credentials, username / password credentials and API tokens. It
maintains a centralized configuration through global variables that can be set
once and reused across function calls, while the session lasts. The module
follows a hierarchical approach to data handling, where work items, pull
requests, and their relationships are tracked and can be exported in various
formats. It emphasizes reusability by allowing parameters to be passed down
through the call chain while providing sensible defaults when not specified.

The module also includes comprehensive retry logic to handle transient failures
and ensure resilient API operations.
Read more in [Retry Logic and Resilience](retry_logic.md).

## Authorization (REST API)

This module calls the Azure DevOps REST API, which supports several authorization
methods depending on whether you're using Azure DevOps Services (cloud) or
Azure DevOps Server (on-premises). Below is a concise reference of supported
options and practical guidance.

When no specific credentials are provided, the module defaults to using users'
default network credentials on Windows.

- Personal Access Tokens (PAT)
  - Supported by both cloud and on-prem. Recommended for scripts and automation
    due to simplicity.
  - Use least-privilege scopes and short lifetimes where possible. Store PATs in
    a secret store or environment variables; never hard-code them.
  - Azure Pipelines exposes a scoped token (System.AccessToken) that can be
    used as a PAT token in CI jobs. Treat it as a short-lived secret.
  - Using a PAT translates to adding a HTTP Basic auth header to all API calls:

    ```http
    Authorization: Basic BASE64(:<PAT>)
    ```

- Windows Integrated (NTLM / Kerberos)
  - Primarily for Azure DevOps Server (on-prem). When running on a domain-joined
    machine, the module can use the current user's default network credentials
    (Negotiate/NTLM) without setting an Authorization header. This is convenient
    for interactive use and scheduled tasks running as domain accounts.

- Username / password and alternate credentials
  - Username/password basic auth is supported on some on-prem servers. Alternate
    credentials for cloud accounts have been deprecated — avoid using them.

- OAuth / Azure AD (Bearer tokens, not tested)
  - Cloud-first option for apps and integrations. Azure AD / OAuth issues
    access tokens which are sent as Bearer tokens:

    ```http
    Authorization: Bearer <access_token>
    ```

## How does it work?

The module uses a credential cache system where API credentials can be
registered using [Set-ApiVariables](./functions/Set-ApiVariables.md) or
[Add-ApiCredential](./functions/Add-ApiCredential.md) functions. The cache is
stored in a global variable and lasts for the duration of the PowerShell session.
Secrets are stored in memory only as a secure string and not persisted to disk.

When making API calls, the collection Uri and project are matched with the
appropriate cached credentials. This allows working with:

- using different credentials for different projects
- multiple Azure DevOps collections simultaneously.

For convenience, the CollectionUri and Project can have default values set
via [Set-ApiVariables](./functions/Set-ApiVariables.md). These defaults
are later used when the CollectionUri and Project are not specified.

## Naming conventions for functions

The module employs a deliberate naming convention that deviates from typical
PowerShell cmdlet patterns. While standard PowerShell cmdlets use
a `Verb-SingularNoun` pattern (like `Get-Process`), this module often
includes "List" in function names (e.g., `Get-ProjectsList` vs `Get-Project`)
to explicitly communicate the shape and intent of the returned data. This
distinction helps reduce ambiguity when chaining functions or writing scripts
that depend on receiving either a collection of (usually simplified) objects
or a (usually single) detailed object(s).

This naming approach directly reflects the underlying Azure DevOps REST API
structure, which provides different representations of the same resources with
varying levels of detail. The "List" variants typically return lightweight
objects with fewer properties (suitable for enumeration and quick lookups),
while the standard variants return richly detailed objects with additional
metadata, links, and related entities. By incorporating this distinction
into function names, the module makes it immediately clear which
representation is being requested or consumed.

## Function parameters

Most module functions accept parameters for `CollectionUri`, `Project`. These
parameters are optional in most cases, as the module maintains global defaults
(set via [Set-ApiVariables](./functions/Set-ApiVariables.md)) for
convenience and scriptability. When not explicitly provided, functions will
use the cached or default values, allowing for concise calls in interactive
and automation scenarios.

- **CollectionUri**: Specifies the Azure DevOps collection endpoint. If omitted,
the module uses the globally set default.
- **Project**: Identifies the Azure DevOps project. If not provided, the default
project (if set) is used.

This design enables seamless switching between multiple collections or projects
within the same session, and supports scenarios where different credentials are
required for different resources.

## `InputObject` parameter

Some functions support a generic `InputObject` parameter (although, it may be
named otherwise). This parameter is intentionally flexible: it can accept
a single object, an array of objects, or even simple identifiers (such as an
integer or url of given resource). For example, `Get-WorkItem` allows you to
pass either a work item object, an array of such objects, the work item ID(s)
or url(s). The function will internally resolve the appropriate details as
needed.

This approach streamlines scripting and pipelining, as you can pass objects
directly from one function to another without needing to extract or reformat
their identifiers. It also enables concise one-liners and supports advanced
scenarios where objects are filtered or transformed before being passed to
subsequent functions.
