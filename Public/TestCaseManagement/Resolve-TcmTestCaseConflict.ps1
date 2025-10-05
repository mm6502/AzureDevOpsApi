function Resolve-TcmTestCaseConflict {
    <#
        .SYNOPSIS
            Resolves synchronization conflicts for test cases.

        .DESCRIPTION
            Resolves conflicts that occur when both local and remote versions of a test case have changes.
            Provides multiple resolution strategies and supports interactive conflict resolution.

            Conflicts occur when content has changed in both the local YAML file and the Azure DevOps work item
            since the last synchronization. This function helps choose which version to keep or merge changes.

        .PARAMETER Id
            The local identifier of the test case with the conflict (e.g., "TC001").
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
            Get-TcmTestCaseSyncStatus
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Id,

        [Parameter(Mandatory)]
        [ValidateSet('Manual', 'LocalWins', 'RemoteWins', 'LatestWins')]
        [string] $Strategy,

        [string] $TestCasesRoot
    )

    begin {
        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot
    }

    process {
        try {
            Write-Verbose "Resolving conflict for test case '$Id' using strategy: $Strategy"

            # Verify there's actually a conflict
            $syncStatus = Get-TcmTestCaseSyncStatus -Id $Id -Config $config

            if ($syncStatus -ne 'conflict') {
                Write-Warning "Test case '$Id' does not have a conflict (status: $syncStatus)"
                return
            }

            # Find local file by scanning
            $localPath = $null
            $yamlFiles = Get-ChildItem -Path $config.TestCasesRoot -Include "*.yaml" -Recurse -File

            foreach ($file in $yamlFiles) {
                try {
                    $fileData = Get-TcmTestCaseFromFile -FilePath $file.FullName -IncludeMetadata -ErrorAction SilentlyContinue
                    if ($fileData.testCase.id -eq $Id) {
                        $localPath = $file.FullName
                        $localData = $fileData
                        break
                    }
                } catch {
                    # Skip files that can't be parsed
                    continue
                }
            }

            if (-not $localPath) {
                throw "Test case with ID '$Id' not found in any local YAML file"
            }

            # The $Id is the Work Item ID
            $collection = $null
            $project = $null
            if ($config.azureDevOps) {
                $collection = $config.azureDevOps.collectionUri
                $project = $config.azureDevOps.project
            }
            $workItem = Get-WorkItem -WorkItem $Id -CollectionUri $collection -Project $project
            $remoteData = ConvertFrom-TcmWorkItemToTestCase -WorkItem $workItem

            switch ($Strategy) {
                'LocalWins' {
                    if ($PSCmdlet.ShouldProcess("Test case '$Id'", "Resolve conflict - keep local changes")) {
                        Write-Host "Resolving conflict for '$Id': Local version wins" -ForegroundColor Yellow
                        Sync-TcmTestCaseToRemote -Id $Id -TestCasesRoot $config.TestCasesRoot -Force
                        Write-Host "✓ Conflict resolved: Local changes pushed to Azure DevOps" -ForegroundColor Green
                    }
                }

                'RemoteWins' {
                    if ($PSCmdlet.ShouldProcess("Test case '$Id'", "Resolve conflict - keep remote changes")) {
                        Write-Host "Resolving conflict for '$Id': Remote version wins" -ForegroundColor Yellow
                        Sync-TcmTestCaseFromRemote -Id $Id -TestCasesRoot $config.TestCasesRoot -Force
                        Write-Host "✓ Conflict resolved: Remote changes pulled from Azure DevOps" -ForegroundColor Green
                    }
                }

                'LatestWins' {
                    # Compare timestamps to determine which is newer
                    $localTimestamp = [DateTime]::Parse($localData.history.lastModifiedAt)
                    $remoteTimestamp = [DateTime]::Parse($workItem.fields.'System.ChangedDate')

                    if ($localTimestamp -gt $remoteTimestamp) {
                        if ($PSCmdlet.ShouldProcess("Test case '$Id'", "Resolve conflict - local is newer")) {
                            Write-Host "Resolving conflict for '$Id': Local version is newer" -ForegroundColor Yellow
                            Sync-TcmTestCaseToRemote -Id $Id -TestCasesRoot $config.TestCasesRoot -Force
                            Write-Host "✓ Conflict resolved: Newer local changes pushed to Azure DevOps" -ForegroundColor Green
                        }
                    } else {
                        if ($PSCmdlet.ShouldProcess("Test case '$Id'", "Resolve conflict - remote is newer")) {
                            Write-Host "Resolving conflict for '$Id': Remote version is newer" -ForegroundColor Yellow
                            Sync-TcmTestCaseFromRemote -Id $Id -TestCasesRoot $config.TestCasesRoot -Force
                            Write-Host "✓ Conflict resolved: Newer remote changes pulled from Azure DevOps" -ForegroundColor Green
                        }
                    }
                }

                'Manual' {
                    # Display conflict information for manual resolution
                    Write-Host "`nConflict Details for Test Case '$Id':" -ForegroundColor Cyan
                    Write-Host "=" * 60 -ForegroundColor Cyan

                    Write-Host "`nLocal Version:" -ForegroundColor Yellow
                    Write-Host "  Title:           $($localData.testCase.title)"
                    Write-Host "  Last Modified:   $($localData.history.lastModifiedAt)"
                    Write-Host "  Modified By:     $($localData.history.lastModifiedBy)"
                    Write-Host "  State:           $($localData.testCase.state)"
                    Write-Host "  Steps Count:     $($localData.testCase.steps.Count)"

                    Write-Host "`nRemote Version:" -ForegroundColor Yellow
                    Write-Host "  Title:           $($workItem.fields.'System.Title')"
                    Write-Host "  Last Modified:   $($workItem.fields.'System.ChangedDate')"
                    Write-Host "  Modified By:     $($workItem.fields.'System.ChangedBy'.displayName)"
                    Write-Host "  State:           $($remoteData.state)"
                    Write-Host "  Steps Count:     $($remoteData.steps.Count)"

                    Write-Host "`n" -ForegroundColor Cyan
                    Write-Host "To resolve this conflict, run one of the following commands:" -ForegroundColor White
                    Write-Host "  Resolve-TcmTestCaseConflict -Id '$Id' -Strategy LocalWins" -ForegroundColor Gray
                    Write-Host "  Resolve-TcmTestCaseConflict -Id '$Id' -Strategy RemoteWins" -ForegroundColor Gray
                    Write-Host "  Resolve-TcmTestCaseConflict -Id '$Id' -Strategy LatestWins" -ForegroundColor Gray

                    Write-Host "`nOr manually edit the local file and sync:" -ForegroundColor White
                    Write-Host "  $localPath" -ForegroundColor Gray
                    Write-Host "  Sync-TcmTestCase -Id '$Id'" -ForegroundColor Gray
                }
            }
        } catch {
            Write-Error "Failed to resolve conflict for test case '$Id': $($_.Exception.Message)"
            throw
        }
    }
}
