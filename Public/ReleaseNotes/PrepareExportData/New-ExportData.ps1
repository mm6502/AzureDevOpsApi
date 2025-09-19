function New-ExportData {

    <#
        .SYNOPSIS
            Creates new export data.

        .EXAMPLE
            $exportData = New-ExportData
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = ''
    )]
    [OutputType('PSTypeNames.AzureDevOpsApi.ExportData')]
    param()

    process {

        $item = [PSCustomObject] @{
            PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            Release   = $null
            Console   = [System.Collections.Generic.List[PSObject]]::new()
            Relations = [System.Collections.Generic.List[PSObject]]::new()
            WorkItems = [System.Collections.Generic.List[PSObject]]::new()
        }

        $item
    }
}
