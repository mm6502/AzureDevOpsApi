function Resolve-TcmTestCaseConflict {
    <#
        .SYNOPSIS
            Resolves synchronization conflicts for test cases.

        .DESCRIPTION
            Resolves conflicts that occur when both local and remote versions of a test case have changes.
            Provides multiple resolution strategies and supports interactive conflict resolution.

            Conflicts occur when content has changed in both the local YAML file and the Azure DevOps work item
            since the last synchronization. This function helps choose which version to keep or merge changes.

        .PARAMETER InputObject
            The local test case to resolve conflict for. Accepts:
            - Test case ID (string) - e.g., "TC001"
            Accepts pipeline input by value or property name.

        .PARAMETER Strategy
            The conflict resolution strategy to use:
            - Manual: Interactive resolution allowing user to choose (default)
            - LocalWins: Use the local version, overwrite remote changes
            - RemoteWins: Use the remote version, overwrite local changes
            - LatestWins: Use the version with the most recent modification timestamp

        .PARAMETER TestCasesRoot
            Root directory containing test case YAML files.
            If not specified, uses the current directory or searches parent directories for .tcm-config.yaml.

        .EXAMPLE
            PS C:\> Resolve-TcmTestCaseConflict -Id "TC001" -Strategy LocalWins

            Resolves the conflict for TC001 by keeping the local version.

        .EXAMPLE
            PS C:\> Resolve-TcmTestCaseConflict -Id "TC001" -Strategy RemoteWins

            Resolves the conflict for TC001 by using the Azure DevOps version.

        .EXAMPLE
            PS C:\> Resolve-TcmTestCaseConflict -Id "TC001" -Strategy LatestWins

            Resolves the conflict by choosing the version that was modified most recently.

        .EXAMPLE
            PS C:\> "TC001", "TC002" | Resolve-TcmTestCaseConflict -Strategy Manual

            Interactively resolves conflicts for multiple test cases.

        .INPUTS
            System.String
            Accepts test case IDs from the pipeline.

        .OUTPUTS
            None. Displays resolution results to the console.

        .NOTES
            - Manual strategy will prompt for user input to choose resolution approach.
            - LatestWins compares file modification timestamps vs. work item changed dates.
            - Resolution is atomic per test case to prevent inconsistent states.
            - After resolution, the test case will be marked as synced.

        .LINK
            Sync-TcmTestCase

        .LINK
            Resolve-TcmTestCaseSyncStatus
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Id", "TestCaseId", "WorkItemId")]
        $InputObject,

        [Parameter(Mandatory)]
        [ValidateSet('Manual', 'LocalWins', 'RemoteWins', 'LatestWins')]
        [string] $Strategy,

        [string] $TestCasesRoot
    )

    begin {
        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot

        $inputItems = @()
    }

    process {
        $inputItems += $InputObject
    }

    end {
        # PS5 compatible: don't start new line with pipe
        $inputItems | Get-TcmTestCase -TestCasesRoot $config.TestCasesRoot | ForEach-Object {

            $resolved = $_
            $testCaseId = $resolved.Id

            try {
                Write-Verbose "Resolving conflict for test case '$testCaseId' using strategy: $Strategy"

                # Check if there's actually a conflict (already determined by Get-TcmTestCase)
                $syncStatus = $resolved.SyncStatus

                if ($syncStatus -ne 'conflict') {
                    Write-Warning "Test case '$testCaseId' does not have a conflict (status: $syncStatus)"
                    return
                }

                # Get local and remote data from resolved object
                $localData = $resolved.LocalData
                $localPath = $resolved.FilePath
                $remoteData = $resolved.RemoteData
                $remoteWorkItem = $resolved.RemoteWorkItem

                switch ($Strategy) {
                    'LocalWins' {
                        Sync-TcmTestCaseToRemote `
                            -InputObject $resolved `
                            -TestCasesRoot $config.TestCasesRoot `
                            -Force `
                            -Message "Resolving conflict for '$testCaseId': Local version wins" `
                            -MessageColor 'Yellow' `
                            -ShouldProcessOperation "Resolve conflict - keep local changes"

                        Write-Host "[OK] Conflict resolved: Local changes pushed to Azure DevOps" -ForegroundColor Green
                    }

                    'RemoteWins' {
                        Sync-TcmTestCaseFromRemote `
                            -InputObject $resolved `
                            -TestCasesRoot $config.TestCasesRoot `
                            -Force `
                            -Message "Resolving conflict for '$testCaseId': Remote version wins" `
                            -MessageColor 'Yellow' `
                            -ShouldProcessOperation "Resolve conflict - keep remote changes"

                        Write-Host "[OK] Conflict resolved: Remote changes pulled from Azure DevOps" -ForegroundColor Green
                    }

                    'LatestWins' {
                        # Compare timestamps to determine which is newer
                        $localTimestamp = [DateTime]::Parse($localData.history.lastModifiedAt)
                        $remoteTimestamp = [DateTime]::Parse($remoteWorkItem.fields.'System.ChangedDate')

                        if ($localTimestamp -gt $remoteTimestamp) {
                            Sync-TcmTestCaseToRemote `
                                -InputObject $resolved `
                                -TestCasesRoot $config.TestCasesRoot `
                                -Force `
                                -Message "Resolving conflict for '$testCaseId': Local version is newer" `
                                -MessageColor 'Yellow' `
                                -ShouldProcessOperation "Resolve conflict - local is newer"

                            Write-Host "[OK] Conflict resolved: Newer local changes pushed to Azure DevOps" -ForegroundColor Green
                        } else {
                            Sync-TcmTestCaseFromRemote `
                                -InputObject $resolved `
                                -TestCasesRoot $config.TestCasesRoot `
                                -Force `
                                -Message "Resolving conflict for '$testCaseId': Remote version is newer" `
                                -MessageColor 'Yellow' `
                                -ShouldProcessOperation "Resolve conflict - remote is newer"

                            Write-Host "[OK] Conflict resolved: Newer remote changes pulled from Azure DevOps" -ForegroundColor Green
                        }
                    }

                    'Manual' {
                        # Display conflict information for manual resolution
                        Write-Host "`nConflict Details for Test Case '$testCaseId':" -ForegroundColor Cyan
                        Write-Host "="*60 -ForegroundColor Cyan

                        Write-Host "`nLocal Version:" -ForegroundColor Yellow
                        Write-Host "  Title:           $($localData.testCase.title)"
                        Write-Host "  State:           $($localData.testCase.state)"
                        Write-Host "  Steps Count:     $($localData.testCase.steps.Count)"

                        Write-Host "`nRemote Version:" -ForegroundColor Yellow
                        Write-Host "  Title:           $($remoteWorkItem.fields.'System.Title')"
                        Write-Host "  Last Modified:   $($remoteWorkItem.fields.'System.ChangedDate')"
                        Write-Host "  Modified By:     $($remoteWorkItem.fields.'System.ChangedBy'.displayName)"
                        Write-Host "  State:           $($remoteData.state)"
                        Write-Host "  Steps Count:     $($remoteData.steps.Count)"

                        Write-Host "`n" -ForegroundColor Cyan
                        Write-Host "To resolve this conflict, run one of the following commands:" -ForegroundColor White
                        Write-Host "  Resolve-TcmTestCaseConflict -InputObject '$testCaseId' -Strategy LocalWins" -ForegroundColor Gray
                        Write-Host "  Resolve-TcmTestCaseConflict -InputObject '$testCaseId' -Strategy RemoteWins" -ForegroundColor Gray
                        Write-Host "  Resolve-TcmTestCaseConflict -InputObject '$testCaseId' -Strategy LatestWins" -ForegroundColor Gray

                        Write-Host "`nOr manually edit the local file and sync:" -ForegroundColor White
                        Write-Host "  $localPath" -ForegroundColor Gray
                        Write-Host "  Sync-TcmTestCase -InputObject '$testCaseId'" -ForegroundColor Gray
                    }
                }
            } catch {
                Write-Error "Failed to resolve conflict for test case '$testCaseId': $($_.Exception.Message)"
                throw
            }
        }
    }
}

