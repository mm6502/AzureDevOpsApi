# Creating a Personal Access Token (PAT)

Personal Access Tokens (PATs) are the recommended way to authenticate with Azure DevOps APIs. This guide walks you through creating a PAT token for use with the AzureDevOpsApi PowerShell module.

## Why Use PAT Tokens?

**Advantages:**

- ✅ More secure than username/password
- ✅ Can be scoped to specific permissions
- ✅ Can have expiration dates
- ✅ Can be revoked without changing your password
- ✅ Works with all Azure DevOps authentication scenarios

**Compared to alternatives:**

- **Windows Authentication**: Only works on Windows with domain accounts
- **Basic Authentication**: Less secure, requires password storage

## Step-by-Step Guide

### 1. Navigate to PAT Management

1. Open your Azure DevOps organization: `https://dev.azure.com/{your-organization}`
2. Click your **profile icon** in the top right corner
3. Select **Personal access tokens** from the dropdown menu

   ![Profile Menu](https://docs.microsoft.com/en-us/azure/devops/media/user-guide/profile-menu.png)

### 2. Create New Token

1. Click **+ New Token** button
2. Fill in the token details:

   **Name**: Give your token a descriptive name
   - Example: `AzureDevOpsApi-PowerShell`
   - Example: `TestCaseManagement-Dev`
   - Example: `ReleaseNotes-Automation`

   **Organization**: Select your organization (or "All accessible organizations")

   **Expiration**: Choose an expiration period
   - 7 days (for testing)
   - 30 days (for short-term projects)
   - 90 days (recommended for active development)
   - Custom date (for specific needs)
   - ⚠️ **Note**: Tokens expire automatically for security

### 3. Set Required Permissions

**For General Work Item Operations:**

- ✅ **Work Items**: Read & write

**For TestCaseManagement:**

- ✅ **Work Items**: Read & write

**For Release Notes Generation:**

- ✅ **Work Items**: Read & write
- ✅ **Code**: Read (if using git commit references)
- ✅ **Build**: Read (if referencing build artifacts)

**For Project/Collection Management:**

- ✅ **Project and Team**: Read
- ✅ **Graph**: Read (optional, for user/group lookups)

**Minimal Permissions:**

- At minimum, select **Work Items: Read & write**
- Add additional scopes as needed for your use case

### 4. Generate and Copy Token

1. Click **Create** button
2. **Important**: Copy the token immediately!

   ```text
   ⚠️ You will NOT be able to see the token again after closing this dialog
   ```

3. Store the token securely (see storage options below)

## Storing Your PAT Token

### Option 1: Environment Variable (Recommended)

**PowerShell (Current Session):**

```powershell
$env:AZURE_DEVOPS_PAT = "your-token-here"
```

**PowerShell (Persistent - User Scope):**

```powershell
[Environment]::SetEnvironmentVariable(
    "AZURE_DEVOPS_PAT",
    "your-token-here",
    [EnvironmentVariableTarget]::User
)
```

**PowerShell Profile (Loads on every session):**

```powershell
# Add to $PROFILE
$env:AZURE_DEVOPS_PAT = "your-token-here"
```

**Verify:**

```powershell
$env:AZURE_DEVOPS_PAT
```

### Option 2: Azure Key Vault (Production)

For production environments or CI/CD pipelines:

```powershell
# Install Azure PowerShell module
Install-Module -Name Az.KeyVault

# Connect to Azure
Connect-AzAccount

# Store token in Key Vault
Set-AzKeyVaultSecret `
    -VaultName "MyVault" `
    -Name "AzureDevOpsPAT" `
    -SecretValue (ConvertTo-SecureString "your-token" -AsPlainText -Force)

# Retrieve token in scripts
$secret = Get-AzKeyVaultSecret -VaultName "MyVault" -Name "AzureDevOpsPAT"
$token = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
```

### Option 3: Configuration Files (Not Recommended)

If you must store in files:

```yaml
# .tcm-config.yaml (for TestCaseManagement)
collectionUri: https://dev.azure.com/myorg
project: MyProject
pat: ${env:AZURE_DEVOPS_PAT}  # ✅ Reference environment variable
# pat: actual-token-here       # ❌ Never hardcode tokens!
```

**Important:**

- Always use environment variable references (`${env:VARIABLE}`)
- Add config files with tokens to `.gitignore`
- Never commit tokens to version control

## Using Your PAT Token

### With Set-ApiVariables (Default Connection)

```powershell
# Using environment variable
Set-ApiVariables `
    -CollectionUri 'https://dev.azure.com/myorg' `
    -Project 'MyProject' `
    -Authorization 'PAT' `
    -Token $env:AZURE_DEVOPS_PAT
```

### With Add-ApiCredential (Multiple Connections)

```powershell
# Add multiple organization credentials
Add-ApiCredential `
    -CollectionUri 'https://dev.azure.com/org1' `
    -Project 'Project1' `
    -Authorization 'PAT' `
    -Token $env:AZURE_DEVOPS_PAT_ORG1

Add-ApiCredential `
    -CollectionUri 'https://dev.azure.com/org2' `
    -Project 'Project2' `
    -Authorization 'PAT' `
    -Token $env:AZURE_DEVOPS_PAT_ORG2
```

### With TestCaseManagement

```powershell
# .tcm-config.yaml
collectionUri: https://dev.azure.com/myorg
project: MyProject
pat: ${env:AZURE_DEVOPS_PAT}

# PowerShell
$env:AZURE_DEVOPS_PAT = "your-token"
Get-TcmTestCase  # Automatically uses token from config
```

## Security Best Practices

### ✅ DO:

- Store tokens in environment variables or secure vaults
- Use separate tokens for different purposes (dev, prod, CI/CD)
- Set appropriate expiration dates (30-90 days)
- Use minimal required permissions (principle of least privilege)
- Rotate tokens regularly
- Revoke unused or compromised tokens immediately
- Use Azure Key Vault for production environments

### ❌ DON'T:

- Hardcode tokens in scripts or configuration files
- Commit tokens to version control (git, etc.)
- Share tokens with others (each user should have their own)
- Use the same token across all environments
- Store tokens in plain text files
- Give tokens full access when limited scope is sufficient
- Leave tokens without expiration dates

## Troubleshooting

### Error: 401 Unauthorized

**Causes:**

1. Token has expired
2. Token is invalid or malformed
3. Token not properly passed to cmdlet

**Solutions:**

```powershell
# Check if token is set
$env:AZURE_DEVOPS_PAT

# Test token manually
$headers = @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$env:AZURE_DEVOPS_PAT"))
}
Invoke-RestMethod -Uri "https://dev.azure.com/myorg/_apis/projects" -Headers $headers

# Regenerate token if expired (see step 2 above)
```

### Error: 403 Forbidden

**Cause:** Token doesn't have required permissions

**Solution:**

1. Go to Azure DevOps → Personal Access Tokens
2. Find your token and click **Edit**
3. Add missing permissions (e.g., "Work Items: Read & write")
4. Click **Save**
5. No need to regenerate the token, changes apply immediately

### Token Expired

**Solution:**

1. Go to Azure DevOps → Personal Access Tokens
2. Find your token
3. If expired, you must create a new token (cannot extend expired tokens)
4. Update your environment variable or configuration with new token

### Lost Token

If you forgot to copy the token:

1. You cannot retrieve the original token value
2. You must **regenerate** the token (creates new value)
3. Or create a new token entirely
4. Update all scripts/configs using the old token

## Managing Multiple Tokens

For complex scenarios with multiple organizations, use separate environment variables and the module's built-in credential management:

```powershell
# Store organization-specific tokens
$env:PAT_ORG1 = "token-for-org1"
$env:PAT_ORG2 = "token-for-org2"

# Add credentials for multiple organizations
Add-ApiCredential `
    -CollectionUri 'https://dev.azure.com/org1' `
    -Project 'Project1' `
    -Authorization 'PAT' `
    -Token $env:PAT_ORG1

Add-ApiCredential `
    -CollectionUri 'https://dev.azure.com/org2' `
    -Project 'Project2' `
    -Authorization 'PAT' `
    -Token $env:PAT_ORG2

# Set one as default
Set-ApiVariables `
    -CollectionUri 'https://dev.azure.com/org1' `
    -Project 'Project1' `
    -Authorization 'PAT' `
    -Token $env:PAT_ORG1

# Usage - defaults to Org1
Get-WorkItem 123

# Usage - explicitly specify Org2
Get-WorkItem 456 `
    -CollectionUri 'https://dev.azure.com/org2' `
    -Project 'Project2'
```

For more examples of managing multiple credentials, see [Managing Multiple Credentials](./01-multiple-credentials.md).## Revoking Tokens

If a token is compromised or no longer needed:

1. Go to Azure DevOps → Personal Access Tokens
2. Find the token in the list
3. Click **Revoke** (or **...** menu → **Revoke**)
4. Confirm revocation
5. Token is immediately invalidated (cannot be undone)

## Token Rotation Strategy

For production environments:

1. **Create new token** before old one expires
2. **Update non-critical systems** with new token first
3. **Test** that new token works
4. **Update critical systems** with new token
5. **Revoke old token** after grace period (e.g., 7 days)
6. **Document** the rotation in your change log

## Additional Resources

- [Azure DevOps PAT Documentation](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
- [Credential Management Examples](./01-multiple-credentials.md)
- [Module Authentication Functions](../functions/Set-ApiVariables.md)

## Related Examples

- [Managing Multiple Credentials](./01-multiple-credentials.md)
- [TestCaseManagement Setup](../test-case-management/01-setup-configuration.md)
- [Basic Usage Quick Start](../basic-usage/01-quick-start.md)
