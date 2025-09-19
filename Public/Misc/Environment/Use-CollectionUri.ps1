function Use-CollectionUri {

    <#
        .SYNOPSIS
            Gets the Azure DevOps collection URI.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingPlainTextForPassword', '',
        Justification = ''
    )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Uri','Collection','CollectionUri')]
        $Value
    )

    process {

        # Use given collection URI
        if ($Value) {
            return Format-Uri -Uri $Value
        }

        # Or the one in the global variable
        $candidate = $global:AzureDevOpsApi_CollectionUri

        return $candidate
    }
}
