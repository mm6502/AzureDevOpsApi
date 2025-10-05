function Get-TcmTestCase {
    <#
        .SYNOPSIS
            Retrieves test case data from YAML files.

        .DESCRIPTION
            Retrieves test case information from local YAML files. Can return a single test case by ID or path,
            or return all test cases in the repository. Optionally includes synchronization metadata.

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

        .PARAMETER IncludeMetadata
            Includes synchronization metadata in the output, such as file paths, modification dates,
            and sync status information.

        .EXAMPLE
            PS C:\> Get-TcmTestCase -Id "TC001"

            Retrieves the test case with ID "TC001" and returns its data.

        .EXAMPLE
            PS C:\> Get-TcmTestCase -Path "authentication/TC001-login.yaml"

            Loads the test case from the specified file path.

        .EXAMPLE
            PS C:\> Get-TcmTestCase | Where-Object { $_.testCase.state -eq "Design" }

            Retrieves all test cases and filters for those in "Design" state.

        .EXAMPLE
            PS C:\> Get-TcmTestCase -IncludeMetadata | Select-Object @{Name="ID";Expression={$_.testCase.id}}, @{Name="Title";Expression={$_.testCase.title}}, @{Name="File";Expression={$_.metadata.filePath}}

            Gets all test cases with metadata and displays ID, title, and file path.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Collections.Hashtable[]
            Returns an array of hashtables, each containing:
            - testCase: The test case metadata and content
            - metadata: File information and sync status (if -IncludeMetadata specified)

        .NOTES
            - Searches recursively through the test cases root directory for .yaml files.
            - Test case IDs are extracted from filenames (e.g., "TC001-test-name.yaml" has ID "TC001").
            - Invalid YAML files are skipped with warnings.
            - Use -IncludeMetadata to get file paths and sync information.

        .LINK
            New-TcmTestCase

        .LINK
            Sync-TcmTestCase

        .LINK
            New-TcmConfig
    #>

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(ParameterSetName = 'ById', Position = 0)]
        [string] $Id,

        [Parameter(ParameterSetName = 'ByPath')]
        [string] $Path,

        [string] $TestCasesRoot,

        [switch] $IncludeMetadata
    )

    try {
        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot

        if ($PSCmdlet.ParameterSetName -eq 'ByPath') {
            # Load specific test case by path
            $fullPath = Join-Path $config.TestCasesRoot $Path
            if (-not (Test-Path $fullPath)) {
                throw "Test case file not found: $fullPath"
            }

            $testCase = Get-TcmTestCaseFromFile -FilePath $fullPath -IncludeMetadata:$IncludeMetadata
            return $testCase
        } elseif ($PSCmdlet.ParameterSetName -eq 'ById') {
            # Load specific test case by ID - scan files directly
            $foundFile = $null
            $yamlFiles = Get-ChildItem -Path $config.TestCasesRoot -Include "*.yaml" -Recurse -File

            foreach ($file in $yamlFiles) {
                try {
                    $fileData = Get-TcmTestCaseFromFile -FilePath $file.FullName -IncludeMetadata -ErrorAction SilentlyContinue
                    if ($fileData.testCase.id -eq $Id) {
                        $foundFile = $file.FullName
                        break
                    }
                } catch {
                    # Skip files that can't be parsed
                    continue
                }
            }

            if (-not $foundFile) {
                throw "Test case with ID '$Id' not found in any YAML file"
            }

            $testCase = Get-TcmTestCaseFromFile -FilePath $foundFile -IncludeMetadata:$IncludeMetadata
            return $testCase
        } else {
            # Load all test cases
            $testCases = @()
            $yamlFiles = Get-ChildItem -Path $config.TestCasesRoot -Include "*.yaml" -Recurse -File

            # Get exclude patterns from config
            $excludePatterns = $config.sync.excludePatterns
            if (-not $excludePatterns) {
                $excludePatterns = @()
            }

            # Always exclude the config file itself
            $excludePatterns += ".tcm-config.yaml"

            foreach ($file in $yamlFiles) {
                # Get relative path for pattern matching (normalize to forward slashes)
                $relativePath = $file.FullName.Substring($config.TestCasesRoot.Length + 1).Replace('\', '/')

                # Check if file should be excluded
                # Include both root-level (*.yaml) and nested files (**/*.yaml)
                $shouldInclude = Test-String -InputObject $relativePath -Include @('*.yaml', '**/*.yaml') -Exclude $excludePatterns

                if ($shouldInclude) {
                    try {
                        $testCase = Get-TcmTestCaseFromFile -FilePath $file.FullName -IncludeMetadata:$IncludeMetadata
                        $testCases += $testCase
                    } catch {
                        Write-Warning "Failed to load test case from $($file.FullName): $($_.Exception.Message)"
                    }
                }
            }

            return $testCases
        }
    } catch {
        throw "Failed to get test case(s): $($_.Exception.Message)"
    }
}