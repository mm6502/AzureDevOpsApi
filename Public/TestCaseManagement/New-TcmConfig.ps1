function New-TcmConfig {
    <#
        .SYNOPSIS
            Creates a new TestCaseManagement configuration file (.tcm-config.yaml).

        .DESCRIPTION
            Creates a configuration file that defines settings for TestCaseManagement operations.
            The configuration includes Azure DevOps connection details, sync preferences, and default values.
            This file is required for all TestCaseManagement operations.

            The configuration file is created as .tcm-config.yaml in the specified directory
            and contains settings for Azure DevOps connection, sync behavior, and test case defaults.

        .PARAMETER CollectionUri
            The Azure DevOps organization/collection URI (e.g., "https://dev.azure.com/my-org" or "my-org").
            This is the base URL for your Azure DevOps organization.

        .PARAMETER Project
            The name of the Azure DevOps project where test cases will be synchronized.

        .PARAMETER Token
            Azure DevOps Personal Access Token for authentication.
            If not provided, the configuration will use an environment variable placeholder.
            The token should have appropriate permissions for work item read/write operations.

        .PARAMETER OutputPath
            The directory path where the .tcm-config.yaml file will be created.
            If a full file path is provided, the directory containing the file will be used.
            Defaults to the current working directory.

        .PARAMETER Force
            Overwrites an existing configuration file without prompting for confirmation.

        .EXAMPLE
            PS C:\> New-TcmConfig -CollectionUri "https://dev.azure.com/my-org" -Project "MyProject"

            Creates a basic configuration file with environment variable placeholder for the PAT.

        .EXAMPLE
            PS C:\> New-TcmConfig -CollectionUri "my-org" -Project "MyProject" -Token "your-pat-here" -OutputPath "C:\TestCases" -Force

            Creates a configuration file with explicit PAT in the specified directory, overwriting any existing file.

        .EXAMPLE
            PS C:\> New-TcmConfig -CollectionUri "https://dev.azure.com/my-org" -Project "MyProject" -OutputPath ".\TestCases\.tcm-config.yaml"

            Creates the configuration file with a specific filename in the TestCases directory.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.String
            Returns the path to the created configuration file.

        .NOTES
            - The configuration file is required for all TestCaseManagement operations.
            - Use environment variables for sensitive information like PATs in production.
            - The file will be searched for starting from the current directory and moving up parent directories.
            - Default sync settings can be modified by editing the generated YAML file.

        .LINK
            Get-TcmTestCaseConfig

        .LINK
            New-TcmTestCase

        .LINK
            Sync-TcmTestCase
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$CollectionUri,

        [Parameter()]
        [string]$Project,

        [Parameter()]
        [string]$Token,

        [Parameter()]
        [string]$OutputPath = $PWD.Path,

        [Parameter()]
        [switch]$Force
    )

    begin {

        # Determine config file path
        # Default to .tcm-config.yaml in the specified output path
        if ([System.IO.Path]::GetExtension($OutputPath) -eq '.yaml') {
            $configFilePath = $OutputPath
        } else {
            $configFilePath = Join-Path -Path $OutputPath -ChildPath ".tcm-config.yaml"
        }

        # Check if config file already exists
        if ((Test-Path -Path $configFilePath -PathType Leaf) -and -not $Force) {
            throw "Config file already exists at '$configFilePath'. Use -Force to overwrite."
        }
    }

    process {

        # Validate collection URI
        $CollectionUri = Use-CollectionUri -CollectionUri $CollectionUri
        if (-not $CollectionUri) {
            throw "Invalid CollectionUri format. Please provide a valid Azure DevOps organization name or URL (e.g., 'my-org' or 'https://dev.azure.com/my-org')."
        }

        # Validate project name
        $Project = Use-Project -Project $Project
        if (-not $Project) {
            throw "Invalid Project name. Please provide a valid Azure DevOps project name."
        }

        # Validate token if provided
        if ($PSBoundParameters.ContainsKey('Token') -and [string]::IsNullOrWhiteSpace($Token)) {
            throw "Token parameter cannot be empty. Either provide a valid Personal Access Token or omit the parameter to use the environment variable placeholder."
        }

        $params = @{
            CollectionUri = $CollectionUri
            Project       = $Project
        }

        if($PSBoundParameters.ContainsKey('Token')) {
            $params.ApiCredential = New-ApiCredential -Token $Token -Authorization 'PAT'
        }

        # Test connection to Azure DevOps
        $connection = Get-ApiProjectConnection @params
        if (-not $connection) {
            throw "Failed to connect to Azure DevOps collection '$CollectionUri' and project '$Project'. Please verify that the collection and project exist, and that you have the necessary permissions. You may also need to set the AZURE_DEVOPS_PAT environment variable if authentication is required."
        }

        # Prepare PAT value
        $patValue = if ($Token) {
            $Token
        } else {
            '${AZURE_DEVOPS_PAT}'
        }

        # Create config content
        $configContent = @"
azureDevOps:
  organization: "$CollectionUri"
  project: "$Project"
  pat: "$patValue"

sync:
  direction: "bidirectional"
  conflictResolution: "manual"
  autoSync: false
  excludePatterns:
    - "**/*-draft.yaml"
    - ".metadata/**"
"@

        # Write config file
        try {
            $configContent | Out-File -FilePath $configFilePath -Encoding UTF8 -Force:$Force
            Write-Host "TestCaseManagement config file created at: $configFilePath" -ForegroundColor Green
        } catch {
            throw "Failed to create config file at '$configFilePath'. Please check that the directory exists and you have write permissions. Error: $($_.Exception.Message)"
        }
    }
}