function Update-TcmHashCacheEntry {
    <#
        .SYNOPSIS
            Updates a single test case entry in the hash cache.

        .DESCRIPTION
            Updates the hash cache entry for a specific test case ID with new
            local and/or remote hash values. Also updates the lastSync timestamp.

        .PARAMETER TestCasesRoot
            Root directory containing test case YAML files and the hash cache file.

        .PARAMETER TestCaseId
            The test case ID to update in the cache.

        .PARAMETER LocalHash
            The current local hash value. If not specified, uses the value from cache.

        .PARAMETER RemoteHash
            The current remote hash value. If not specified, uses the value from cache.

        .EXAMPLE
            Update-TcmHashCacheEntry -TestCasesRoot "C:\TestCases" -TestCaseId "12345" -LocalHash "abc123" -RemoteHash "abc123"

        .EXAMPLE
            Update-TcmHashCacheEntry -TestCasesRoot "C:\TestCases" -TestCaseId "TC001" -LocalHash "def456"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $TestCasesRoot,

        [Parameter(Mandatory)]
        [string] $TestCaseId,

        [string] $LocalHash,

        [string] $RemoteHash
    )

    # Load current cache
    $cache = Get-TcmHashCache -TestCasesRoot $TestCasesRoot

    # Get existing entry or create new one
    if (-not $cache.ContainsKey($TestCaseId)) {
        $cache[$TestCaseId] = @{
            local    = $null
            remote   = $null
            lastSync = $null
        }
    }

    # Update hashes if provided
    if ($PSBoundParameters.ContainsKey('LocalHash')) {
        $cache[$TestCaseId].local = $LocalHash
    }

    if ($PSBoundParameters.ContainsKey('RemoteHash')) {
        $cache[$TestCaseId].remote = $RemoteHash
    }

    # Update timestamp
    $cache[$TestCaseId].lastSync = (Get-Date).ToUniversalTime().ToString('o')

    # Save updated cache
    Set-TcmHashCache -TestCasesRoot $TestCasesRoot -Cache $cache

    Write-Verbose "Updated hash cache entry for test case '$TestCaseId'"
}
