[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Set-ApiRetryConfig' {

    BeforeEach {
        # Reset retry configuration to defaults
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount = 3
            RetryDelay = 1.0
            DisableRetry = $false
            MaxRetryDelay = 30.0
            UseExponentialBackoff = $true
            UseJitter = $true
        }
    }

    Context 'Parameter Setting' {
        It 'Should set RetryCount' {
            # Act
            Set-ApiRetryConfig -RetryCount 5

            # Assert
            $global:AzureDevOpsApi_RetryConfig.RetryCount | Should -Be 5
        }

        It 'Should set RetryDelay' {
            # Act
            Set-ApiRetryConfig -RetryDelay 2.5

            # Assert
            $global:AzureDevOpsApi_RetryConfig.RetryDelay | Should -Be 2.5
        }

        It 'Should set DisableRetry' {
            # Act
            Set-ApiRetryConfig -DisableRetry

            # Assert
            $global:AzureDevOpsApi_RetryConfig.DisableRetry | Should -Be $true
        }

        It 'Should set MaxRetryDelay' {
            # Act
            Set-ApiRetryConfig -MaxRetryDelay 60.0

            # Assert
            $global:AzureDevOpsApi_RetryConfig.MaxRetryDelay | Should -Be 60.0
        }

        It 'Should set UseExponentialBackoff' {
            # Act
            Set-ApiRetryConfig -UseExponentialBackoff $false

            # Assert
            $global:AzureDevOpsApi_RetryConfig.UseExponentialBackoff | Should -Be $false
        }

        It 'Should set UseJitter' {
            # Act
            Set-ApiRetryConfig -UseJitter $false

            # Assert
            $global:AzureDevOpsApi_RetryConfig.UseJitter | Should -Be $false
        }

        It 'Should set multiple parameters at once' {
            # Act
            Set-ApiRetryConfig -RetryCount 7 -RetryDelay 3.0 -DisableRetry

            # Assert
            $global:AzureDevOpsApi_RetryConfig.RetryCount | Should -Be 7
            $global:AzureDevOpsApi_RetryConfig.RetryDelay | Should -Be 3.0
            $global:AzureDevOpsApi_RetryConfig.DisableRetry | Should -Be $true
        }

        It 'Should not modify unspecified parameters' {
            # Arrange
            $originalMaxRetryDelay = $global:AzureDevOpsApi_RetryConfig.MaxRetryDelay

            # Act
            Set-ApiRetryConfig -RetryCount 5

            # Assert
            $global:AzureDevOpsApi_RetryConfig.RetryCount | Should -Be 5
            $global:AzureDevOpsApi_RetryConfig.MaxRetryDelay | Should -Be $originalMaxRetryDelay
        }
    }

    Context 'PassThru Parameter' {
        It 'Should return configuration when PassThru is specified' {
            # Act
            $result = Set-ApiRetryConfig -RetryCount 4 -PassThru

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.RetryCount | Should -Be 4
            $result.GetType().Name | Should -Be 'Hashtable'
        }

        It 'Should return cloned configuration (not reference)' {
            # Act
            $result = Set-ApiRetryConfig -PassThru

            # Assert
            $result | Should -Not -Be $global:AzureDevOpsApi_RetryConfig
            $result.RetryCount = 999
            $global:AzureDevOpsApi_RetryConfig.RetryCount | Should -Not -Be 999
        }
    }

    Context 'Parameter Validation' {
        It 'Should validate RetryCount range - minimum' {
            # Act & Assert
            { Set-ApiRetryConfig -RetryCount -1 } | Should -Throw
        }

        It 'Should validate RetryCount range - maximum' {
            # Act & Assert
            { Set-ApiRetryConfig -RetryCount 11 } | Should -Throw
        }

        It 'Should validate RetryDelay range - minimum' {
            # Act & Assert
            { Set-ApiRetryConfig -RetryDelay 0.05 } | Should -Throw
        }

        It 'Should validate RetryDelay range - maximum' {
            # Act & Assert
            { Set-ApiRetryConfig -RetryDelay 301 } | Should -Throw
        }

        It 'Should validate MaxRetryDelay range - minimum' {
            # Act & Assert
            { Set-ApiRetryConfig -MaxRetryDelay 0.5 } | Should -Throw
        }

        It 'Should validate MaxRetryDelay range - maximum' {
            # Act & Assert
            { Set-ApiRetryConfig -MaxRetryDelay 301 } | Should -Throw
        }

        It 'Should accept valid boundary values' {
            # Act & Assert
            { Set-ApiRetryConfig -RetryCount 0 } | Should -Not -Throw
            { Set-ApiRetryConfig -RetryCount 10 } | Should -Not -Throw
            { Set-ApiRetryConfig -RetryDelay 0.1 } | Should -Not -Throw
            { Set-ApiRetryConfig -RetryDelay 300 } | Should -Not -Throw
            { Set-ApiRetryConfig -MaxRetryDelay 1 } | Should -Not -Throw
            { Set-ApiRetryConfig -MaxRetryDelay 300 } | Should -Not -Throw
        }
    }
}
