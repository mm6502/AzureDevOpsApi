function Use-ApiVersion {

    <#
        .SYNOPSIS
            Gets the ApiVersion to use for given Azure DevOps collection URI.
            If the ApiVersion is not determined, it will default to '5.0'

        .DESCRIPTION
            Gets the ApiVersion to use for given Azure DevOps collection URI.
            If the ApiVersion is not determined, it will default to '5.0'

        .PARAMETER ApiVersion
            Version of the Azure DevOps API to use.
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Version', 'ApiVersion')]
        $Value = $null
    )

    process {

        $candidate = Use-Value -A $Value -B ($global:AzureDevOpsApi_ApiVersion)
        if ($candidate) {
            return $candidate
        }

        return '5.0'
    }
}
