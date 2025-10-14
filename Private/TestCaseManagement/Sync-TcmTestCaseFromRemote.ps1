function Sync-TcmTestCaseFromRemote {
    <#
        .SYNOPSIS
            Syncs remote test case data to local YAML files.

        .DESCRIPTION
            Takes a resolved test case object with remote work item data and syncs it to a local YAML file.
            InputObject must contain RemoteData with the work item information.

        .PARAMETER InputObject
            The resolved test case object with RemoteData containing the work item information.

        .PARAMETER OutputPath
            Relative path where to create the test case file (used when pulling a
            Work Item as a new test case file).

        .PARAMETER TestCasesRoot
            Root directory for test cases. If not specified, uses the default TestCases directory.

        .PARAMETER Force
            Force pull even if there are local changes (overwrite local).

        .EXAMPLE
            # Sync remote work item data to local file
            $resolvedObject | Sync-TcmTestCaseFromRemote
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ $_.PSTypeNames -contains $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended })]
        $InputObject,

        # Optional output path (used when pulling a Work Item as a new test case file)
        [string] $OutputPath,

        [string] $TestCasesRoot,

        [switch] $Force,

        [string] $Message,

        [string] $MessageColor = 'Cyan',

        [string] $ShouldProcessOperation = "Pull from Azure DevOps"
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
        # Validate input
        if (-not $InputObject -or -not $InputObject.Id -or -not $InputObject.RemoteData) {
            throw "Invalid input: InputObject must have Id and RemoteData properties"
        }

        try {
            $workItemId = $InputObject.Id
            $workItem = $InputObject.RemoteWorkItem
            $testCaseData = $InputObject.RemoteData

            # Display message if provided
            if ($Message) {
                Write-Host "← $Message" -ForegroundColor $MessageColor
            }

            # Only process if Id looks like a Work Item ID (numeric)
            if ($workItemId -notmatch '^\d+$') {
                Write-Warning "Skipping '$workItemId': Not a numeric Work Item ID"
                return
            }

            $workItemId = [int]$workItemId

            if ($workItem -and $workItem.fields.'System.WorkItemType' -ne 'Test Case') {
                throw "Work item $workItemId is not a Test Case"
            }

            # Determine output path
            $outputPath = $InputObject.FilePath
            if (-not $outputPath) {
                if (-not $OutputPath) {
                    $sanitizedTitle = $workItem.fields.'System.Title' -replace '[^\w\s-]', '' -replace '\s+', '-'
                    $fileName = "$workItemId-$sanitizedTitle.yaml".ToLower()
                    $OutputPath = $fileName
                }
                $outputPath = Join-Path $config.TestCasesRoot $OutputPath
            }

            # Create test case data structure
            # Note: $testCaseData already has id and title set from ConvertFrom-TcmWorkItemToTestCase
            $fullTestCase = [ordered]@{
                testCase = $testCaseData
            }

            if ($PSCmdlet.ShouldProcess("Test case '$workItemId'", $ShouldProcessOperation)) {
                $actualFilePath = Save-TcmTestCaseYaml -FilePath $outputPath -Data $fullTestCase -TestCasesRoot $config.TestCasesRoot

                Write-Host "Synced test case from work item $workItemId to: $actualFilePath" -ForegroundColor Green
                $processedCount++

                # Update cache: after pull, local and remote should match
                # Re-read from disk to get the actual file content hash
                $savedTestCase = Get-TcmTestCaseFromFile -FilePath $actualFilePath
                $savedHash = Get-TcmStringHash -InputObject $savedTestCase
                Update-TcmHashCacheEntry `
                    -TestCasesRoot $config.TestCasesRoot `
                    -TestCaseId $workItemId `
                    -LocalHash $savedHash `
                    -RemoteHash $savedHash
            }
        } catch {
            $hasErrors = $true
            Write-Error "Failed to sync test case: $($_.Exception.Message)"
            throw
        }

    }

    end {
        if ($processedCount -gt 0 -and -not $hasErrors) {
            Write-Host "Pulled $processedCount test case(s) successfully." -ForegroundColor Green
        }
    }
}
