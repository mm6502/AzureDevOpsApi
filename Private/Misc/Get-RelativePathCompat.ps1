function Resolve-RelativePath {
    <#
        .SYNOPSIS
            Resolves the relative path from one path to another.

        .DESCRIPTION
            This function resolves relative paths between two locations in a cross-version compatible way.
            It uses [System.IO.Path]::GetRelativePath() on PowerShell 7+ where available,
            and falls back to a System.Uri-based implementation for PowerShell 5.

            Parameter names are compatible with Resolve-Path and [System.IO.Path]::GetRelativePath().

        .PARAMETER RelativeBasePath
            The base path (directory) from which to calculate the relative path.
            This is the "relative to" path - the starting point for the relative path calculation.

        .PARAMETER Path
            The target path (file or directory) for which to calculate the relative path.
            This is the destination path.

        .EXAMPLE
            Resolve-RelativePath -RelativeBasePath 'C:\Projects' -Path 'C:\Projects\Module\file.ps1'
            Returns: Module\file.ps1

        .EXAMPLE
            Resolve-RelativePath -RelativeBasePath 'C:\Projects\Module' -Path 'C:\Projects\Tests\test.ps1'
            Returns: ..\Tests\test.ps1

        .NOTES
            This function works with both existing and non-existing paths.
            The RelativeBasePath parameter should typically be a directory path.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('From', 'RelativeTo')]
        [string] $RelativeBasePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('To', 'Target')]
        [string] $Path
    )

    process {

        # Use .NET Core method if available (PS7+)
        if ([System.IO.Path].GetMethod('GetRelativePath')) {
            return [System.IO.Path]::GetRelativePath($RelativeBasePath, $Path)
        }

        # PS5 fallback: manual implementation using .NET Uri class
        # Normalize paths to absolute paths
        $fromPath = [System.IO.Path]::GetFullPath($RelativeBasePath)
        $toPath = [System.IO.Path]::GetFullPath($Path)

        # Ensure From path ends with directory separator for proper URI construction
        if (-not $fromPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
            $fromPath += [System.IO.Path]::DirectorySeparatorChar
        }

        # Create URIs for path manipulation
        $fromUri = New-Object System.Uri($fromPath)
        $toUri = New-Object System.Uri($toPath)

        # Get relative URI and convert to path string
        $relativeUri = $fromUri.MakeRelativeUri($toUri)
        $relativePath = [System.Uri]::UnescapeDataString($relativeUri.ToString())

        # Convert forward slashes to backslashes on Windows
        if ([System.IO.Path]::DirectorySeparatorChar -eq '\') {
            $relativePath = $relativePath -replace '/', '\'
        }

        return $relativePath
    }
}
