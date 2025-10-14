function ConvertTo-TcmTestCaseInput {
    <#
        .SYNOPSIS
            Converts various input types to standardized TcmTestCaseInput objects for test case operations.
        .DESCRIPTION
            Accepts test case IDs, file paths, directories, or existing test case objects from the pipeline or parameters.
            Normalizes all input types into standardized TcmTestCaseInput objects with ID-to-file-path caching for efficient lookups.
            Used as the input normalization layer for sync operations and test case retrieval.
        .PARAMETER InputObject
            The input object(s) from the pipeline or parameter. Accepts:
            - Test case ID (string) - e.g., "TC001" or "123"
            - File path (string) - relative or absolute path to YAML file
            - Directory path (string) - recursively finds all YAML files
            - Test case object (PSCustomObject/hashtable) - from Get-TcmTestCase or Get-TcmTestCaseFromFile
            - TcmTestCaseInput object - pass-through
        .OUTPUTS
            [PSCustomObject[]] Array of TcmTestCaseInput objects with PSTypeName 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
        .EXAMPLE
            'TestCases/area/TC001.yaml' | ConvertTo-TcmTestCaseInput

            Converts a file path to a TcmTestCaseInput object.
        .EXAMPLE
            '123' | ConvertTo-TcmTestCaseInput -TestCasesRoot 'C:\TestCases'

            Converts a numeric ID to a TcmTestCaseInput object, checking for local files first.
        .EXAMPLE
            ConvertTo-TcmTestCaseInput -InputObject 'TestCases' -TestCasesRoot 'C:\TestCases'

            Converts a directory path to multiple TcmTestCaseInput objects for all YAML files.
        .EXAMPLE
            Get-TcmTestCase -Id 'TC001' | ConvertTo-TcmTestCaseInput

            Converts an existing test case object back to TcmTestCaseInput format.
    #>
    [OutputType('PSTypeNames.AzureDevOpsApi.TcmTestCaseInput')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $InputObject,

        [string] $TestCasesRoot
    )

    begin {
        $items = @()
        # Cache for ID to file path mappings to avoid rescanning
        $script:idToFilePathCache = $null

        # Helper function to build ID to file path cache
        function Get-IdToFilePathCache {
            param([string] $RootPath)

            if ($null -eq $script:idToFilePathCache) {
                Write-Debug "Building ID to file path cache for root: $RootPath"
                $script:idToFilePathCache = @{}

                # Get all YAML files
                $yamlFiles = Get-ChildItem -Path $RootPath -Filter "*.yaml" -Recurse -File

                foreach ($file in $yamlFiles) {
                    # First try: Extract ID from filename pattern (fast)
                    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                    if ($fileName -match '^([^-]+)-') {
                        $extractedId = $matches[1]
                        if (-not $script:idToFilePathCache.ContainsKey($extractedId)) {
                            $script:idToFilePathCache[$extractedId] = $file.FullName
                            Write-Debug "Cached ID '$extractedId' -> '$($file.FullName)' from filename"
                        }
                    }

                    # Second try: If ID is not numeric, also check file contents for ID
                    if ($extractedId -and $extractedId -notmatch '^\d+$') {
                        try {
                            $content = Get-TcmTestCaseFromFile -FilePath $file.FullName -ErrorAction SilentlyContinue
                            if ($content.testCase.id -and -not $script:idToFilePathCache.ContainsKey($content.testCase.id)) {
                                $script:idToFilePathCache[$content.testCase.id] = $file.FullName
                                Write-Debug "Cached ID '$($content.testCase.id)' -> '$($file.FullName)' from file content"
                            }
                        } catch {
                            # Skip files that can't be parsed
                            continue
                        }
                    }
                }

                Write-Debug "Cache built with $($script:idToFilePathCache.Count) entries"
            }

            return $script:idToFilePathCache
        }
    }

    process {

        # If no input, get all test cases from root
        if ($null -eq $InputObject) {
            $InputObject = Get-Item -Path $TestCasesRoot
        }

        $item = $InputObject

        # If object is already a TcmTestCaseInput, pass through
        if ($item -and $item.PSTypeNames `
                -and $item.PSTypeNames -contains 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput') {
            Write-Debug "Input is already a TcmTestCaseInput object, passing through."
            $items += $item
            return
        }

        # Handle TestCase objects from Get-TcmTestCaseFromFile
        if ($item -and $item.PSTypeNames `
                -and $item.PSTypeNames -contains $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseLocalData) {
            Write-Debug "Input is a TcmTestCaseLocalData object, wrapping in TcmTestCaseInput."
            $wrappedObject = [PSCustomObject] @{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                FilePath   = $item.FilePath
                SyncStatus = $null
                LocalData  = $item
                RemoteData = $null
                Id         = $item.testCase.id
            }
            $items += $wrappedObject
            return
        }

        # Handle hashtable/PSCustomObject from Get-TcmTestCase (has testCase.id property)
        if ($item -is [hashtable] -or $item -is [PSCustomObject]) {
            if ($item.testCase -and $item.testCase.id) {
                Write-Debug "Input is a hashtable/PSCustomObject with testCase.id, wrapping in TcmTestCaseInput."
                $wrappedObject = [PSCustomObject] @{
                    PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                    FilePath   = $item.FilePath
                    SyncStatus = $null
                    LocalData  = $item
                    RemoteData = $null
                    Id         = $item.testCase.id
                }
                $items += $wrappedObject
                return
            }
            # Handle PSCustomObject with Id property (from pipeline input)
            elseif ($item.Id) {
                Write-Debug "Input is a PSCustomObject with Id, wrapping in TcmTestCaseInput."
                $wrappedObject = [PSCustomObject] @{
                    PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                    FilePath   = $null
                    SyncStatus = $null
                    LocalData  = $null
                    RemoteData = $null
                    Id         = $item.Id
                }
                $items += $wrappedObject
                return
            }
        }

        # Handle string input (file path or ID)
        $resolvedPath = $item
        if ($TestCasesRoot -and -not [System.IO.Path]::IsPathRooted($item)) {
            # If relative path and TestCasesRoot provided, resolve against root
            $resolvedPath = Join-Path -Path $TestCasesRoot -ChildPath $item
        }

        # Check if path looks like a file path but doesn't exist - treat as invalid
        if ($resolvedPath -match '\.yaml$|\.yml$' -and -not (Test-Path $resolvedPath -PathType Leaf)) {
            Write-Error "File path does not exist: $resolvedPath"
            return
        }

        if ((Test-Path $resolvedPath -PathType Leaf)) {
            try {
                Write-Debug "Input is a file path, wrapping in TcmTestCaseInput."
                $wrappedObject = [PSCustomObject] @{
                    PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                    FilePath   = $resolvedPath
                    SyncStatus = $null
                    LocalData  = $null
                    RemoteData = $null
                    Id         = $null
                }
                $items += $wrappedObject
            } catch {
                Write-Error "Failed to read test case file: $resolvedPath. $_"
            }
            return
        }

        if ((Test-Path $resolvedPath -PathType Container)) {
            try {
                Write-Debug "Input is a directory, getting all YAML files within."
                $yamlFiles = Get-ChildItem `
                    -Path $resolvedPath `
                    -Include "*.yaml" `
                    -Exclude $config.ExcludePatterns `
                    -Recurse `
                    -File `
                | Where-Object { [System.IO.Path]::GetFileName($_.FullName) -notmatch '^\.' }  # Exclude dot-files

                foreach ($file in $yamlFiles) {
                    $wrappedObject = [PSCustomObject] @{
                        PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                        FilePath   = $file.FullName
                        SyncStatus = $null
                        LocalData  = $null
                        RemoteData = $null
                        Id         = $null
                    }
                    $items += $wrappedObject
                }
            } catch {
                Write-Warning "Failed to read test cases from directory: $resolvedPath. $_"
            }
            return
        }

        # Treat as ID (any string that doesn't match a file/directory path)
        Write-Debug "Input '$item' treated as test case ID"

        # Check local files first for any ID (including numeric ones)
        Write-Debug "Checking local files for ID '$item'..."
        $cache = Get-IdToFilePathCache -RootPath $TestCasesRoot
        $matchedFilePath = $cache[[string]$item]

        if ($matchedFilePath) {
            Write-Debug "Found local file for ID '$item': $matchedFilePath"
            $wrappedObject = [PSCustomObject] @{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                FilePath   = $matchedFilePath
                SyncStatus = $null
                LocalData  = $null
                RemoteData = $null
                Id         = $item
            }
            $items += $wrappedObject
        } else {
            Write-Debug "No local file found for ID '$item', will use for remote loading"
            $wrappedObject = [PSCustomObject] @{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                FilePath   = $null
                SyncStatus = $null
                LocalData  = $null
                RemoteData = $null
                Id         = $item
            }
            $items += $wrappedObject
        }
    }
    end {
        Write-Debug "Finished processing input, total items: $($items.Count)"
        # Only return objects with FilePath or Id
        # Use Write-Output -NoEnumerate to preserve array for single items (PS5 compatibility)
        $result = @(
            $items `
            | Where-Object { $null -ne $_ } `
            | Where-Object { ($null -ne $_.Id) -or ($null -ne $_.FilePath) }
        )
        Write-Output -NoEnumerate $result
    }
}
