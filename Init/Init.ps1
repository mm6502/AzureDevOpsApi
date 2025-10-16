# Dot source initialization scripts
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Globals.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '.\PSTypeNames.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Get-Emoji.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Classes\AuthorizationType.ps1')

# Import required external modules
try {
    Import-Module powershell-yaml -ErrorAction Stop
} catch {
    Write-Warning "Failed to import powershell-yaml module. Test Case Management features will not work. Install with: Install-Module -Name powershell-yaml"
}
try {
    Import-Module ImportExcel -ErrorAction Stop
} catch {
    Write-Warning "Failed to import ImportExcel module. Excel related features will not work. Install with: Install-Module -Name ImportExcel -AllowClobber"
}
