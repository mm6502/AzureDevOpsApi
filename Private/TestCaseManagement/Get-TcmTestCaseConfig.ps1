function Get-TcmTestCaseConfig {
    <#
        .SYNOPSIS
            Loads the test case management configuration from config.yaml file.

        .PARAMETER ConfigPath
            Path to the configuration file. If not specified, looks for config.yaml in the TestCases directory.

        .PARAMETER TestCasesRoot
            Root directory for test cases. If not specified, uses the TestCases directory relative to the module.
    #>

    [CmdletBinding()]
    param(
        $ConfigPath = '.tcm-config.yaml',
        $TestCasesRoot = $PWD.Path
    )

    # Resolve TestCasesRoot to absolute path
    if (-not $TestCasesRoot) {
        $TestCasesRoot = $PWD.Path
    }

    # Determine the config file path
    if (-not [System.IO.Path]::IsPathRooted($ConfigPath)) {
        $ConfigPath = Join-Path -Path $TestCasesRoot -ChildPath ".tcm-config.yaml"
    }

    # Check if config file exists
    if (-not (Test-Path $ConfigPath -PathType Leaf)) {
        throw "Configuration file not found at: $ConfigPath. Please create the configuration file with 'New-TcmConfig' command."
    }

    # Load and parse YAML configuration
    try {
        $configContent = Get-Content -Path $ConfigPath -Raw
        $config = ConvertFrom-Yaml $configContent

        # Add computed properties
        $config | Add-Member -NotePropertyName 'TestCasesRoot' -NotePropertyValue $TestCasesRoot
        $config | Add-Member -NotePropertyName 'ConfigPath' -NotePropertyValue $ConfigPath
        $config | Add-Member -NotePropertyName 'MetadataPath' -NotePropertyValue (Join-Path $TestCasesRoot ".metadata")

        return $config
    }
    catch {
        throw "Failed to parse configuration file: $($_.Exception.Message)"
    }
}