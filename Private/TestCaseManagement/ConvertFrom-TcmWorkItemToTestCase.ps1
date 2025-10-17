function ConvertFrom-TcmWorkItemToTestCase {
    <#
        .SYNOPSIS
            Converts an Azure DevOps work item to test case format.

        .PARAMETER WorkItem
            The work item object from Azure DevOps.

        .OUTPUTS
            Hashtable representing the test case data structure.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $WorkItem
    )

    try {
        $fields = $WorkItem.fields

        # Extract test steps if present
        $steps = @()
        if ($fields.'Microsoft.VSTS.TCM.Steps') {
            # Parse XML test steps
            [xml]$stepsXml = $fields.'Microsoft.VSTS.TCM.Steps'
            $stepNumber = 1

            foreach ($step in $stepsXml.steps.step) {
                # Process both ActionStep and ValidateStep (portal creates ValidateStep)
                if ($step.type -eq 'ActionStep' -or $step.type -eq 'ValidateStep') {
                    # Build step with explicit order: stepNumber, attachments, action, expectedResult
                    $orderedStep = [ordered]@{}
                    $orderedStep['stepNumber'] = $stepNumber
                    $orderedStep['attachments'] = @()

                    # CDATA sections use '#cdata-section' property, not '#text'
                    # Portal-edited steps use '#text' with HTML entities, API-created steps use '#cdata-section'
                    # PS5 compatible: use if/else instead of ?? operator
                    if ($step.parameterizedString[0].'#cdata-section') {
                        $actionRaw = $step.parameterizedString[0].'#cdata-section'
                    } elseif ($step.parameterizedString[0].'#text') {
                        $actionRaw = $step.parameterizedString[0].'#text'
                    } else {
                        $actionRaw = ''
                    }

                    if ($step.parameterizedString[1].'#cdata-section') {
                        $expectedResultRaw = $step.parameterizedString[1].'#cdata-section'
                    } elseif ($step.parameterizedString[1].'#text') {
                        $expectedResultRaw = $step.parameterizedString[1].'#text'
                    } else {
                        $expectedResultRaw = ''
                    }

                    # Strip HTML tags from the content (portal adds <DIV>, <P> tags)
                    $orderedStep['action'] = ($actionRaw -replace '<[^>]+>', '').Trim()
                    $orderedStep['expectedResult'] = ($expectedResultRaw -replace '<[^>]+>', '').Trim()

                    $steps += $orderedStep
                    $stepNumber++
                }
            }
        }

        # If no steps were parsed, ensure there is at least one empty default step
        if (-not $steps -or $steps.Count -eq 0) {
            # Default empty step with explicit ordering
            $defaultStep = [ordered]@{}
            $defaultStep['stepNumber'] = 1
            $defaultStep['attachments'] = @()
            $defaultStep['action'] = ""
            $defaultStep['expectedResult'] = ""
            $steps = @($defaultStep)
        }

        # Build test case data structure
        $testCaseData = [ordered]@{
            id = $WorkItem.id
            title = $fields.'System.Title'
            areaPath = $fields.'System.AreaPath'
            iterationPath = $fields.'System.IterationPath'
            state = $fields.'System.State'
            # PS5 compatible: use if/else instead of ?? operator
            # Note: Extract values first, then build hashtable (PS5 doesn't support if expressions in hashtable literals)
            priority = [int]$(if ($fields.'Microsoft.VSTS.Common.Priority') { $fields.'Microsoft.VSTS.Common.Priority' } else { 2 })
            assignedTo = $(if ($fields.'System.AssignedTo'.displayName) { $fields.'System.AssignedTo'.displayName } else { "" })
            tags = $(if ($fields.'System.Tags') { ($fields.'System.Tags' -split ';' | Where-Object { $_ }) } else { @() })
            description = $(if ($fields.'System.Description') { $fields.'System.Description' } else { "" })
            preconditions = $(if ($fields.'Microsoft.VSTS.TCM.LocalDataSource') { $fields.'Microsoft.VSTS.TCM.LocalDataSource' } else { "" })
            steps = $steps
            automationStatus = $(if ($fields.'Microsoft.VSTS.TCM.AutomationStatus') { $fields.'Microsoft.VSTS.TCM.AutomationStatus' } else { "Not Automated" })
            customFields = @{}
        }

        # Extract custom fields (any field not in the standard set)
        $standardFields = @(
            'System.Id', 'System.Title', 'System.AreaPath', 'System.IterationPath',
            'System.State', 'System.AssignedTo', 'System.Tags', 'System.Description',
            'System.CreatedDate', 'System.CreatedBy', 'System.ChangedDate', 'System.ChangedBy',
            'Microsoft.VSTS.Common.Priority', 'Microsoft.VSTS.TCM.Steps',
            'Microsoft.VSTS.TCM.LocalDataSource', 'Microsoft.VSTS.TCM.AutomationStatus'
        )

        foreach ($fieldName in $fields.Keys) {
            if ($fieldName -notin $standardFields) {
                $testCaseData.customFields[$fieldName] = $fields[$fieldName]
            }
        }

        return $testCaseData
    }
    catch {
        throw "Failed to convert work item to test case format: $($_.Exception.Message)"
    }
}
