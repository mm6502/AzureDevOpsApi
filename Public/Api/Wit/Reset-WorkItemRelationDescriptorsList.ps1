function Reset-WorkItemRelationDescriptorsList {

    <#
        .SYNOPSIS
            Resets the configuration file to the default work item relationship descriptors.

        .NOTES
            Overwrites the existing configuration file with default values.

        .PARAMETER Default
            If specified, removes the existing configuration file.

            On the next Get-WorkItemRelationDescriptorsList call, the default values
            returned by Get-DefaultWorkItemRelationDescriptorsList will be loaded
            into cache and returned to caller.
    #>

    [CmdletBinding()]
    param(
        [Alias('Permanent', 'Persistent')]
        [switch] $Default
    )

    process {

        # Clear the cache (to force reload on next get)
        Set-WorkItemRelationDescriptorsCache -Value $null

        # If -Default is specified, also remove existing file.
        if ($Default.IsPresent -and ($true -eq $Default)) {

            # Remove existing file if it exists
            $configPath = Join-Path `
                -Path $PSScriptRoot `
                -ChildPath '..\..\..\Config\WorkItemRelationDescriptors.json'

            Remove-Item -Path $configPath -ErrorAction SilentlyContinue
        }
    }
}
