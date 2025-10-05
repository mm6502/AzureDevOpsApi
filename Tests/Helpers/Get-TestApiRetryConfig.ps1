function Get-TestApiRetryConfig {

    <#
        .SYNOPSIS
        Returns a configuration hashtable that disables retries for API calls.
    #>

    [CmdletBinding()]
    param(
        [int] $RetryCount = 3,
        [int] $RetryDelay = 0.1,
        [switch] $DisableRetry,
        [double] $MaxRetryDelay = 5.0,
        [switch] $UseExponentialBackoff,
        [switch] $UseJitter
    )

    return @{
        RetryCount            = $RetryCount
        RetryDelay            = $RetryDelay
        DisableRetry          = [bool] $DisableRetry
        MaxRetryDelay         = $MaxRetryDelay
        UseExponentialBackoff = [bool] $UseExponentialBackoff
        UseJitter             = [bool] $UseJitter
    }
}
