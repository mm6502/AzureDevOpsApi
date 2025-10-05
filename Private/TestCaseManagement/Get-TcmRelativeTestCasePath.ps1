function Get-TcmRelativeTestCasePath {
    <#
        .SYNOPSIS
            Gets the relative path of a test case file from the TestCases root.

        .PARAMETER FilePath
            Full path to the test case file.

        .PARAMETER TestCasesRoot
            Root directory for test cases.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath,

        [string] $TestCasesRoot
    )

    if (-not $TestCasesRoot) {
        $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        $TestCasesRoot = Join-Path $moduleRoot "TestCases"
    }

    # Normalize paths
    $FilePath = [System.IO.Path]::GetFullPath($FilePath)
    $TestCasesRoot = [System.IO.Path]::GetFullPath($TestCasesRoot)

    # Get relative path
    $relativePath = [System.IO.Path]::GetRelativePath($TestCasesRoot, $FilePath)

    # Convert backslashes to forward slashes for consistency
    return $relativePath -replace '\\', '/'
}