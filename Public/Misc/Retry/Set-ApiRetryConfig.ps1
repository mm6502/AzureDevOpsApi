function Set-ApiRetryConfig {
    <#
        .SYNOPSIS
            Configures global retry behavior for Azure DevOps API calls.

        .DESCRIPTION
            This function allows you to configure the default retry behavior for all Azure DevOps API calls.
            These settings will be used by default unless overridden in individual function calls.

        .PARAMETER RetryCount
            The maximum number of retry attempts for transient failures. Default is 3.

        .PARAMETER RetryDelay
            The base delay in seconds between retry attempts. Default is 1 second.

        .PARAMETER DisableRetry
            Disables retry logic completely for all API calls.

        .PARAMETER MaxRetryDelay
            The maximum delay in seconds between retries. Default is 30 seconds.

        .PARAMETER UseExponentialBackoff
            Whether to use exponential backoff for retry delays. Default is $true.

        .PARAMETER UseJitter
            Whether to add random jitter to retry delays. Default is $true.

        .PARAMETER PassThru
            Returns the current retry configuration.

        .EXAMPLE
            Set-ApiRetryConfig -RetryCount 5 -RetryDelay 2

        .EXAMPLE
            Set-ApiRetryConfig -DisableRetry

        .EXAMPLE
            $config = Set-ApiRetryConfig -PassThru
    #>

    [CmdletBinding()]
    param(
        [ValidateRange(0, 10)]
        [int] $RetryCount = 3,

        [ValidateRange(0.1, 300)]
        [double] $RetryDelay = 1.0,

        [switch] $DisableRetry,

        [ValidateRange(1, 300)]
        [double] $MaxRetryDelay = 30.0,

        [bool] $UseExponentialBackoff = $true,

        [bool] $UseJitter = $true,

        [switch] $PassThru
    )

    process {
        # Update global configuration
        if ($PSBoundParameters.ContainsKey('RetryCount')) {
            $global:AzureDevOpsApi_RetryConfig.RetryCount = $RetryCount
        }

        if ($PSBoundParameters.ContainsKey('RetryDelay')) {
            $global:AzureDevOpsApi_RetryConfig.RetryDelay = $RetryDelay
        }

        if ($PSBoundParameters.ContainsKey('DisableRetry')) {
            $global:AzureDevOpsApi_RetryConfig.DisableRetry = $DisableRetry.IsPresent -and $DisableRetry
        }

        if ($PSBoundParameters.ContainsKey('MaxRetryDelay')) {
            $global:AzureDevOpsApi_RetryConfig.MaxRetryDelay = $MaxRetryDelay
        }

        if ($PSBoundParameters.ContainsKey('UseExponentialBackoff')) {
            $global:AzureDevOpsApi_RetryConfig.UseExponentialBackoff = $UseExponentialBackoff
        }

        if ($PSBoundParameters.ContainsKey('UseJitter')) {
            $global:AzureDevOpsApi_RetryConfig.UseJitter = $UseJitter
        }

        Write-Verbose "Updated Azure DevOps API retry configuration"

        if ($PassThru.IsPresent -and $PassThru) {
            return $global:AzureDevOpsApi_RetryConfig.Clone()
        }
    }
}
