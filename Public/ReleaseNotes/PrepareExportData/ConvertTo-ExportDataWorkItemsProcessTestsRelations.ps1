function ConvertTo-ExportDataWorkItemsProcessTestsRelations {

    <#
        .SYNOPSIS
            Converts set of ReleaseNotesDataItems to ExportData - WorkItems subset.

            Evaluates the relations of the given work item and returns distinct
            work item states from all work items that are tested by the given work item.

        .PARAMETER Items
            Hashtable of ReleaseNotesDataItems.

        .PARAMETER Item
            The current Item being processed.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = ''
    )]
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 1)]
        [hashtable] $Items,

        [PSTypeNameAttribute('PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem')]
        [Parameter(Mandatory, ValueFromPipeline)]
        $Item
    )

    process {

        # determine, whether given item is a test item
        # if not, return N/A equivalent
        if (-not (Test-TestWorkItem -WorkItem $Item.WorkItem)) {
            return $null
        }

        # otherwise try to inspect the Tests relations

        $collectedStates = [System.Collections.Generic.HashSet[string]]::new()
        $stack = [System.Collections.Generic.Stack[object]]::new()
        $visited = [System.Collections.Generic.HashSet[object]]::new()
        $null = $stack.Push($Item)
        $null = $visited.Add($Item)

        while ($stack.Count -gt 0) {

            $current = $stack.Pop()

            # determine, whether current item is a test item
            $isTestWorkItem = Test-TestWorkItem -WorkItem $current.WorkItem

            # if not a Test work item, we followed the Tests relations to actual work item
            # to be tested, just return the item state
            if (-not $isTestWorkItem) {
                $null = $collectedStates.Add($current.WorkItem.fields.'System.State')
                continue;
            }

            # otherwise inspect the Tests relations

            # retrieve the target urls of Tests relations;
            $testsTargetsUrls = $current.RelationsList `
            | Where-Object { $_.Name -ieq 'Tests' } `
            | Select-Object -ExpandProperty 'Relations'

            # check whether there are any
            if (!$testsTargetsUrls) {
                # if not, nothing to do
                continue
            }

            # iterate over all related tested items,
            # following the relations recursively to the real tested items
            # (i.e. transparently interpret test requirements as test cases for this purpose)
            foreach ($testsTargetUrl in $testsTargetsUrls) {
                # 'recursivelly' call on all related items
                $testsTargetItem = $Items[[string] $testsTargetUrl]
                # only push the item, if it is not already visited;
                # protection against infinite loops
                if ($testsTargetItem -and -not $visited.Contains($testsTargetItem)) {
                    $null = $stack.Push($testsTargetItem)
                    $null = $visited.Add($testsTargetItem)
                }
            }
        }

        # evaluate and prepare result
        $result = @()
        if ($collectedStates.Contains('Proposed')) {
            $result += 'Proposed'
        }
        if ($collectedStates.Contains('Active')) {
            $result += 'Active'
        }
        if ($collectedStates.Contains('Resolved')) {
            $result += 'Resolved'
        }
        if ($collectedStates.Contains('Closed')) {
            $result += 'Closed'
        }

        # return the result
        $result -join ', '
    }
}
