function Sync-TcmTestCaseFromRemote {
    <#
        .SYNOPSIS
            Pulls test case(s) from Azure DevOps to local YAML files.

        .DESCRIPTION
            When called with -Id (numeric), treats Id as an Azure DevOps Work Item ID.
            The corresponding local YAML file will be updated or created. When -Id is omitted, the
            cmdlet pulls all test cases that have remote changes by scanning local YAML files.

        .PARAMETER Id
            The Azure DevOps Work Item ID to pull (numeric). If omitted, pulls all
            test cases that need updating.

        .PARAMETER OutputPath
            Relative path where to create the test case file (used when pulling a
            Work Item as a new test case file).

        .PARAMETER TestCasesRoot
            Root directory for test cases. If not specified, uses the default TestCases directory.

        .PARAMETER Force
            Force pull even if there are local changes (overwrite local).

        .EXAMPLE
            # Pull a single work item and create/update the local YAML file
            Sync-TcmTestCaseFromRemote -Id 12345

        .EXAMPLE
            # Pull all test cases with remote changes
            Sync-TcmTestCaseFromRemote
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        # ID of already existing Azure DevOps Work Item;
        [Alias("WorkItemId")]
        [string] $Id,

        # Optional output path (used when pulling a Work Item as a new test case file)
        [string] $OutputPath,

        [string] $TestCasesRoot,

        [switch] $Force
    )

    begin {
        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot

        # Get credentials and project info
        $collectionUri = $config.azureDevOps.collectionUri
        $project = $config.azureDevOps.project

        if (-not $collectionUri -or -not $project) {
            throw "Azure DevOps collectionUri and project must be configured in config.yaml"
        }

        $processedCount = 0
        $hasErrors = $false
    }

    process {

        try {
            # Id must be a numeric Work Item ID when provided
            if ($Id) {
                if (-not ($Id -match '^[0-9]+$')) {
                    throw "Id must be a numeric Azure DevOps Work Item ID"
                }

                $workItemId = [int]$Id
                Write-Verbose "Pulling work item $workItemId from Azure DevOps..."

                $workItem = Get-WorkItem -WorkItem $workItemId -CollectionUri $collectionUri -Project $project

                if ($workItem.fields.'System.WorkItemType' -ne 'Test Case') {
                    throw "Work item $workItemId is not a Test Case"
                }

                # Check if the work item already has a local file
                $existingFilePath = $null
                $yamlFiles = Get-ChildItem -Path $config.TestCasesRoot -Filter "*.yaml" -Recurse -File
                foreach ($file in $yamlFiles) {
                    try {
                        $fileData = Get-TcmTestCaseFromFile -FilePath $file.FullName -IncludeMetadata
                        if ($fileData.testCase.id -eq $workItemId) {
                            $existingFilePath = $file.FullName
                            break
                        }
                    } catch {
                        # Skip files that can't be parsed
                        continue
                    }
                }

                # Convert work item to test case data
                $testCaseData = ConvertFrom-TcmWorkItemToTestCase -WorkItem $workItem

                if ($existingFilePath) {
                    # Update existing local file
                    $existingData = Get-TcmTestCaseFromFile -FilePath $existingFilePath -IncludeMetadata

                    $existingData.testCase = $testCaseData
                    $existingData.testCase.title = $workItem.fields.'System.Title'
                    $existingData.testCase.id = $workItem.id
                    $existingData.history.lastModifiedAt = $workItem.fields.'System.ChangedDate'
                    $existingData.history.lastModifiedBy = $workItem.fields.'System.ChangedBy'.displayName

                    if ($PSCmdlet.ShouldProcess($existingFilePath, "Update test case file")) {
                        Save-TcmTestCaseYaml -FilePath $existingFilePath -Data $existingData -TestCasesRoot $config.TestCasesRoot

                        Write-Host "Updated test case from work item $workItemId`: $existingFilePath" -ForegroundColor Green
                        $processedCount++
                    }
                } else {
                    # Create new test case file
                    if (-not $OutputPath) {
                        $sanitizedTitle = $workItem.fields.'System.Title' -replace '[^\w\s-]', '' -replace '\s+', '-'
                        $fileName = "$workItemId-$sanitizedTitle.yaml".ToLower()
                        # Use just the filename - let Save-TcmTestCaseYaml handle folder structure
                        $OutputPath = $fileName
                    }

                    $fullOutputPath = Join-Path $config.TestCasesRoot $OutputPath

                    $fullTestCase = [ordered]@{
                        testCase = $testCaseData
                    }

                    $fullTestCase.testCase.title = $workItem.fields.'System.Title'
                    $fullTestCase.testCase.id = $workItemId

                    if ($PSCmdlet.ShouldProcess($fullOutputPath, "Create test case file")) {
                        $actualFilePath = Save-TcmTestCaseYaml -FilePath $fullOutputPath -Data $fullTestCase -TestCasesRoot $config.TestCasesRoot

                        Write-Host "Pulled work item $workItemId to: $actualFilePath" -ForegroundColor Green
                        $processedCount++
                    }
                }
            } else {
                # Pull all test cases with remote changes
                Write-Verbose "Pulling all test cases with remote changes..."

                # Scan all YAML files and check for remote changes
                $yamlFiles = Get-ChildItem -Path $config.TestCasesRoot -Filter "*.yaml" -Recurse -File

                foreach ($file in $yamlFiles) {
                    try {
                        $fileData = Get-TcmTestCaseFromFile -FilePath $file.FullName -IncludeMetadata
                        if ($fileData.testCase.id -and ($fileData.testCase.id -match '^\d+$')) {
                            $syncStatus = Get-TcmTestCaseSyncStatus -Id $fileData.testCase.id -Config $config -TestCaseData $fileData

                            if ($syncStatus -eq "remote-changes" -or ($Force -and $syncStatus -eq "conflict")) {
                                Sync-TcmTestCaseFromRemote -Id $fileData.testCase.id -TestCasesRoot $config.TestCasesRoot -Force:$Force
                                $processedCount++
                            }
                        }
                    } catch {
                        Write-Warning "Failed to process file $($file.FullName): $($_.Exception.Message)"
                        continue
                    }
                }

                if ($processedCount -eq 0) {
                    Write-Host "No test cases need to be pulled." -ForegroundColor Green
                }
            }
        } catch {
            $hasErrors = $true
            Write-Error "Failed to pull test case: $($_.Exception.Message)"
            throw
        }

    }

    end {
        if ($processedCount -gt 0 -and -not $hasErrors) {
            Write-Host "Pulled $processedCount test case(s) successfully." -ForegroundColor Green
        }
    }
}
