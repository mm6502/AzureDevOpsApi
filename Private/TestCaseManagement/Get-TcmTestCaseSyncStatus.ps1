function Get-TcmTestCaseSyncStatus {
    <#
        .SYNOPSIS
            Determines the sync status of a test case by comparing local and remote states.

        .PARAMETER Id
            The local ID of the test case.

        .PARAMETER Config
            Configuration object from Get-TcmTestCaseConfig.

        .PARAMETER TestCaseData
            The local test case data object (optional, will be loaded if not provided).

        .PARAMETER RemoteWorkItem
            The remote work item from Azure DevOps (optional, will be fetched if not provided).

        .OUTPUTS
            String representing the sync status: 'synced', 'local-changes', 'remote-changes', 'conflict', 'new-local', 'new-remote'
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Id,

        [Parameter(Mandatory)]
        [hashtable] $Config,

    [object] $TestCaseData,

    [object] $RemoteWorkItem
    )

    try {
        # If ID is not numeric, it's a new local test case (not synced yet)
        if (-not ($Id -match '^\d+$')) {
            return "new-local"
        }

        # For numeric IDs, check if local file exists
        $localFileExists = $false
        $localFilePath = $null

        if (-not $TestCaseData) {
            # Find local file by scanning directory
            $yamlFiles = Get-ChildItem -Path $Config.TestCasesRoot -Filter "*.yaml" -Recurse -File
            foreach ($file in $yamlFiles) {
                try {
                    $fileData = Get-TcmTestCaseFromFile -FilePath $file.FullName -IncludeMetadata
                    if ($fileData.testCase.id -eq $Id) {
                        $TestCaseData = $fileData
                        $localFilePath = $file.FullName
                        $localFileExists = $true
                        break
                    }
                }
                catch {
                    # Skip files that can't be parsed
                    continue
                }
            }
        } else {
            $localFileExists = $true
        }

        # If no local file exists with this ID, it's new-remote
        if (-not $localFileExists) {
            return "new-remote"
        }

        # Load local test case if not provided
        if (-not $TestCaseData) {
            $TestCaseData = Get-TcmTestCaseFromFile -FilePath $localFilePath -IncludeMetadata
        }

        # Calculate current local hash
        $localHash = Get-TcmStringHash -InputObject $TestCaseData.testCase
        Write-Verbose "Local hash for test case '$Id': $localHash"

        # Fetch remote work item if not provided
        if (-not $RemoteWorkItem) {
            try {
                # Pass parameters expected by Get-WorkItem: use -WorkItem and include collection/project
                $collection = $null
                $project = $null
                if ($Config.azureDevOps) {
                    $collection = $Config.azureDevOps.collectionUri
                    $project = $Config.azureDevOps.project
                }

                $RemoteWorkItem = Get-WorkItem -WorkItem $Id -CollectionUri $collection -Project $project -ErrorAction Stop
            }
            catch {
                Write-Warning "Failed to fetch remote work item ${Id}: $($_.Exception.Message)"
                # If we can't fetch remote, assume local changes (since we have local file)
                return "local-changes"
            }
        }

        # Calculate remote hash if we have remote work item
        $remoteChanged = $false
        if ($RemoteWorkItem) {
            # Convert remote work item to comparable format
            $remoteTestCaseData = ConvertFrom-TcmWorkItemToTestCase -WorkItem $RemoteWorkItem
            $remoteHash = Get-TcmStringHash -InputObject $remoteTestCaseData
            Write-Verbose "Remote hash for test case '$Id': $remoteHash"

            $remoteChanged = $false  # We just fetched remote, so no remote changes detected
        }

        # Compare local hash with remote hash
        $localChanged = $false
        if ($RemoteWorkItem) {
            $localChanged = ($localHash -ne $remoteHash)
            Write-Verbose "Hash comparison for test case '$Id': localChanged=$localChanged, remoteChanged=$remoteChanged"
        } else {
            # If no remote work item, local is new
            $localChanged = $true
        }

        # Determine sync status based on changes
        if ($localChanged -and $remoteChanged) {
            return "conflict"
        }
        elseif ($localChanged) {
            return "local-changes"
        }
        elseif ($remoteChanged) {
            return "remote-changes"
        }
        else {
            return "synced"
        }
    }
    catch {
        throw "Failed to determine sync status for test case '$Id': $($_.Exception.Message)"
    }
}
