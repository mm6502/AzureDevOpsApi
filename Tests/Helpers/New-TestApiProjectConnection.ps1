
function New-TestApiProjectConnection {

    <#
        .SYNOPSIS
            Returns new ApiProjectConnection for use in tests.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Does not change state, generates a new object.'
    )]
    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiProjectConnection')]
    param()

    process {
        return New-ApiProjectConnection `
            -ApiCollectionConnection (New-TestApiCollectionConnection) `
            -ProjectId '00000000-0000-0000-cafe-000000000001' `
            -ProjectName 'MyProject'
    }
}
