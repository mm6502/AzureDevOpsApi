function Get-WorkItemRelationDescriptorsList {

    <#
        .SYNOPSIS
            Returns a list of all known work item relationship descriptors.
            Used to manipulate work items relationships.

        .NOTES
            Reads from configuration file if it exists, otherwise falls back to default descriptors.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor')]
    [CmdletBinding()]
    param()

    # Return cached descriptors if already loaded
    $cache = Get-WorkItemRelationDescriptorsCache
    if ($null -ne $cache) {
        return $cache
    }

    # Initialize the cache
    $cache = @()

    # Define the path to the configuration file
    $configPath = Join-Path `
        -Path $PSScriptRoot `
        -ChildPath '..\..\..\Config\WorkItemRelationDescriptors.json'

    # Check if the configuration file exists
    if (Test-Path -Path $configPath -PathType Leaf) {
        # Read and parse the JSON configuration file
        $cache = @(
            Get-Content -Path $configPath `
            | ConvertFrom-Json `
            | ForEach-Object {
                New-WorkItemRelationDescriptor `
                    -Relation     $_.Relation `
                    -FollowFrom   $_.FollowFrom `
                    -NameOnSource $_.NameOnSource `
                    -NameOnTarget $_.NameOnTarget
            }
        )
    } else {
        # Fallback to default descriptors if the config file does not exist
        $cache = @(
            Get-DefaultWorkItemRelationDescriptorsList
        )
    }

    # Cache the loaded descriptors
    Set-WorkItemRelationDescriptorsCache -Value $cache

    # Return the cached descriptors
    Get-WorkItemRelationDescriptorsCache
}
