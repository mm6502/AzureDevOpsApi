[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
    $script:baseUri = 'https://dev.azure.com/organization/_apis/test'
}

BeforeDiscovery {
    $skipOnPS5 = $PSVersionTable.PSVersion.Major -lt 6
}

Describe 'Invoke-CustomWebRequest Retry Logic' {
    BeforeEach {
        # Reset global retry config to fast test defaults
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount = 1
            RetryDelay = 0.1
            MaxRetryDelay = 1.0
            DisableRetry = $false
            UseExponentialBackoff = $false
            UseJitter = $false
        }

        # Suppress retry warnings during tests
        $global:WarningPreference = 'SilentlyContinue'
    }

    Context 'Basic Retry Functionality' {
        It 'Should retry on transient failure and succeed' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                if ($script:callCount -lt 2) {
                    throw [System.Net.WebException]::new('Simulated transient failure')
                }
                return [PSCustomObject]@{
                    StatusCode = 200
                    Content = '{"result": "success"}'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act
            $result = Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 1

            # Assert
            $script:callCount | Should -Be 2
            $result.StatusCode | Should -Be 200
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -Times 2
        }

        It 'Should fail after exhausting all retries' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                throw [System.Net.WebException]::new('Persistent failure')
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act & Assert
            { Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 1 } |
                Should -Throw 'Persistent failure'
            $script:callCount | Should -Be 2  # Initial attempt + 1 retry
        }

        It 'Should not retry on non-retryable errors' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                throw [System.ArgumentException]::new('Invalid argument')
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act & Assert
            { Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 1 } |
                Should -Throw 'Invalid argument'
            $script:callCount | Should -Be 1  # Only initial attempt, no retries
        }

        It 'Should not retry when RetryCount is 0' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                throw [System.Net.WebException]::new('Simulated failure')
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act & Assert
            { Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 0 } |
                Should -Throw 'Simulated failure'
            $script:callCount | Should -Be 1
        }

        It 'Should not retry when DisableRetry is specified' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                throw [System.Net.WebException]::new('Simulated failure')
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act & Assert
            { Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) -DisableRetry } |
                Should -Throw 'Simulated failure'
            $script:callCount | Should -Be 1
        }

        It 'Should not retry when global DisableRetry is true' {
            # Arrange
            $global:AzureDevOpsApi_RetryConfig.DisableRetry = $true

            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                throw [System.Net.WebException]::new('Simulated failure')
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act & Assert
            { Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) } |
                Should -Throw 'Simulated failure'
            $script:callCount | Should -Be 1
        }
    }

    Context 'Integration with Different HTTP Clients' {
        It 'Should retry with Invoke-WebRequest' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                if ($script:callCount -lt 2) {
                    throw [System.Net.WebException]::new('Simulated failure')
                }
                return [PSCustomObject]@{ StatusCode = 200; Content = '{}' }
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act
            $null = Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 1

            # Assert
            $script:callCount | Should -Be 2
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -Times 2
        }

        It 'Should retry with Invoke-CurlWebRequest' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -MockWith {
                $script:callCount++
                if ($script:callCount -lt 2) {
                    throw [System.Net.WebException]::new('Simulated failure')
                }
                return [PSCustomObject]@{ StatusCode = 200; Content = '{}' }
            }

            # Mock PowerShell 7 and use Basic auth instead of PAT to avoid token conversion
            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 7 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Linux' }
            }

            # Act
            $credential = [PSCredential]::new('testuser', (ConvertTo-SecureString 'testpass' -AsPlainText -Force))
            $null = Invoke-CustomWebRequest `
                -Uri $script:baseUri `
                -ApiCredential (New-ApiCredential -Credential $credential -Authorization 'Basic') `
                -RetryCount 1

            # Assert
            $script:callCount | Should -Be 2
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CurlWebRequest -Times 2
        }
    }

    Context 'Configuration Parameter Inheritance' {
        It 'Should use global config when no parameters specified' {
            # Arrange
            $global:AzureDevOpsApi_RetryConfig.RetryCount = 1

            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                throw [System.Net.WebException]::new('Simulated failure')
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act & Assert
            { Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) } |
                Should -Throw 'Simulated failure'
            $script:callCount | Should -Be 2  # Initial + 1 retry from global config
        }

        It 'Should override global config with explicit parameters' {
            # Arrange
            $global:AzureDevOpsApi_RetryConfig.RetryCount = 3

            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                throw [System.Net.WebException]::new('Simulated failure')
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act & Assert - Using explicit RetryCount of 1 instead of global 3
            { Invoke-CustomWebRequest -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 1 } |
                Should -Throw 'Simulated failure'
            $script:callCount | Should -Be 2  # Initial + 1 retry (not 3)
        }
    }

    Context 'Integration with Invoke-Api Functions' {
        It 'Should pass retry parameters to Invoke-Api' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                if ($script:callCount -lt 2) {
                    throw [System.Net.WebException]::new('Simulated failure')
                }
                return [PSCustomObject]@{
                    StatusCode = 200
                    Content = '{"result": "success"}'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act
            $null = Invoke-Api -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 1

            # Assert
            $script:callCount | Should -Be 2
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -Times 2
        }

        It 'Should pass retry parameters to Invoke-ApiListPaged' {
            # Arrange
            $script:callCount = 0
            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {
                $script:callCount++
                if ($script:callCount -lt 2) {
                    throw [System.Net.WebException]::new('Simulated failure')
                }
                return [PSCustomObject]@{
                    StatusCode = 200
                    Content = '{"value": [], "count": 0}'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-PSVersion -MockWith { 5 }
            Mock -ModuleName $ModuleName -CommandName Get-OSVersion -MockWith {
                [PSCustomObject] @{ Platform = 'Windows' }
            }

            # Act
            $null = Invoke-ApiListPaged -Uri $script:baseUri -ApiCredential (New-ApiCredential) -RetryCount 1

            # Assert
            $script:callCount | Should -Be 2
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-WebRequest -Times 2
        }
    }
}
