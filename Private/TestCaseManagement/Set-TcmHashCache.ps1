function Set-TcmHashCache {
    <#
        .SYNOPSIS
            Saves the test case hash cache to disk.

        .DESCRIPTION
            Saves the hash cache hashtable to the .tcm-hashes.json file.
            The cache stores last-known local and remote hashes for each test case ID.

        .PARAMETER TestCasesRoot
            Root directory containing test case YAML files and the hash cache file.

        .PARAMETER Cache
            The cache hashtable to save. Structure: @{
                <testCaseId> = @{
                    local = <localHash>
                    remote = <remoteHash>
                    lastSync = <timestamp>
                }
            }

        .EXAMPLE
            Set-TcmHashCache -TestCasesRoot "C:\TestCases" -Cache $cache
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $TestCasesRoot,

        [Parameter(Mandatory)]
        [hashtable] $Cache
    )

    $cacheFilePath = Join-Path -Path $TestCasesRoot -ChildPath '.tcm-hashes.json'

    try {
        # Ensure directory exists
        $cacheDir = Split-Path -Path $cacheFilePath -Parent
        if (-not (Test-Path -Path $cacheDir -PathType Container)) {
            New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
        }

        # Convert to JSON and save
        $cacheJson = $Cache | ConvertTo-Json -Depth 10
        $cacheJson | Set-Content -Path $cacheFilePath -Encoding UTF8 -Force

        Write-Verbose "Saved hash cache to: $cacheFilePath ($(($Cache.Keys).Count) entries)"
    }
    catch {
        Write-Error "Failed to save hash cache to '$cacheFilePath': $($_.Exception.Message)"
        throw
    }
}
