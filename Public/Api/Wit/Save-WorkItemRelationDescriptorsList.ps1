function Save-WorkItemRelationDescriptorsList {

    <#
        .SYNOPSIS
            Saves the list of work item relationship descriptors to the configuration file.

        .PARAMETER Descriptors
            The list of descriptors to save.
            If not provided, saves the current cached descriptors as defaults.
            If $null is provided, deletes the configuration file if it exists.

        .NOTES
            Overwrites the existing configuration file.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor')]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Array] $Descriptors
    )

    # If the Descriptors parameter is not provided,
    # assume user wants to save the current cached descriptors as defaults
    if (-not $PSBoundParameters.ContainsKey('Descriptors')) {
        $Descriptors = Get-WorkItemRelationDescriptorsCache
    }

    # Define the path to the configuration file
    $configPath = Join-Path `
        -Path $PSScriptRoot `
        -ChildPath '..\..\..\Config\WorkItemRelationDescriptors.json'

    # If no descriptors are provided, just delete the file if it exists
    if ($null -eq $Descriptors) {
        if (Test-Path -Path $configPath -PathType Leaf) {
            Remove-Item -Path $configPath -Force
        }
        return
    }

    # Convert the descriptors to JSON and save to the configuration file
    $jsonContent = ConvertTo-JsonCustom -Depth 5 -Value $Descriptors

    # Ensure the directory exists
    $configPathDir = Split-Path -Path $configPath
    if (-not (Test-Path -Path $configPathDir)) {
        $null = New-Item -Path $configPathDir -ItemType Directory -Force
    }

    # Save the JSON content to the file
    Set-Content -Path $configPath -Value $jsonContent
}
