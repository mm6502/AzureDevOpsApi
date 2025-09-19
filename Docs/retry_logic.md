# Retry Logic and Resilience

The module includes comprehensive retry logic to handle transient failures that can occur when making API calls to Azure DevOps. This ensures your scripts are more resilient to network issues, temporary server problems, and rate limiting.

## Automatic Retry Behavior

By default, the module automatically retries failed requests that encounter:

- **Network timeouts** (408 Request Timeout)
- **Rate limiting** (429 Too Many Requests)
- **Server errors** (500, 502, 503, 504 status codes)
- **Transient network exceptions** (WebException, TimeoutException, etc.)

The module uses intelligent retry strategies:

- **Exponential backoff** - delays increase exponentially between retries
- **Jitter** - adds randomization to prevent thundering herd effects
- **Maximum delay caps** - prevents excessively long waits

## Configuring Retry Behavior

### Retry Conditions

The system automatically retries for:

#### HTTP Status Codes

- 408 (Request Timeout)
- 429 (Too Many Requests / Rate Limiting)
- 500 (Internal Server Error)
- 502 (Bad Gateway)
- 503 (Service Unavailable)
- 504 (Gateway Timeout)

#### Exception Types

- `System.Net.WebException`
- `System.TimeoutException`
- `System.Net.Http.HttpRequestException`
- `Microsoft.PowerShell.Commands.HttpResponseException`

### Default Configuration

```powershell
RetryCount = 3                     # Maximum retry attempts
RetryDelay = 1.0                   # Base delay in seconds
DisableRetry = $false              # Enable retry by default
MaxRetryDelay = 30.0               # Maximum delay cap
UseExponentialBackoff = $true      # Use exponential backoff
UseJitter = $true                  # Add randomization to delays
```

### Global Configuration

Set default retry behavior for all API calls:

```powershell
# Configure global retry settings
Set-ApiRetryConfig `
    -RetryCount 5 `
    -RetryDelay 2.0 `
    -MaxRetryDelay 60.0 `
    -UseExponentialBackoff $true `
    -UseJitter $true

# View current configuration
Get-ApiRetryConfig | Format-List
```

### Per-Function Overrides

Override retry settings for specific function calls:

```powershell
# Use custom retry settings for this call
$projects = Invoke-Api -Uri "$collection/_apis/projects" `
    -RetryCount 10 `
    -RetryDelay 0.5

# Disable retry for this specific call
$result = Get-Project -CollectionUri $collection -Project $project -DisableRetry
```

### Disabling Retry

Temporarily or permanently disable retry logic:

```powershell
# Disable retry globally
Set-ApiRetryConfig -DisableRetry

# Re-enable retry globally
Set-ApiRetryConfig -DisableRetry:$false

# Disable retry for specific call only
$data = Get-WorkItem -Id 12345 -DisableRetry
```

## Monitoring Retry Attempts

Enable verbose output to see retry attempts in action:

```powershell
$VerbosePreference = 'Continue'
$result = Get-Project -CollectionUri $collection -Project $project
# Will show: "Retrying in 2.1 seconds (attempt 1 of 3)"
```

## Best Practices

1. **Use appropriate retry counts** - Higher for critical operations, lower for interactive scenarios
2. **Monitor retry behavior** - Use verbose output during development and troubleshooting
3. **Configure based on environment** - More aggressive retries for automated scripts, conservative for interactive use
4. **Disable for debugging** - Turn off retry when troubleshooting API issues to see immediate failures
