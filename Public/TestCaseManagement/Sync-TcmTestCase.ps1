function Sync-TcmTestCase {
    <#
        .SYNOPSIS
            Synchronizes test cases between local YAML files and Azure DevOps.

        .DESCRIPTION
            Synchronizes test case data between local YAML files and Azure DevOps work items.
            Supports bidirectional synchronization, push-only, and pull-only operations.
            Automatically detects sync status and handles conflicts based on the specified resolution strategy.

            The function compares content hashes to determine if local and remote versions differ,
            and performs the appropriate sync operation based on the direction and conflict resolution settings.

        .PARAMETER InputObject
            The local test case to synchronize. Accepts:
            - Test case ID (string) - e.g., "TC001"
            - File path (string) - relative or absolute path to YAML file
            - Test case object (hashtable) - from Get-TcmTestCase
            Accepts pipeline input by value or property name.
            If not specified, synchronizes all test cases found by Get-TcmTestCase.

        .PARAMETER Direction
            Direction of synchronization:
            - Bidirectional: Push local changes and pull remote changes (default)
            - ToRemote: Only push local changes to Azure DevOps
            - FromRemote: Only pull changes from Azure DevOps

        .PARAMETER TestCasesRoot
            Root directory containing test case YAML files.
            If not specified, uses the current directory or searches parent directories for .tcm-config.yaml.

        .PARAMETER ConflictResolution
            How to handle conflicts when both local and remote versions have changes:
            - Manual: Stop and require manual resolution (default)
            - LocalWins: Use local version, overwrite remote
            - RemoteWins: Use remote version, overwrite local
            - LatestWins: Use the version with the most recent modification date

        .PARAMETER WhatIf
            Shows what would happen if the cmdlet runs without actually performing the sync operations.

        .EXAMPLE
            PS C:\> Sync-TcmTestCase -InputObject "TC001"

            Synchronizes test case TC001 bidirectionally using default settings.

        .EXAMPLE
            PS C:\> Get-TcmTestCase -Id "TC*" | Sync-TcmTestCase -Direction ToRemote

            Gets all test cases matching "TC*" and pushes them to Azure DevOps.

        .EXAMPLE
            PS C:\> Sync-TcmTestCase -InputObject "authentication/TC001-login.yaml" -Direction FromRemote -ConflictResolution RemoteWins

            Pulls the latest version from Azure DevOps for the specified file, using remote version in case of conflicts.

        .EXAMPLE
            PS C:\> Sync-TcmTestCase -WhatIf

            Shows what sync operations would be performed without making any changes.

        .EXAMPLE
            PS C:\> Sync-TcmTestCase

            Synchronizes all test cases bidirectionally using default settings.

        .INPUTS
            System.String
            System.Collections.Hashtable
            Accepts test case IDs, file paths, or test case objects from the pipeline.

        .OUTPUTS
            None. The function displays progress and results to the console.

        .NOTES
            - Requires a valid .tcm-config.yaml configuration file.
            - Azure DevOps credentials must be configured for the target collection and project.
            - Sync operations are atomic per test case to prevent partial updates.
            - Use -WhatIf to preview changes before executing.
            - Conflict resolution strategies only apply when both versions have changes.

        .LINK
            Get-TcmTestCase

        .LINK
            Resolve-TcmTestCaseConflict

        .LINK
            New-TcmConfig
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Path", "Id", "TestCaseId", "WorkItemId")]
        $InputObject,

        [ValidateSet('Bidirectional', 'ToRemote', 'FromRemote')]
        [string] $Direction = 'Bidirectional',

        [string] $TestCasesRoot,

        [ValidateSet('Manual', 'LocalWins', 'RemoteWins', 'LatestWins')]
        [string] $ConflictResolution = 'Manual'
    )

    begin {
        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot

        # Override conflict resolution from config if not specified
        if ($PSBoundParameters.ContainsKey('ConflictResolution') -eq $false) {
            $ConflictResolution = $config.sync.conflictResolution
        }

        # Override direction from config if not specified
        if ($PSBoundParameters.ContainsKey('Direction') -eq $false) {
            $Direction = $config.sync.direction
        }

        $stats = @{
            Processed = 0
            Synced    = 0
            Conflicts = 0
            Errors    = 0
            Skipped   = 0
        }

        Write-Verbose "Starting sync with direction: $Direction, conflict resolution: $ConflictResolution"
    }

    process {

        foreach ($resolved in ($InputObject | Resolve-TcmTestCaseFilePathInput -TestCasesRoot $config.TestCasesRoot)) {

            $testCaseId = $resolved.Id
            $stats.Processed++

            try {
                Write-Verbose "Syncing test case '$testCaseId'..."

                # Determine sync status
                $syncStatus = Get-TcmTestCaseSyncStatus -Id $testCaseId -Config $config
                Write-Verbose "Test case '$testCaseId' status: $syncStatus"

                switch ($syncStatus) {
                    'synced' {
                        Write-Host "✓ Test case '$testCaseId' is already synced" -ForegroundColor Green
                        $stats.Synced++
                    }

                    'new-local' {
                        if ($Direction -in @('Bidirectional', 'ToRemote')) {
                            if ($PSCmdlet.ShouldProcess("Test case '$testCaseId'", "Push to Azure DevOps")) {
                                Write-Host "→ Pushing new test case '$testCaseId' to Azure DevOps..." -ForegroundColor Cyan
                                Sync-TcmTestCaseToRemote -InputObject $testCaseId -TestCasesRoot $config.TestCasesRoot
                                $stats.Synced++
                            }
                        } else {
                            Write-Host "○ Skipping test case '$testCaseId' (new local, direction: $Direction)" -ForegroundColor Yellow
                            $stats.Skipped++
                        }
                    }

                    'local-changes' {
                        if ($Direction -in @('Bidirectional', 'ToRemote')) {
                            if ($PSCmdlet.ShouldProcess("Test case '$testCaseId'", "Push changes to Azure DevOps")) {
                                Write-Host "→ Pushing changes for test case '$testCaseId' to Azure DevOps..." -ForegroundColor Cyan
                                Sync-TcmTestCaseToRemote -InputObject $testCaseId -TestCasesRoot $config.TestCasesRoot
                                $stats.Synced++
                            }
                        } else {
                            Write-Host "○ Skipping test case '$testCaseId' (local changes, direction: $Direction)" -ForegroundColor Yellow
                            $stats.Skipped++
                        }
                    }

                    'remote-changes' {
                        if ($Direction -in @('Bidirectional', 'FromRemote')) {
                            if ($PSCmdlet.ShouldProcess("Test case '$testCaseId'", "Pull changes from Azure DevOps")) {
                                Write-Host "← Pulling changes for test case '$testCaseId' from Azure DevOps..." -ForegroundColor Cyan
                                Sync-TcmTestCaseFromRemote -Id $testCaseId -TestCasesRoot $config.TestCasesRoot
                                $stats.Synced++
                            }
                        } else {
                            Write-Host "○ Skipping test case '$testCaseId' (remote changes, direction: $Direction)" -ForegroundColor Yellow
                            $stats.Skipped++
                        }
                    }

                    'new-remote' {
                        if ($Direction -in @('Bidirectional', 'FromRemote')) {
                            if ($PSCmdlet.ShouldProcess("Test case '$testCaseId'", "Pull from Azure DevOps")) {
                                Write-Host "← Pulling test case '$testCaseId' from Azure DevOps..." -ForegroundColor Cyan
                                Sync-TcmTestCaseFromRemote -Id $testCaseId -TestCasesRoot $config.TestCasesRoot
                                $stats.Synced++
                            }
                        } else {
                            Write-Host "○ Skipping test case '$testCaseId' (new remote, direction: $Direction)" -ForegroundColor Yellow
                            $stats.Skipped++
                        }
                    }

                    'conflict' {
                        $stats.Conflicts++

                        if ($ConflictResolution -eq 'Manual') {
                            Write-Warning "⚠ Conflict detected for test case '$testCaseId'. Local and remote versions have diverged. Run 'Resolve-TcmTestCaseConflict -Id $testCaseId' to resolve manually, or specify a different ConflictResolution strategy."
                        } else {
                            if ($PSCmdlet.ShouldProcess("Test case '$testCaseId'", "Resolve conflict using $ConflictResolution")) {
                                Write-Host "⚠ Resolving conflict for test case '$testCaseId' using strategy: $ConflictResolution" -ForegroundColor Yellow

                                $resolveParams = @{
                                    Id            = $testCaseId
                                    Strategy      = $ConflictResolution
                                    TestCasesRoot = $config.TestCasesRoot
                                }

                                Resolve-TcmTestCaseConflict @resolveParams
                                $stats.Synced++
                            }
                        }
                    }

                    default {
                        Write-Warning "Unknown sync status '$syncStatus' for test case '$testCaseId'"
                        $stats.Errors++
                    }
                }
            } catch {
                Write-Error "Failed to sync test case '$testCaseId': $($_.Exception.Message)"
                $stats.Errors++
            }
        }
    }

    end {
        # Display summary
        Write-Host "`nSync Summary:" -ForegroundColor Cyan
        Write-Host "  Processed:  $($stats.Processed)" -ForegroundColor White
        Write-Host "  Synced:     $($stats.Synced)" -ForegroundColor Green
        Write-Host "  Conflicts:  $($stats.Conflicts)" -ForegroundColor Yellow
        Write-Host "  Skipped:    $($stats.Skipped)" -ForegroundColor Gray
        Write-Host "  Errors:     $($stats.Errors)" -ForegroundColor Red
    }
}
