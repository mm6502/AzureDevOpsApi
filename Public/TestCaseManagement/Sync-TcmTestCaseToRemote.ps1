function Sync-TcmTestCaseToRemote {
    <#
        .SYNOPSIS
            Pushes a local test case to Azure DevOps.

        .PARAMETER InputObject
            The test case to push. Can be a test case ID (string), file path (string), or resolved object from Resolve-TcmTestCaseFilePathInput.

        .PARAMETER TestCasesRoot
            Root directory for test cases. If not specified, uses the default TestCases directory.

        .PARAMETER Force
            Force push even if there are remote changes (overwrite remote).

        .EXAMPLE
            Sync-TcmTestCaseToRemote -InputObject "TC001"

        .EXAMPLE
            Sync-TcmTestCaseToRemote -InputObject "TestCases/area/TC001.yaml"

        .EXAMPLE
            Get-ChildItem "TestCases/*.yaml" | Resolve-TcmTestCaseFilePathInput | Sync-TcmTestCaseToRemote

        .EXAMPLE
            Sync-TcmTestCaseToRemote -InputObject "TC001" -Force
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Path", "FilePath", "Id", "TestCaseId", "WorkItemId")]
        $InputObject,

        [string] $TestCasesRoot,

        [switch] $Force
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
        # Resolve input to get consistent format
        $resolved = $InputObject | Resolve-TcmTestCaseFilePathInput
        if (-not $resolved -or -not $resolved.Id) {
            throw "Invalid input: Could not resolve test case from input '$InputObject'"
        }

        $Id = $resolved.Id

        try {
            Write-Verbose "Pushing test case '$Id' to Azure DevOps..."
            Write-Verbose "CollectionUri: $collectionUri"
            Write-Verbose "Project: $project"

            # Get sync status
            $syncStatus = Get-TcmTestCaseSyncStatus -Id $Id -Config $config

            # Check for conflicts
            if ($syncStatus -eq "conflict" -and -not $Force) {
                throw "Test case '$Id' has conflicts. Use -Force to overwrite remote or run Resolve-TcmTestCaseConflict first."
            }

            if ($syncStatus -eq "synced" -and -not $Force) {
                Write-Host "Test case '$Id' is already synced. No push needed." -ForegroundColor Green
                return
            }

            # Load local test case by scanning files
            $localPath = $null

            # First try: Search for file with this ID prefix in the filename (fast)
            $pattern = "$Id-*.yaml"
            $foundFiles = Get-ChildItem -Path $config.TestCasesRoot -Filter $pattern -Recurse -File

            # Second try: If not found by filename and ID is not numeric, search file contents
            if ($foundFiles.Count -eq 0 -and $Id -notmatch '^\d+$') {
                Write-Verbose "Searching for test case '$Id' by scanning YAML file contents..."
                $allYamlFiles = Get-ChildItem -Path $config.TestCasesRoot -Filter "*.yaml" -Recurse -File

                foreach ($file in $allYamlFiles) {
                    try {
                        $content = Get-TcmTestCaseFromFile -FilePath $file.FullName -IncludeMetadata -ErrorAction SilentlyContinue
                        if ($content.testCase.id -eq $Id) {
                            $foundFiles = @($file)
                            Write-Verbose "Found test case '$Id' in file: $($file.FullName)"
                            break
                        }
                    } catch {
                        # Skip files that can't be parsed
                        continue
                    }
                }
            }

            if ($foundFiles.Count -eq 0) {
                throw "Test case '$Id' not found. Searched by filename pattern '$pattern' and file contents. Ensure the test case YAML file exists and has 'testCase.id: $Id' set."
            } elseif ($foundFiles.Count -gt 1) {
                throw "Multiple files found matching test case ID '$Id'. Please ensure unique IDs."
            }

            $localPath = $foundFiles[0].FullName
            Write-Verbose "Found local file for test case '$Id': $localPath"

            if (-not (Test-Path $localPath)) {
                throw "Local test case file not found: $localPath"
            }

            $testCaseData = Get-TcmTestCaseFromFile -FilePath $localPath -IncludeMetadata

            # Convert test steps to Azure DevOps XML format
            $stepsXml = ConvertTo-TestStepsXml -Steps $testCaseData.testCase.steps

            # Prepare work item fields (title and id now live under testCase)
            $fields = @{
                'System.Title'                        = $testCaseData.testCase.title
                'System.AreaPath'                     = $testCaseData.testCase.areaPath
                'System.IterationPath'                = $testCaseData.testCase.iterationPath
                'System.State'                        = $testCaseData.testCase.state
                'Microsoft.VSTS.Common.Priority'      = $testCaseData.testCase.priority
                'System.Description'                  = $testCaseData.testCase.description
                'Microsoft.VSTS.TCM.LocalDataSource'  = $testCaseData.testCase.preconditions
                'Microsoft.VSTS.TCM.Steps'            = $stepsXml
                'Microsoft.VSTS.TCM.AutomationStatus' = $testCaseData.testCase.automationStatus
            }

            # Add tags if present
            if ($testCaseData.testCase.tags -and $testCaseData.testCase.tags.Count -gt 0) {
                $fields['System.Tags'] = $testCaseData.testCase.tags -join ';'
            }

            # Add assigned to if present
            if ($testCaseData.testCase.assignedTo) {
                $fields['System.AssignedTo'] = $testCaseData.testCase.assignedTo
            }

            # Add custom fields
            foreach ($key in $testCaseData.testCase.customFields.Keys) {
                $fields[$key] = $testCaseData.testCase.customFields[$key]
            }

            # Create or update work item
            # The $Id is the Work Item ID if numeric, otherwise treated as a local-only id
            $remoteWorkItem = $null
            if ($Id -match '^\d+$') {
                # Try to fetch existing work item (ID is numeric, so it might be a Work Item ID)
                try {
                    $remoteWorkItem = Get-WorkItem -WorkItem $Id -CollectionUri $collectionUri -Project $project -ErrorAction Stop
                } catch {
                    # Work item doesn't exist - will create it below
                    Write-Verbose "Work item $Id not found, will create new work item"
                    $remoteWorkItem = $null
                }
            }

            if ($remoteWorkItem) {
                # Update existing work item
                if ($PSCmdlet.ShouldProcess("Work Item $Id", "Update test case")) {

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
                }
            } else {
                # Create new work item (ID is not found remotely or not numeric)
                if ($PSCmdlet.ShouldProcess($project, "Create new test case")) {
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
                    $title = $fields.'System.Title' -replace '[^\w\s-]', '' -replace '\s+', '-'
                    $newFileName = "$newWorkItemId-$title".ToLower() + ".yaml"
                    $newFullPath = Join-Path (Split-Path -Parent $localPath) $newFileName

                    # Only rename if the filename is different
                    if ($localPath -ne $newFullPath) {
                        # Replace existing file by new content and rename without losing data on failure
                        $tmpPath = [System.IO.Path]::GetTempFileName()
                        try {
                            Save-TcmTestCaseYaml -FilePath $tmpPath -Data $updatedData

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
                }
            }

            Write-Verbose "Test case '$($workItem.id)' pushed successfully"
        } catch {
            Write-Error "Failed to push test case '$Id': $($_.Exception.Message)"
            throw
        }
    }
}
