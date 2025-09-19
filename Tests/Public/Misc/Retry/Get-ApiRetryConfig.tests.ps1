[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-ApiRetryConfig' {

    BeforeEach {
        # Set known configuration
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount = 5
            RetryDelay = 2.0
            DisableRetry = $true
            MaxRetryDelay = 45.0
            UseExponentialBackoff = $false
            UseJitter = $false
        }
    }

    It 'Should return current configuration' {
        # Act
        $result = Get-ApiRetryConfig

        # Assert
        $result.RetryCount | Should -Be 5
        $result.RetryDelay | Should -Be 2.0
        $result.DisableRetry | Should -Be $true
        $result.MaxRetryDelay | Should -Be 45.0
        $result.UseExponentialBackoff | Should -Be $false
        $result.UseJitter | Should -Be $false
    }

    It 'Should return cloned configuration (not reference)' {
        # Act
        $result = Get-ApiRetryConfig

        # Assert
        $result | Should -Not -Be $global:AzureDevOpsApi_RetryConfig
        $result.RetryCount = 999
        $global:AzureDevOpsApi_RetryConfig.RetryCount | Should -Not -Be 999
    }

    It 'Should return all expected properties' {
        # Act
        $result = Get-ApiRetryConfig

        # Assert
        $result.Keys | Should -Contain 'RetryCount'
        $result.Keys | Should -Contain 'RetryDelay'
        $result.Keys | Should -Contain 'DisableRetry'
        $result.Keys | Should -Contain 'MaxRetryDelay'
        $result.Keys | Should -Contain 'UseExponentialBackoff'
        $result.Keys | Should -Contain 'UseJitter'
        $result.Keys.Count | Should -Be 6
    }

    It 'Should reflect changes made by Set-ApiRetryConfig' {
        # Arrange
        Set-ApiRetryConfig -RetryCount 8 -RetryDelay 1.5 -DisableRetry:$false

        # Act
        $result = Get-ApiRetryConfig

        # Assert
        $result.RetryCount | Should -Be 8
        $result.RetryDelay | Should -Be 1.5
        $result.DisableRetry | Should -Be $false
    }
}
