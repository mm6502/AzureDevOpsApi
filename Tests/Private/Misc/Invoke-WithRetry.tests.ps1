[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Invoke-WithRetry' {

    BeforeEach {
        # Reset retry configuration
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount = 1
            RetryDelay = 0.1
            DisableRetry = $false
            MaxRetryDelay = 5.0
            UseExponentialBackoff = $false
            UseJitter = $false
        }
    }

    Context 'Basic Functionality' {
        It 'Should execute script block successfully on first attempt' {
            # Arrange
            $expected = 'success'
            $scriptBlock = { return $expected }

            # Act
            $result = Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 3 `
                -WarningAction SilentlyContinue

            # Assert
            $result | Should -Be $expected
        }

        It 'Should return result from successful retry' {
            # Arrange
            $expected = 'success'
            $script:attemptCount = 0
            $scriptBlock = {
                $script:attemptCount++
                if ($script:attemptCount -lt 2) {
                    throw [System.Net.WebException]::new('Simulated failure')
                }
                return $expected
            }

            # Act
            $result = Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 3 `
                -RetryDelay 0.1 `
                -WarningAction SilentlyContinue

            # Assert
            $result | Should -Be $expected
            $script:attemptCount | Should -Be 2
        }

        It 'Should throw after maximum retries exceeded' {
            # Arrange
            $scriptBlock = {
                throw [System.Net.WebException]::new('Persistent failure')
            }

            # Act & Assert
            { Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 2 `
                -RetryDelay 0.1 `
                -WarningAction SilentlyContinue
            } | Should -Throw 'Persistent failure'
        }
    }

    Context 'Retryable Exceptions' {
        It 'Should retry on WebException' {
            # Arrange
            $script:attemptCount = 0
            $scriptBlock = {
                $script:attemptCount++
                if ($script:attemptCount -lt 2) {
                    throw [System.Net.WebException]::new('Network error')
                }
                return 'success'
            }

            # Act
            $result = Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 3 `
                -RetryDelay 0.1 `
                -WarningAction SilentlyContinue

            # Assert
            $result | Should -Be 'success'
            $script:attemptCount | Should -Be 2
        }

        It 'Should retry on TimeoutException' {
            # Arrange
            $script:attemptCount = 0
            $scriptBlock = {
                $script:attemptCount++
                if ($script:attemptCount -lt 2) {
                    throw [System.TimeoutException]::new('Request timeout')
                }
                return 'success'
            }

            # Act
            $result = Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 3 `
                -RetryDelay 0.1 `
                -WarningAction SilentlyContinue

            # Assert
            $result | Should -Be 'success'
            $script:attemptCount | Should -Be 2
        }

        It 'Should not retry on non-retryable exception' {
            # Arrange
            $script:attemptCount = 0
            $scriptBlock = {
                $script:attemptCount++
                throw [System.ArgumentException]::new('Invalid argument')
            }

            # Act & Assert
            { Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 3 `
                -RetryDelay 0.1 `
                -WarningAction SilentlyContinue
            } | Should -Throw 'Invalid argument'
            $script:attemptCount | Should -Be 1
        }
    }

    Context 'HTTP Status Code Retries' {
        It 'Should retry on retryable HTTP status codes' {
            # Arrange
            $retryableStatusCodes = @(408, 429, 500, 502, 503, 504)

            foreach ($statusCode in $retryableStatusCodes) {
                $script:attemptCount = 0
                $scriptBlock = {
                    $script:attemptCount++
                    if ($script:attemptCount -lt 2) {
                        # Create an error that will have TargetObject with StatusCode
                        $targetObject = [PSCustomObject]@{ StatusCode = $statusCode }
                        Write-Error "HTTP $statusCode error" -TargetObject $targetObject -ErrorAction Stop
                    }
                    return 'success'
                }

                # Act
                $result = Invoke-WithRetry `
                    -ScriptBlock $scriptBlock `
                    -RetryCount 3 `
                    -RetryDelay 0.1 `
                    -WarningAction SilentlyContinue

                # Assert
                $result | Should -Be 'success'
                $script:attemptCount | Should -Be 2
            }
        }

        It 'Should not retry on non-retryable HTTP status codes' {
            # Arrange
            $nonRetryableStatusCodes = @(400, 401, 403, 404)

            foreach ($statusCode in $nonRetryableStatusCodes) {
                $script:attemptCount = 0
                $scriptBlock = {
                    $script:attemptCount++
                    $targetObject = [PSCustomObject]@{ StatusCode = $statusCode }
                    Write-Error "HTTP $statusCode error" -TargetObject $targetObject -ErrorAction Stop
                }

                # Act & Assert
                { Invoke-WithRetry `
                    -ScriptBlock $scriptBlock `
                    -RetryCount 3 `
                    -RetryDelay 0.1 `
                    -WarningAction SilentlyContinue
                } | Should -Throw
                $script:attemptCount | Should -Be 1
            }
        }
    }

    Context 'Retry Delay Calculations' {
        It 'Should use exponential backoff when enabled' {
            # Arrange
            $script:attemptCount = 0
            $script:delays = @()
            $scriptBlock = {
                $script:attemptCount++
                if ($script:attemptCount -le 3) {
                    throw [System.Net.WebException]::new('Simulated failure')
                }
                return 'success'
            }

            # Mock Start-Sleep to capture delays
            Mock -ModuleName $ModuleName -CommandName Start-Sleep -MockWith {
                param($Seconds)
                $script:delays += $Seconds
            }

            # Act
            $result = Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 3 `
                -RetryDelay 1.0 `
                -UseJitter $false `
                -WarningAction SilentlyContinue

            # Assert
            $result | Should -Be 'success'
            $script:delays.Count | Should -Be 3
            # With exponential backoff: 1, 2, 4
            $script:delays[0] | Should -BeGreaterOrEqual 0.9
            $script:delays[0] | Should -BeLessOrEqual 1.1
            $script:delays[1] | Should -BeGreaterOrEqual 1.9
            $script:delays[1] | Should -BeLessOrEqual 2.1
            $script:delays[2] | Should -BeGreaterOrEqual 3.9
            $script:delays[2] | Should -BeLessOrEqual 4.1
        }

        It 'Should respect maximum delay limit' {
            # Arrange
            $script:attemptCount = 0
            $script:delays = @()
            $scriptBlock = {
                $script:attemptCount++
                if ($script:attemptCount -le 2) {
                    throw [System.Net.WebException]::new('Simulated failure')
                }
                return 'success'
            }

            # Mock Start-Sleep to capture delays
            Mock -ModuleName $ModuleName -CommandName Start-Sleep -MockWith {
                param($Seconds)
                $script:delays += $Seconds
            }

            # Act
            $result = Invoke-WithRetry `
                -ScriptBlock $scriptBlock `
                -RetryCount 2 `
                -RetryDelay 10.0 `
                -MaxRetryDelay 5.0 `
                -UseJitter $false `
                -WarningAction SilentlyContinue

            # Assert
            $result | Should -Be 'success'
            $script:delays | ForEach-Object { $_ | Should -BeLessOrEqual 5.0 }
        }
    }
}
