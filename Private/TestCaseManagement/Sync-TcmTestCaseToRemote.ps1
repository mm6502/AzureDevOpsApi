function Sync-TcmTestCaseToRemote {
    <#
        .SYNOPSIS
            Pushes a local test case to Azure DevOps.

        .PARAMETER InputObject
            The resolved test case object from ConvertTo-TcmTestCaseInput with PSTypeName 'PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended'.

        .PARAMETER TestCasesRoot
            Root directory for test cases. If not specified, uses the default TestCases directory.

        .PARAMETER Force
            Force push even if there are remote changes (overwrite remote).

        .EXAMPLE
            "TC001" | ConvertTo-TcmTestCaseInput | Sync-TcmTestCaseToRemote

        .EXAMPLE
            "TestCases/area/TC001.yaml" | ConvertTo-TcmTestCaseInput | Sync-TcmTestCaseToRemote

        .EXAMPLE
            Get-ChildItem "TestCases/*.yaml" | ConvertTo-TcmTestCaseInput | Sync-TcmTestCaseToRemote

        .EXAMPLE
            "TC001" | ConvertTo-TcmTestCaseInput | Sync-TcmTestCaseToRemote -Force
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ $_.PSTypeNames -contains $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended })]
        $InputObject,

        [string] $TestCasesRoot,

        [switch] $Force,

        [string] $Message,

        [string] $MessageColor = 'Cyan',

        [string] $ShouldProcessOperation = "Push to Azure DevOps"
    )

    begin {
        $Force = $Force.IsPresent -and ($true -eq $Force)

        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot

        # Get credentials and project info
        $collectionUri = $config.azureDevOps.collectionUri
        $project = $config.azureDevOps.project

        if (-not $collectionUri -or -not $project) {
            throw "Azure DevOps collectionUri and project must be configured in config.yaml"
        }
    }

    process {
        # Validate input: function expects already-resolved test case input (LocalData present)
        if (-not $InputObject -or -not $InputObject.LocalData) {
            throw "Invalid input: InputObject must be a resolved TcmTestCaseExtended with LocalData populated"
        }

        $testCaseData = $InputObject.LocalData
        $Id = if ($InputObject.Id) { $InputObject.Id } else { $testCaseData.id }
        $localPath = $InputObject.FilePath

        try {
            # Display message if provided
            if ($Message) {
                Write-Host "→ $Message" -ForegroundColor $MessageColor
            }

            Write-Verbose "Pushing test case '$Id' to Azure DevOps..."
            Write-Verbose "CollectionUri: $collectionUri"
            Write-Verbose "Project: $project"

            # Get sync status
            $resolved = Resolve-TcmTestCaseSyncStatus -InputObject $InputObject -Config $config
            $syncStatus = $resolved.SyncStatus

            # Check for conflicts
            if ($syncStatus -eq 'conflict' -and -not $Force) {
                throw "Test case '$Id' has conflicts. Use -Force to overwrite remote or run Resolve-TcmTestCaseConflict first."
            }

            if ($syncStatus -eq 'synced' -and -not $Force) {
                Write-Host "Test case '$Id' is already synced. No push needed." -ForegroundColor Green
                return
            }

            # Convert test steps to Azure DevOps XML format
            $stepsXml = ConvertTo-TestStepsXml -Steps $testCaseData.steps

            # Prepare work item fields (LocalData contains the test case structure)
            $fields = @{
                'System.Title'                        = $testCaseData.title
                'System.AreaPath'                     = $testCaseData.areaPath
                'System.IterationPath'                = $testCaseData.iterationPath
                'System.State'                        = $testCaseData.state
                'Microsoft.VSTS.Common.Priority'      = $testCaseData.priority
                'System.Description'                  = $testCaseData.description
                'Microsoft.VSTS.TCM.LocalDataSource'  = $testCaseData.preconditions
                'Microsoft.VSTS.TCM.Steps'            = $stepsXml
                'Microsoft.VSTS.TCM.AutomationStatus' = $testCaseData.automationStatus
            }

            # Add tags if present
            if ($testCaseData.tags -and $testCaseData.tags.Count -gt 0) {
                $fields['System.Tags'] = $testCaseData.tags -join ';'
            }

            # Add assigned to if present
            if ($testCaseData.assignedTo) {
                $fields['System.AssignedTo'] = $testCaseData.assignedTo
            }

            # Add custom fields
            if ($testCaseData.customFields) {
                foreach ($key in $testCaseData.customFields.Keys) {
                    $fields[$key] = $testCaseData.customFields[$key]
                }
            }

            # Create or update work item
            # The $Id is the Work Item ID if numeric, otherwise treated as a local-only id
            $remoteWorkItem = $null
            if ($Id -match '^\d+$') {
                # Try to fetch existing work item (ID is numeric, so it might be a Work Item ID)
                try {
                    $remoteWorkItem = Get-WorkItem `
                        -WorkItem $Id `
                        -CollectionUri $collectionUri `
                        -Project $project `
                        -ErrorAction Stop
                } catch {
                    # Work item doesn't exist - will create it below
                    Write-Verbose "Work item $Id not found, will create new work item"
                    $remoteWorkItem = $null
                }
            }

            if ($remoteWorkItem) {
                # Update existing work item
                if ($PSCmdlet.ShouldProcess("Test case '$Id'", $ShouldProcessOperation)) {

                    # Create a minimal patch document for update (avoid copying source field objects)
                    $workItemType = $remoteWorkItem.fields.'System.WorkItemType'
                    $patchDoc = New-PatchDocument -WorkItemType $workItemType -Data $fields

                    # Ensure patch document contains WorkItemUrl so Update-WorkItem can resolve connection
                    $patchDoc.WorkItemUrl = $remoteWorkItem.url

                    # Add a test operation for current revision to avoid races
                    if ($remoteWorkItem.rev) {
                        $patchDoc.Operations += [PSCustomObject]@{
                            op    = 'test'
                            path  = '/rev'
                            value = "$($remoteWorkItem.rev)"
                        }
                    }

                    # Send patch document to Update-WorkItem
                    $workItem = $patchDoc | Update-WorkItem -ErrorAction Stop

                    Write-Host "Updated test case '$Id' in Azure DevOps (Work Item: $Id)" -ForegroundColor Green

                    # Update cache: after push, local and remote should match
                    $localHash = Get-TcmStringHash -InputObject $InputObject.LocalData
                    Update-TcmHashCacheEntry `
                        -TestCasesRoot $config.TestCasesRoot `
                        -TestCaseId $workItem.id `
                        -Hash $localHash
                }
            } else {
                # Create new work item (ID is not found remotely or not numeric)
                if ($PSCmdlet.ShouldProcess("Test case '$Id'", $ShouldProcessOperation)) {
                    Write-Verbose "Creating new work item with CollectionUri='$collectionUri' and Project='$project'"

                    # Build patch document for creation
                    $patchDoc = New-PatchDocumentCreate -WorkItemType "Test Case" -Data $fields

                    # Create the work item in the project and collection
                    $workItem = $patchDoc | New-WorkItem -Project $project -CollectionUri $collectionUri -ErrorAction Stop

                    Write-Host "Created test case '$Id' in Azure DevOps (Work Item: $($workItem.id))" -ForegroundColor Green

                    # Update testCase in YAML file with Azure DevOps ID and ensure title is preserved
                    # Create a fresh ordered testCase block with the new work item id
                    $updatedTestCase = [ordered]@{
                        id               = $workItem.id
                        title            = $fields.'System.Title'
                        areaPath         = $testCaseData.testCase.areaPath
                        iterationPath    = $testCaseData.testCase.iterationPath
                        tags             = $testCaseData.testCase.tags
                        assignedTo       = $testCaseData.testCase.assignedTo
                        description      = $testCaseData.testCase.description
                        state            = $testCaseData.testCase.state
                        customFields     = $testCaseData.testCase.customFields
                        preconditions    = $testCaseData.testCase.preconditions
                        priority         = $testCaseData.testCase.priority
                        automationStatus = $testCaseData.testCase.automationStatus
                        steps            = $testCaseData.testCase.steps
                    }

                    $updatedData = [ordered]@{ testCase = $updatedTestCase }
                    if ($testCaseData.PSObject.Properties.Name -contains 'history') {
                        $updatedData.history = $testCaseData.history
                    }

                    # Keep in-memory representation in sync
                    $testCaseData.testCase = $updatedTestCase

                    # Build new filename prefixed with server id
                    $newWorkItemId = [int]$workItem.id
                    $title = $updatedTestCase.title -replace '[^\w\s-]', '' -replace '\s+', '-'
                    $newFileName = "$newWorkItemId-$title".ToLower() + ".yaml"
                    $newFullPath = Join-Path (Split-Path -Parent $localPath) $newFileName

                    # Only rename if the filename is different
                    if ($localPath -ne $newFullPath) {
                        # Replace existing file by new content and rename without losing data on failure
                        $tmpPath = [System.IO.Path]::GetTempFileName()
                        try {
                            Save-TcmTestCaseYaml -FilePath $tmpPath -Data $updatedData -TestCasesRoot $config.TestCasesRoot

                            Move-Item -Path $localPath -Destination ($localPath + '.bak') -Force
                            Move-Item -Path $tmpPath -Destination $newFullPath -Force
                            Remove-Item -Path ($localPath + '.bak') -Force -ErrorAction SilentlyContinue
                        } catch {
                            Remove-Item -Path $tmpPath -Force -ErrorAction SilentlyContinue
                            throw
                        }

                        # Update variables to reflect renamed file
                        $localPath = $newFullPath
                    } else {
                        # File already has correct name, just update content
                        Save-TcmTestCaseYaml -FilePath $localPath -Data $updatedData
                    }

                    # Update cache: after push, local and remote should match
                    # Re-read from disk to get the actual file content hash
                    $savedTestCase = Get-TcmTestCaseFromFile -FilePath $localPath
                    $savedHash = Get-TcmStringHash -InputObject $savedTestCase
                    Update-TcmHashCacheEntry `
                        -TestCasesRoot $config.TestCasesRoot `
                        -TestCaseId $workItem.id `
                        -Hash $savedHash
                }
            }

            Write-Verbose "Test case '$($workItem.id)' pushed successfully"

        } catch {
            Write-Error "Failed to push test case '$Id': $($_.Exception.Message)"
            throw
        }
    }
}
