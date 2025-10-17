function Update-TcmHashCacheEntry {
    <#
        .SYNOPSIS
            Updates a single test case entry in the hash cache.

        .DESCRIPTION
            Updates the hash cache entry for a specific test case ID with the synced hash value.
            This should only be called after a successful sync where local and remote are equal.
            Also updates the lastSync timestamp.

        .PARAMETER TestCasesRoot
            Root directory containing test case YAML files and the hash cache file.

        .PARAMETER TestCaseId
            The test case ID to update in the cache.

        .PARAMETER Hash
            The hash value representing the synced state (must be equal for both local and remote).

        .EXAMPLE
            Update-TcmHashCacheEntry -TestCasesRoot "C:\TestCases" -TestCaseId "12345" -Hash "abc123"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $TestCasesRoot,

        [Parameter(Mandatory)]
        [string] $TestCaseId,

        [Parameter(Mandatory)]
        [string] $Hash
    )

    # Load current cache
    $cache = Get-TcmHashCache -TestCasesRoot $TestCasesRoot

    # Update or create entry with new format
    $cache[$TestCaseId] = @{
        hash     = $Hash
        lastSync = (Get-Date).ToUniversalTime().ToString('o')
    }

    # Save updated cache
    Set-TcmHashCache -TestCasesRoot $TestCasesRoot -Cache $cache

    $hashPreview = if ($Hash.Length -gt 8) { "$($Hash.Substring(0, 8))..." } else { $Hash }
    Write-Verbose "Updated hash cache entry for test case '$TestCaseId' (hash: $hashPreview)"
}
