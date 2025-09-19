function Get-ApiRetryConfig {
    <#
        .SYNOPSIS
            Gets the current global retry configuration for Azure DevOps API calls.

        .DESCRIPTION
            This function returns the current global retry configuration that is used
            as default for all Azure DevOps API calls.

        .EXAMPLE
            $config = Get-ApiRetryConfig
    #>

    [CmdletBinding()]
    param()

    process {
        return $global:AzureDevOpsApi_RetryConfig.Clone()
    }
}
