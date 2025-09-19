function ConvertTo-ExportDataConsole {

    <#
        .SYNOPSIS
            Converts set of ReleaseNotesDataItems to ExportData - Console subset.

        .PARAMETER WorkItems
            List of ReleaseNotesDataItems.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.ExportDataConsoleItem')]
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Default', Mandatory)]
        [hashtable] $Items
    )

    begin {
        $result = [System.Collections.Generic.List[PSObject]]::new()
    }

    process {

        # Console
        foreach ($item in $Items.Values) {
            $result += [PSCustomObject] @{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.ExportDataConsoleItem'
                WorkItemId   = $item.WorkItemId
                ApiUrl       = $item.ApiUrl
                PortalUrl    = $item.PortalUrl
                WorkItemType = $item.WorkItemType
                Reasons      = $item.Reasons
                Relations    = $item.Relations
            }
        }
    }

    end {
        $result
    }
}
