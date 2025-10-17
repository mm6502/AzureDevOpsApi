function Get-TcmHashCache {
    <#
        .SYNOPSIS
            Loads the test case hash cache from disk.

        .DESCRIPTION
            Loads the hash cache file (.tcm-hashes.json) which stores the last-known
            synced hash for each test case ID. This enables detection of
            concurrent changes and proper 3-way merge status determination.

        .PARAMETER TestCasesRoot
            Root directory containing test case YAML files and the hash cache file.

        .OUTPUTS
            Hashtable with structure: @{
                <testCaseId> = @{
                    hash = <syncedHash>
                    lastSync = <timestamp>
                }
            }

        .EXAMPLE
            $cache = Get-TcmHashCache -TestCasesRoot "C:\TestCases"
    #>

    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [string] $TestCasesRoot
    )

    $cacheFilePath = Join-Path -Path $TestCasesRoot -ChildPath '.tcm-hashes.json'

    if (-not (Test-Path -Path $cacheFilePath -PathType Leaf)) {
        Write-Verbose "Hash cache file not found at: $cacheFilePath. Returning empty cache."
        return @{}
    }

    try {
        $cacheJson = Get-Content -Path $cacheFilePath -Raw -ErrorAction Stop

        # Convert from JSON (handling both PS 5.1 and PS 6+)
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $cache = $cacheJson | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        } else {
            # For PS 5.1, convert to hashtable manually
            $cacheObj = $cacheJson | ConvertFrom-Json -ErrorAction Stop
            $cache = @{}
            foreach ($prop in $cacheObj.PSObject.Properties) {
                $cache[$prop.Name] = @{
                    hash = $prop.Value.hash
                    lastSync = $prop.Value.lastSync
                }
            }
        }

        Write-Verbose "Loaded hash cache from: $cacheFilePath ($(($cache.Keys).Count) entries)"
        return $cache
    }
    catch {
        Write-Warning "Failed to load hash cache from '$cacheFilePath': $($_.Exception.Message). Returning empty cache."
        return @{}
    }
}
