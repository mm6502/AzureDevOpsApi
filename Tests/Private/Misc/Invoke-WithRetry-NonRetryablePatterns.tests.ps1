[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', '',
    Justification = 'Test code uses parameter names that trigger the rule but are not actual credentials'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'Invoke-WithRetry NonRetryableErrorPatterns' {

    BeforeEach {
        # Reset any global state
        $script:TestCallCount = 0
    }

    It 'Should not retry when error message contains "Cannot add duplicate" pattern' {
        # Arrange
        $scriptBlock = {
            $script:TestCallCount++
            # Create a mock target object with StatusCode property for testing
            $mockTarget = [PSCustomObject]@{
                StatusCode = 500
            }
            # Create a mock error record that simulates HTTP 500 with duplicate error message
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Net.WebException]::new("Cannot add duplicate test case to suite"),
                "TestError",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $mockTarget
            )
            throw $errorRecord
        }

        # Act & Assert
        {
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1
        } | Should -Throw -ExpectedMessage "*Cannot add duplicate*"

        # Should only be called once (no retries) - this verifies the pattern was detected in ErrorDetails.Message
        $script:TestCallCount | Should -Be 1
    }

    It 'Should not retry when error message contains "already exists" pattern' {
        # Arrange
        $scriptBlock = {
            $script:TestCallCount++
            $mockTarget = [PSCustomObject]@{
                StatusCode = 500
            }
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Net.WebException]::new("Test case already exists in suite"),
                "TestError",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $mockTarget
            )
            throw $errorRecord
        }

        # Act & Assert
        {
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1
        } | Should -Throw -ExpectedMessage "*already exists*"

        # Should only be called once (no retries)
        $script:TestCallCount | Should -Be 1
    }

    It 'Should not retry when error message contains "duplicate entry" pattern' {
        # Arrange
        $scriptBlock = {
            $script:TestCallCount++
            $mockTarget = [PSCustomObject]@{
                StatusCode = 500
            }
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Net.WebException]::new("Cannot insert duplicate entry"),
                "TestError",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $mockTarget
            )
            throw $errorRecord
        }

        # Act & Assert
        {
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1
        } | Should -Throw -ExpectedMessage "*duplicate entry*"

        # Should only be called once (no retries)
        $script:TestCallCount | Should -Be 1
    }

    It 'Should not retry when error message contains "unique constraint" pattern' {
        # Arrange
        $scriptBlock = {
            $script:TestCallCount++
            $mockTarget = [PSCustomObject]@{
                StatusCode = 500
            }
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Net.WebException]::new("Violation of unique constraint"),
                "TestError",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $mockTarget
            )
            throw $errorRecord
        }

        # Act & Assert
        {
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1
        } | Should -Throw -ExpectedMessage "*unique constraint*"

        # Should only be called once (no retries)
        $script:TestCallCount | Should -Be 1
    }

    It 'Should retry normal HTTP 500 errors that do not match non-retryable patterns' {
        # Arrange
        $scriptBlock = {
            $script:TestCallCount++
            if ($script:TestCallCount -lt 3) {
                $mockTarget = [PSCustomObject]@{
                    StatusCode = 500
                }
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Net.WebException]::new("Internal server error - temporary issue"),
                    "TestError",
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $mockTarget
                )
                throw $errorRecord
            }
            return "Success on attempt $script:TestCallCount"
        }

        # Act
        $result = Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1

        # Assert
        $result | Should -Be "Success on attempt 3"
        $script:TestCallCount | Should -Be 3
    }

    It 'Should check ErrorDetails.Message when available' {
        # Arrange
        $scriptBlock = {
            $script:TestCallCount++
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Exception]::new("Generic exception message"),
                "TestError",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $null
            )
            $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new("Cannot add duplicate item to collection")
            throw $errorRecord
        }

        # Act & Assert
        {
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1
        } | Should -Throw -ExpectedMessage "*Generic exception message*"

        # Should only be called once (no retries) - this verifies the pattern was detected in ErrorDetails.Message
        $script:TestCallCount | Should -Be 1
    }

    It 'Should use custom NonRetryableErrorPatterns when provided' {
        # Arrange
        $customPatterns = @('custom error pattern', 'another pattern')
        $scriptBlock = {
            $script:TestCallCount++
            $mockTarget = [PSCustomObject]@{
                StatusCode = 500
            }
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Net.WebException]::new("This is a custom error pattern that should not retry"),
                "TestError",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $mockTarget
            )
            throw $errorRecord
        }

        # Act & Assert
        {
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1 -NonRetryableErrorPatterns $customPatterns
        } | Should -Throw -ExpectedMessage "*custom error pattern*"

        # Should only be called once (no retries)
        $script:TestCallCount | Should -Be 1
    }

    It 'Should still retry when error message does not match any non-retryable patterns' {
        # Arrange
        $scriptBlock = {
            $script:TestCallCount++
            if ($script:TestCallCount -lt 2) {
                $mockTarget = [PSCustomObject]@{
                    StatusCode = 500
                }
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Net.WebException]::new("Some other server error"),
                    "TestError",
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $mockTarget
                )
                throw $errorRecord
            }
            return "Success"
        }

        # Act
        $result = Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelay 0.1

        # Assert
        $result | Should -Be "Success"
        $script:TestCallCount | Should -Be 2
    }
}