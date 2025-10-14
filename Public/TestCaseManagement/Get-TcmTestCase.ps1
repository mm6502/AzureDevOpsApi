function Get-TcmTestCase {
    <#
        .SYNOPSIS
            Retrieves test case data from YAML files.

        .DESCRIPTION
            Retrieves test case information from local YAML files. Can return a single test case by ID or path,
            or return all test cases in the repository.

            The function searches for YAML files in the test cases root directory and parses them
            into structured PowerShell objects for further processing or display.

        .PARAMETER Id
            The local identifier of a specific test case to retrieve (e.g., "TC001").
            When specified, returns only the matching test case.

        .PARAMETER Path
            The relative or absolute path to a specific test case YAML file.
            When specified, loads and returns data from that specific file.

        .PARAMETER TestCasesRoot
            The root directory containing test case YAML files.
            If not specified, uses the current directory or searches parent directories for .tcm-config.yaml.

        .EXAMPLE
            PS C:\> Get-TcmTestCase -Id "TC001"

            Retrieves the test case with ID "TC001" and returns its data.

        .EXAMPLE
            PS C:\> Get-TcmTestCase -Path "authentication/TC001-login.yaml"

            Loads the test case from the specified file path.

        .EXAMPLE
            PS C:\> Get-TcmTestCase | Where-Object { $_.LocalData.state -eq "Design" }

            Retrieves all test cases and filters for those in "Design" state.

        .PARAMETER InputObject
            Test case input from pipeline. Accepts:
            - Test case ID (string) - e.g., "TC001"
            - File path (string) - relative or absolute path to YAML file
            - Test case object (hashtable) - from previous operations
            Accepts pipeline input by value or property name.

        .EXAMPLE
            PS C:\> "TC001", "TC002" | Get-TcmTestCase

            Retrieves multiple test cases by ID from pipeline.

        .INPUTS
            System.String
            System.Collections.Hashtable
            Accepts test case IDs, file paths, or test case objects from the pipeline.

        .OUTPUTS
            PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended
            Returns objects that extend TcmTestCaseInput with test case data in the LocalData property.
            LocalData contains the parsed test case properties (id, title, state, etc.).

        .NOTES
            - Searches recursively through the test cases root directory for .yaml files.
            - Test case IDs are extracted from filenames (e.g., "TC001-test-name.yaml" has ID "TC001").
            - Invalid YAML files are skipped with warnings.

        .LINK
            New-TcmTestCase

        .LINK
            Sync-TcmTestCase

        .LINK
            New-TcmConfig
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended')]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id', 'Path')]
        $InputObject,

        [string] $TestCasesRoot = (Get-Location -PSProvider FileSystem).Path
    )

    begin {
        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot
        $inputItems = @()
        $seenEmptyInput = $false
    }

    process {
        # Collect all input items (or null for 'all' mode)
        if ($null -eq $InputObject) {
            $seenEmptyInput = $true
        } else {
            $inputItems += $InputObject
        }
    }

    end {
        $results = @()

        # If no specific input was provided, add null to indicate 'all' mode
        if ($seenEmptyInput) {
            $inputItems = $null
        }

        # Use ConvertTo-TcmTestCaseInput to normalize all inputs
        $resolvedInputs = $inputItems `
        | ConvertTo-TcmTestCaseInput -TestCasesRoot $config.TestCasesRoot

        foreach ($resolved in $resolvedInputs) {
            try {
                $localData = $null
                $remoteData = $null
                $remoteDataHash = $null

                # If LocalData is already populated (from pipeline objects), use it
                if ($null -ne $resolved.LocalData) {
                    $localData = $resolved.LocalData
                }

                # If we have a FilePath, check exclude patterns and load local data
                if ($null -ne $resolved.FilePath) {
                    Write-Debug "Loading local data from file $($resolved.FilePath)..."
                    $localData = Get-TcmTestCaseFromFile -FilePath $resolved.FilePath
                    $resolved.Id = $localData.testCase.id
                }

                # If we have a numeric ID, load from remote
                if (($null -ne $resolved.Id) -and ($resolved.Id -match '^\d+$')) {
                    Write-Debug "Loading remote data for Work Item ID $($resolved.Id)..."

                    # Get Azure DevOps configuration
                    $collectionUri = $config.azureDevOps.collectionUri
                    $project = $config.azureDevOps.project

                    if (-not $collectionUri -or -not $project) {
                        throw "Azure DevOps collectionUri and project must be configured in config.yaml"
                    }

                    $workItemId = [int]$resolved.Id
                    Write-Verbose "Loading work item $workItemId from Azure DevOps..."

                    $workItem = Get-WorkItem -WorkItem $workItemId -CollectionUri $collectionUri -Project $project

                    if ($null -eq $workItem) {
                        throw "Work item $workItemId not found in Azure DevOps"
                    }
                    if ($workItem.fields.'System.WorkItemType' -ne 'Test Case') {
                        throw "Work item $workItemId is not a Test Case (type: $($workItem.fields.'System.WorkItemType'))"
                    }

                    # Convert work item to test case format
                    $remoteData = ConvertFrom-TcmWorkItemToTestCase -WorkItem $workItem

                    # Calculate hash for remote data
                    $remoteDataHash = Get-TcmStringHash -InputObject $remoteData
                }

                # If we have a non-numeric ID without a local file, throw error
                elseif ($null -ne $resolved.Id) {
                    throw "Invalid test case ID '$($resolved.Id)': Not a numeric Work Item ID and no local file found"
                }

                # Create unified output object that extends TcmTestCaseInput
                if ($localData -or $remoteData) {
                    $resultObject = [PSCustomObject] @{
                        # Inherit from TcmTestCaseInput
                        FilePath   = $resolved.FilePath
                        Id         = $resolved.Id
                        SyncStatus = $null

                        # Additional metadata properties
                        FileName       = if ($localData) { $localData.FileName } else { $null }
                        LocalData      = if ($localData.testCase) { $localData.testCase } else { $null }
                        LocalDataHash  = if ($localData) { $localData.LocalDataHash } else { $null }
                        RemoteDataHash = if ($remoteData) { $remoteDataHash } else { $null }
                        RemoteData     = if ($remoteData) { $remoteData } else { $null }
                        RemoteWorkItem = if ($workItem) { $workItem } else { $null }
                    }

                    # Set proper PSTypeNames for inheritance
                    $resultObject.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended)
                    $resultObject.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseInput)

                    # Ensure Id is set from LocalData if not already available
                    if (-not $resultObject.Id -and $localData.testCase.id) {
                        $resultObject.Id = $localData.testCase.id
                    }

                    # Determine sync status
                    $resultObject = Resolve-TcmTestCaseSyncStatus -InputObject $resultObject -Config $config

                    $results += $resultObject
                }
            } catch {
                Write-Error "Failed to load test case: $($_.Exception.Message)"
            }
        }

        return $results
    }
}
