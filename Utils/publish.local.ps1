#requires -version 5

<#
    .SYNOPSIS
        Publishes the module to .\Merged folder.
#>

[CmdletBinding()]
param(
    [switch] $Force
)

$ModuleName = 'AzureDevOpsApi'

# Name of our local repository
$repositoryName = 'AzureDevOpsApi.local.repo'

# Unregister our private repository
Unregister-PSRepository -Name $repositoryName -ErrorAction 'SilentlyContinue'

# Register our private repository
$targetPath = Join-Path -Path $PSScriptRoot -ChildPath '..\merged\'
if (-not (Test-Path -Path $targetPath -PathType Container)) {
    New-Item -Path $targetPath -ItemType 'Directory'
}
Register-PSRepository `
    -Name $repositoryName `
    -PublishLocation $targetPath `
    -SourceLocation $targetPath `
    -InstallationPolicy 'Trusted'

# If force is used, delete existing packages
if ($Force.IsPresent -and $Force -eq $true) {
    Get-ChildItem $targetPath -Filter *.nupkg `
    | Remove-Item
}

# Publish the module
$pathToPublish = Join-Path -Path $PSScriptRoot -ChildPath '..' -Resolve

## Copy the module to the temp location

### Create a temp folder, so copying works as intended.
### If the target folder does not exist, copy would copy the content of first copied
### folder directly to target folder. Subsequent folders would be copied as subfolders...
$tempPath = Join-Path `
    -Path ([System.IO.Path]::GetTempPath()) `
    -ChildPath ([Guid]::NewGuid()) `
    -AdditionalChildPath $ModuleName

$tempPath = New-Item -Path $tempPath -ItemType 'Directory'

### Copy this content
@(
    'Init'
    'Private'
    'Public'
    'Tests'
    'Utils'
    "$($ModuleName).*"
) `
| ForEach-Object {
    Join-Path -Path $pathToPublish -ChildPath $_ -Resolve
} `
| Copy-Item -Recurse -Destination $tempPath

## Publish the module
Publish-Module -Repository $repositoryName -Path $tempPath

## Remove the temp folder
Remove-Item -Path $tempPath -Recurse -Force -ErrorAction 'SilentlyContinue'

# Remove module from current session
if (Get-Module -Name $ModuleName) {
    Remove-Module -Name $ModuleName -Force
}

# Reinstall the module if it is already installed
if (Get-Module -Name $ModuleName -ListAvailable) {
    # Uninstall current version of module
    Uninstall-Module -Name $ModuleName -Force -AllVersions

    # Install module from our private repository
    Install-Module -Name $ModuleName -Repository $repositoryName -Scope 'CurrentUser' -Force
}

# Remove the local repository
Unregister-PSRepository -Name $repositoryName
