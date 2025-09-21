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
and ensure resilient API operations. Read more in [Retry Logic and Resilience](retry_logic.md).

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
registered using [Set-ApiVariables](functions\Set-ApiVariables.md) or
[Add-ApiCredential](functions\Add-ApiCredential.md) functions. The cache is
stored in a global variable and lasts for the duration of the PowerShell session.
Secrets are stored in memory only as a secure string and not persisted to disk.

When making API calls, the collection Uri and project are matched with the
appropriate cached credentials. This allows working with:

- using different credentials for different projects
- multiple Azure DevOps collections simultaneously.

For convenience, the CollectionUri and Project can have default values set
via [Set-ApiVariables](functions\Set-ApiVariables.md). These defaults
are later used when the CollectionUri and Project are not specified.


