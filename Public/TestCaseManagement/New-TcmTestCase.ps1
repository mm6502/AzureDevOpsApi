function New-TcmTestCase {
    <#
        .SYNOPSIS
            Creates a new test case YAML file with the specified properties.

        .DESCRIPTION
            Creates a new test case in YAML format that can be synchronized with Azure DevOps.
            The test case is saved to a file in a folder structure based on the area path.
            If no configuration exists, you must first create a .tcm-config.yaml file.

            The function validates input parameters, creates the necessary directory structure,
            and generates a properly formatted YAML file containing all test case metadata.

        .PARAMETER Id
            The unique identifier for the test case (e.g., "TC001").
            This will be used as the filename and must contain only letters, numbers, underscores, and hyphens.
            This parameter is mandatory.

        .PARAMETER Title
            The title of the test case. This parameter is mandatory.

        .PARAMETER Description
            A description of what the test case validates. Defaults to empty string if not specified.

        .PARAMETER AreaPath
            The area path for the test case in Azure DevOps (e.g., "Project\Area\Component").
            If not specified, uses the default from the configuration file.

        .PARAMETER IterationPath
            The iteration path for the test case in Azure DevOps.
            If not specified, uses the default from the configuration file.

        .PARAMETER Priority
            The priority of the test case (1-4, where 1 is highest priority).
            If not specified, uses the default from the configuration file.
            Valid values are 1, 2, 3, or 4.

        .PARAMETER Tags
            An array of tags to associate with the test case.
            Tags help categorize and filter test cases in Azure DevOps.

        .PARAMETER Steps
            An array of test steps. Each step should be a hashtable with 'action' and 'expectedResult' properties.
            Additional properties like 'attachments' are supported but not required.
            If not specified, a default empty step will be created.

        .PARAMETER OutputPath
            The relative path where the test case file should be created.
            If not specified, the file is created in a folder structure based on the area path.
            Should include the filename with .yaml extension.

        .PARAMETER TestCasesRoot
            The root directory for test cases.
            If not specified, uses the current directory or the directory containing the .tcm-config.yaml file.

        .PARAMETER Force
            Overwrites the test case file if it already exists without prompting.

        .EXAMPLE
            PS C:\> New-TcmTestCase -Id "TC001" -Title "Login Test" -Description "Test user login functionality"

            Creates a basic test case with default values for area path, iteration path, and priority.

        .EXAMPLE
            PS C:\> $steps = @(
                @{ action = "Navigate to login page"; expectedResult = "Login form displayed" },
                @{ action = "Enter valid credentials"; expectedResult = "User logged in successfully" },
                @{ action = "Click logout button"; expectedResult = "User logged out" }
            )
            PS C:\> New-TcmTestCase -Id "TC002" -Title "Login Flow" -Steps $steps -AreaPath "MyProject\Authentication"

            Creates a test case with multiple test steps and a specific area path.

        .EXAMPLE
            PS C:\> New-TcmTestCase -Id "TC003" -Title "API Test" -OutputPath "api/TC003-api-test.yaml" -TestCasesRoot "C:\MyTestCases" -Force

            Creates a test case in a specific file path within a custom test cases root directory,
            overwriting any existing file.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Collections.Hashtable
            Returns a hashtable containing the created test case data with the following structure:
            - testCase: The test case metadata
            - metadata: File path and creation information

        .NOTES
            - Requires a .tcm-config.yaml file in the test cases root directory or a parent directory.
            - The test case ID must be unique within the test cases root.
            - Test steps are optional but recommended for comprehensive test cases.
            - The created YAML file can be synchronized with Azure DevOps using Sync-TcmTestCase.
            - Invalid characters in the ID will cause the function to throw an error.

        .LINK
            Sync-TcmTestCase

        .LINK
            New-TcmConfig

        .LINK
            Get-TcmTestCase
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Id,

        [Parameter(Mandatory)]
        [string] $Title,

        [string] $Description = "",

        [string] $AreaPath,

        [string] $IterationPath,

        [int] $Priority,

        [string[]] $Tags = @(),

        [hashtable[]] $Steps = @(),

        [string] $OutputPath,

        [string] $TestCasesRoot,

        [switch] $Force
    )

    try {
        # Get configuration
        $config = Get-TcmTestCaseConfig -TestCasesRoot $TestCasesRoot

        # Validate inputs
        if ([string]::IsNullOrWhiteSpace($Id)) {
            throw "Test case ID is required and cannot be empty."
        }
        if ($Id -notmatch '^[A-Za-z0-9_-]+$') {
            throw "Test case ID '$Id' contains invalid characters. Only letters, numbers, underscores, and hyphens are allowed."
        }

        if ([string]::IsNullOrWhiteSpace($Title)) {
            throw "Test case title is required and cannot be empty."
        }

        if ($Priority -and ($Priority -lt 1 -or $Priority -gt 4)) {
            throw "Priority must be between 1 and 4. Provided value: $Priority"
        }

        if ($Steps -and $Steps.Count -gt 0) {
            foreach ($i in 0..($Steps.Count - 1)) {
                $step = $Steps[$i]
                if (-not $step.action -or [string]::IsNullOrWhiteSpace($step.action)) {
                    throw "Step $($i + 1) is missing the required 'action' property."
                }
                if (-not $step.expectedResult -or [string]::IsNullOrWhiteSpace($step.expectedResult)) {
                    throw "Step $($i + 1) is missing the required 'expectedResult' property."
                }
            }
        }

        # Use defaults from config if not specified
        if (-not $AreaPath) { $AreaPath = $config.testCase.defaultAreaPath }
        if (-not $IterationPath) { $IterationPath = $config.testCase.defaultIterationPath }
        if (-not $Priority) { $Priority = $config.testCase.defaultPriority }

        # Determine output path
        if (-not $OutputPath) {
            $sanitizedTitle = $Title -replace '[^\w\s-]', '' -replace '\s+', '-'
            $fileName = "$Id-$sanitizedTitle.yaml".ToLower()
            # Use just the filename - let Save-TcmTestCaseYaml handle folder structure
            $OutputPath = $fileName
        }

        $fullOutputPath = Join-Path $config.TestCasesRoot $OutputPath

        # Check if test case with same ID already exists
        $existingFiles = Get-ChildItem -Path $config.TestCasesRoot -Filter "*.yaml" -Recurse -File |
            Where-Object {
                try {
                    $fileData = Get-TcmTestCaseFromFile -FilePath $_.FullName
                    $fileData.testCase.id -eq $Id
                } catch {
                    $false
                }
            }

        if ($existingFiles -and -not $Force) {
            throw "A test case with ID '$Id' already exists at: $($existingFiles[0].FullName). To overwrite the existing test case, use the -Force parameter."
        }

        # Ensure output directory exists
        $outputDir = Split-Path -Parent $fullOutputPath
        if (-not (Test-Path $outputDir)) {
            New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
        }

        # Create test case object
        $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $currentUser = [Environment]::UserName + "@" + [Environment]::UserDomainName

        # Process steps
        $processedSteps = @()
        for ($i = 0; $i -lt $Steps.Count; $i++) {
            $step = $Steps[$i]
            $processedSteps += @{
                stepNumber     = $i + 1
                action         = $step.action
                expectedResult = $step.expectedResult
                attachments    = @()
            }
        }

        $testCaseData = [ordered]@{
            testCase = [ordered]@{
                id               = $Id
                title            = $Title
                areaPath         = $AreaPath
                iterationPath    = $IterationPath
                state            = $config.testCase.defaultState
                priority         = $Priority
                assignedTo       = ""
                tags             = $Tags
                description      = $Description
                preconditions    = ""
                steps            = $processedSteps
                automationStatus = "Not Automated"
                customFields     = @{}
            }
            history  = [ordered]@{
                createdAt      = $now
                createdBy      = $currentUser
                lastModifiedAt = $now
                lastModifiedBy = $currentUser
            }
        }

        $actualFilePath = Save-TcmTestCaseYaml -FilePath $fullOutputPath -Data $testCaseData -TestCasesRoot $config.TestCasesRoot

        Write-Host "Test case '$Id' created successfully at: $actualFilePath" -ForegroundColor Green

        # Return the created test case
        return Get-TcmTestCaseFromFile -FilePath $actualFilePath -IncludeMetadata
    } catch {
        throw "Failed to create test case '$Id'. Error: $($_.Exception.Message)"
    }
}
