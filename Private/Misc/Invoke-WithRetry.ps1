function Invoke-WithRetry {
    <#
        .SYNOPSIS
            Executes a script block with retry logic for transient failures.

        .DESCRIPTION
            This function provides retry logic for operations that may fail due to transient issues
            such as network timeouts, temporary server errors, or rate limiting.

        .PARAMETER ScriptBlock
            The script block to execute with retry logic.

        .PARAMETER RetryCount
            The maximum number of retry attempts. Default is 3.

        .PARAMETER RetryDelay
            The base delay in seconds between retry attempts. Default is 1 second.
            The actual delay will use exponential backoff with jitter.

        .PARAMETER RetryableExceptions
            Array of exception types that should trigger a retry.
            Defaults to common transient error conditions.

        .PARAMETER RetryableStatusCodes
            Array of HTTP status codes that should trigger a retry.
            Defaults to common transient error conditions.

        .PARAMETER NonRetryableErrorPatterns
            Array of error message patterns that should NOT be retried, even if the HTTP status code
            would normally be retryable. This helps distinguish between transient server errors and
            permanent business logic errors (like duplicate entries).

        .PARAMETER MaxRetryDelay
            The maximum delay in seconds between retries. Default is 30 seconds.

        .PARAMETER UseExponentialBackoff
            Whether to use exponential backoff for retry delays. Default is $true.

        .PARAMETER UseJitter
            Whether to add random jitter to retry delays to avoid thundering herd. Default is $true.

        .EXAMPLE
            $result = Invoke-WithRetry -ScriptBlock {
                Invoke-WebRequest -Uri 'https://api.example.com/data'
            }

        .EXAMPLE
            $result = Invoke-WithRetry -ScriptBlock {
                Get-SomeData
            } -RetryCount 5 -RetryDelay 2
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,

        [ValidateRange(0, 10)]
        [int] $RetryCount = 3,

        [ValidateRange(0.1, 300)]
        [double] $RetryDelay = 1.0,

        [string[]] $RetryableExceptions = @(
            'System.Net.WebException',
            'System.TimeoutException',
            'System.Net.Http.HttpRequestException',
            'Microsoft.PowerShell.Commands.HttpResponseException'
        ),

        [int[]] $RetryableStatusCodes = @(
            408, # Request Timeout
            429, # Too Many Requests
            500, # Internal Server Error
            502, # Bad Gateway
            503, # Service Unavailable
            504  # Gateway Timeout
        ),

        [string[]] $NonRetryableErrorPatterns = @(
            'Cannot add duplicate',
            'already exists',
            'duplicate entry',
            'unique constraint'
        ),

        [ValidateRange(1, 300)]
        [double] $MaxRetryDelay = 30.0,

        [bool] $UseExponentialBackoff = $true,

        [bool] $UseJitter = $true
    )

    $attempt = 0
    $lastException = $null

    while ($attempt -le $RetryCount) {
        try {
            Write-Verbose "Executing attempt $($attempt + 1) of $($RetryCount + 1)"

            # Execute the script block
            $result = & $ScriptBlock

            # If we get here, the operation succeeded
            if ($attempt -gt 0) {
                Write-Verbose "Operation succeeded on attempt $($attempt + 1)"
            }

            return $result
        } catch {
            $lastException = $_
            $attempt++            # Check if we should retry this exception
            $shouldRetry = $false

            # Check HTTP status codes for web exceptions
            $statusCode = $null
            if ($_.Exception -is [System.Net.WebException]) {
                if ($_.Exception.Response) {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                }
            } elseif ($_.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') {
                # Use type name comparison for PowerShell version compatibility
                $statusCode = [int]$_.Exception.Response.StatusCode
            } elseif ($_.TargetObject -and $_.TargetObject.StatusCode) {
                # For mock objects in tests
                $statusCode = [int]$_.TargetObject.StatusCode
            }

            # For HTTP exceptions, only retry if the status code is in the retryable list
            if ($statusCode) {
                if ($statusCode -in $RetryableStatusCodes) {
                    $shouldRetry = $true
                    Write-Verbose "Retryable HTTP status code detected: $statusCode"
                } else {
                    Write-Verbose "Non-retryable HTTP status code detected: $statusCode"
                }
            } else {
                # For non-HTTP exceptions, check exception type
                $exceptionType = $_.Exception.GetType().FullName
                if ($exceptionType -in $RetryableExceptions) {
                    $shouldRetry = $true
                    Write-Verbose "Retryable exception detected: $exceptionType"
                }
            }

            # Check if the error message contains non-retryable patterns
            $errorMessage = $_.Exception.Message
            if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                $errorMessage = $_.ErrorDetails.Message
            }

            $isNonRetryablePattern = $false
            foreach ($pattern in $NonRetryableErrorPatterns) {
                if ($errorMessage -like "*$pattern*") {
                    $isNonRetryablePattern = $true
                    Write-Verbose "Non-retryable error pattern detected: '$pattern' in message: $errorMessage"
                    break
                }
            }

            # If we found a non-retryable pattern, don't retry regardless of status code or exception type
            if ($shouldRetry -and $isNonRetryablePattern) {
                Write-Verbose "Skipping retry due to non-retryable error pattern"
                $shouldRetry = $false
            }
            # If this is our last attempt or the error is not retryable, throw
            if ($attempt -gt $RetryCount -or -not $shouldRetry) {
                if (-not $shouldRetry) {
                    Write-Verbose "Non-retryable error encountered: $exceptionType $(if ($statusCode) { "HTTP $statusCode" })"
                } else {
                    Write-Verbose "Maximum retry attempts ($RetryCount) exceeded"
                }

                # Use Assert-HttpResponse to parse JSON error messages for better error details
                try {
                    Assert-HttpResponse -ErrorRecord $lastException
                } catch {
                    # If Assert-HttpResponse fails or doesn't apply, throw the original exception
                    throw $lastException
                }
            }

            # Calculate delay for next attempt
            $delay = $RetryDelay

            if ($UseExponentialBackoff) {
                # Exponential backoff: delay = base * (2 ^ attempt)
                $delay = $RetryDelay * [Math]::Pow(2, $attempt - 1)
            }

            # Apply jitter (random ±25% variation)
            if ($UseJitter) {
                $jitterRange = $delay * 0.25
                $jitter = (Get-Random -Minimum (-$jitterRange) -Maximum $jitterRange)
                $delay += $jitter
            }

            # Cap the delay at maximum
            $delay = [Math]::Min($delay, $MaxRetryDelay)

            Write-Verbose "Retrying in $([Math]::Round($delay, 2)) seconds (attempt $attempt of $RetryCount)"
            Write-Verbose "Operation failed, retrying in $([Math]::Round($delay, 2)) seconds. Error: $($_.Exception.Message)"

            # Wait before retrying
            Start-Sleep -Seconds $delay
        }
    }

    # This should never be reached, but just in case
    throw $lastException
}
