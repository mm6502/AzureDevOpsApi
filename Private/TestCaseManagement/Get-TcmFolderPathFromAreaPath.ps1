function Get-TcmFolderPathFromAreaPath {
    <#
        .SYNOPSIS
            Converts an Azure DevOps area path into a folder structure path.

        .PARAMETER AreaPath
            The area path from Azure DevOps (e.g., "Project\Area\Component").

        .PARAMETER MaxDepth
            Maximum number of folder levels to create. 0 = unlimited.

        .PARAMETER IncludeProject
            Whether to include the project name as the top-level folder.

        .EXAMPLE
            Get-TcmFolderPathFromAreaPath -AreaPath "MyProject\Authentication\Login"
            # Returns: "MyProject/Authentication/Login/"

        .EXAMPLE
            Get-TcmFolderPathFromAreaPath -AreaPath "MyProject\Authentication\Login" -MaxDepth 2
            # Returns: "MyProject/Authentication/"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $AreaPath,

        [int] $MaxDepth = 0,

        [switch] $IncludeProject
    )

    # Handle empty or null area path
    if ([string]::IsNullOrWhiteSpace($AreaPath)) {
        return ""
    }

    # Split by backslash (Azure DevOps separator)
    $components = $AreaPath -split '\\' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    # If no components, return empty
    if ($components.Count -eq 0) {
        return ""
    }

    # Apply depth limiting
    if ($MaxDepth -gt 0 -and $components.Count -gt $MaxDepth) {
        $components = $components[0..($MaxDepth - 1)]
    }

    # Sanitize each component for filesystem safety
    $sanitizedComponents = foreach ($component in $components) {
        # Remove invalid filename characters and replace with underscores
        $component -replace '[<>:"/\\|?*]', '_' -replace '\s+', '_'
    }

    # Join with forward slashes and ensure trailing slash
    $folderPath = ($sanitizedComponents -join '/') + '/'

    return $folderPath
}