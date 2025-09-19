
function New-TestApiCollectionConnection {

    <#
        .SYNOPSIS
            Returns new ApiCollectionConnection for use in tests.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Does not change state, generates a new object.'
    )]
    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiCollectionConnection')]
    param()

    process {
        return New-ApiCollectionConnection `
            -CollectionUri 'https://dev.azure.com/myorg/' `
            -ApiCredential (New-ApiCredential) `
            -ApiVersion '6.0'
    }
}
