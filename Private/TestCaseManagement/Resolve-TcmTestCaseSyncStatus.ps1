function Resolve-TcmTestCaseSyncStatus {
    <#
        .SYNOPSIS
            Determines the sync status of a test case by comparing local and remote states.

        .DESCRIPTION
            Uses a hash cache (.tcm-hashes.json) to implement 3-way merge logic:
            - Compares current local hash with cached local hash (detects local changes)
            - Compares current remote hash with cached remote hash (detects remote changes)
            - Determines sync status based on change patterns:
              * synced: No changes detected
              * local-changes: Only local changed since last sync
              * remote-changes: Only remote changed since last sync
              * conflict: Both local and remote changed since last sync
              * new-local: Test case exists only locally (non-numeric ID or no cache entry)
              * new-remote: Test case exists only remotely (no local file)

        .PARAMETER InputObject
            Extended test case object from Get-TcmTestCase containing Id, LocalData, RemoteData, LocalDataHash, RemoteDataHash, etc.

        .PARAMETER Config
            Configuration object from Get-TcmTestCaseConfig.

        .OUTPUTS
            The input object with SyncStatus property set.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')]
        [object] $InputObject,

        [Parameter(Mandatory)]
        [hashtable] $Config
    )

    try {
        $Id = $InputObject.Id

        # If ID is not numeric, it's a new local test case (not synced yet)
        if (-not ($Id -match '^\d+$')) {
            $InputObject.SyncStatus = "new-local"
            return $InputObject
        }

        # Load hash cache
        $hashCache = Get-TcmHashCache -TestCasesRoot $Config.TestCasesRoot
        $cachedEntry = $hashCache[$Id]

        # Check what data exists (already loaded by Get-TcmTestCase)
        $localExists = $null -ne $InputObject.LocalData
        $remoteExists = $null -ne $InputObject.RemoteData

        # If local file doesn't exist but cache entry does, invalidate cache (file was deleted)
        if (-not $localExists -and $cachedEntry) {
            Write-Verbose "Cache entry exists for test case '$Id' but local file is missing - invalidating cache entry"
            $cachedEntry = $null
        }

        # Case 1: No local and no remote = new-local (shouldn't happen with numeric ID)
        if (-not $localExists -and -not $remoteExists) {
            $InputObject.SyncStatus = "new-local"
            return $InputObject
        }

        # Case 2: No local but remote exists = new-remote
        if (-not $localExists -and $remoteExists) {
            $InputObject.SyncStatus = "new-remote"
            return $InputObject
        }

        # Case 3: Local exists but no remote = new-local or local-changes
        if ($localExists -and -not $remoteExists) {
            if (-not $cachedEntry) {
                # No cache entry = never synced = new-local
                $InputObject.SyncStatus = "new-local"
            }
            else {
                # Had cache entry but remote gone = local-changes (assume we want to re-create)
                $InputObject.SyncStatus = "local-changes"
            }
            return $InputObject
        }

        # Case 4: Both local and remote exist - use pre-calculated hashes
        $localHash = $InputObject.LocalDataHash
        $remoteHash = $InputObject.RemoteDataHash

        Write-Verbose "Local hash for test case '$Id': $localHash"
        Write-Verbose "Remote hash for test case '$Id': $remoteHash"

        # If no cache entry exists, determine initial sync status
        if (-not $cachedEntry) {
            Write-Verbose "No cache entry found for test case '$Id' - determining initial status"
            if ($localHash -eq $remoteHash) {
                # Already in sync, create cache entry
                $InputObject.SyncStatus = "synced"
            }
            else {
                # Different but never synced - assume local-changes (local is source of truth)
                $InputObject.SyncStatus = "local-changes"
            }
            return $InputObject
        }

        # Compare with cached hashes to detect changes
        $cachedLocalHash = $cachedEntry.local
        $cachedRemoteHash = $cachedEntry.remote

        $localChanged = ($null -ne $cachedLocalHash -and $localHash -ne $cachedLocalHash)
        $remoteChanged = ($null -ne $cachedRemoteHash -and $remoteHash -ne $cachedRemoteHash)

        Write-Verbose "Cache comparison for test case '$Id': localChanged=$localChanged, remoteChanged=$remoteChanged"
        Write-Verbose "  Current local: $localHash, Cached local: $cachedLocalHash"
        Write-Verbose "  Current remote: $remoteHash, Cached remote: $cachedRemoteHash"

        # Determine sync status based on change pattern
        if (-not $localChanged -and -not $remoteChanged) {
            # No changes since last sync
            $InputObject.SyncStatus = "synced"
        }
        elseif ($localChanged -and -not $remoteChanged) {
            # Only local changed since last sync
            $InputObject.SyncStatus = "local-changes"
        }
        elseif (-not $localChanged -and $remoteChanged) {
            # Only remote changed since last sync
            $InputObject.SyncStatus = "remote-changes"
        }
        else {
            # Both changed since last sync = conflict
            $InputObject.SyncStatus = "conflict"
        }

        return $InputObject
    }
    catch {
        throw "Failed to determine sync status for test case '$Id': $($_.Exception.Message)"
    }
}
