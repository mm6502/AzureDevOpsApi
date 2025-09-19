function Test-TestWorkItem {

    <#
        .SYNOPSIS
            Decides whether given $WorkItem is a Test Work Item;
            i.e. it has a 'System.WorkItemType' field with value 'Test Case',
            or it has a 'System.WorkItemType' field with value 'Requirement'
            and Tags field with value like 'Test*'.

        .PARAMETER WorkItem
            Work Item we want to test. Must be an object read from Azure DevOps API.

        .PARAMETER From
            Interval start.
            Default value is '2000-01-01T00:00:00Z'.

        .PARAMETER To
            Interval end.
            Default value is UTCNow.
    #>

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [Alias('Value', 'Item', 'InputObject')]
        $WorkItem
    )

    process {

        # if no workitem is given, return false
        if (!$WorkItem) {
            return $false
        }

        # if input is actually a 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem',
        # correct the input
        if ($WorkItem -is [PSCustomObject]) {
            # better than checking PSTypeName?
            # $WorkItem.PSObject.TypeNames -icontains 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            if ([bool]($WorkItem.PSObject.Properties.Name -ilike "WorkItem")) {
                $WorkItem = $WorkItem.WorkItem
            }
        }

        # Requirement is a test work item, if it has 'Test' or 'Testing' tag
        if ((Get-WorkItemType -WorkItem $WorkItem) -ieq 'Requirement') {
            if ($WorkItem.fields.'System.Tags' -imatch '(?:;? ?)?\b(Test)(?:ing)?') {
                return $true
            }
        }

        # Test Case is a test work item
        if ((Get-WorkItemType -WorkItem $WorkItem) -ieq 'Test Case') {
            return $true
        }

        # Other work items are Test items, if it has 'Discipline' attribute with value of 'Test'
        if ($WorkItem.fields.'Microsoft.VSTS.Common.Discipline' -ieq 'Test') {
            return $true
        }

        return $false
    }
}

Set-Alias -Name Test-ForTestWorkItem -Value Test-TestWorkItem
