function Get-TcmStringHash {
    <#
        .SYNOPSIS
            Calculates SHA256 hash for test-case content with normalization.

        .DESCRIPTION
            Accepts either a JSON/string representation (-InputString) or a PowerShell
            object/hashtable (-InputObject). The input is normalized to a canonical
            JSON representation before hashing. Normalization includes:
              - ordering object properties alphabetically
              - sorting arrays of primitives
              - sorting steps by `stepNumber` where present
              - removing common non-deterministic properties (timestamps, ids,
                azure attachment ids, metadata)
              - normalizing attachments to deterministic fields (keeps path/name)

        .PARAMETER InputString
            JSON or plain string to be hashed. If JSON, it will be parsed and normalized.

        .PARAMETER InputObject
            A PowerShell object (hashtable / PSCustomObject) describing the test case.
    #>

    [CmdletBinding(DefaultParameterSetName = 'String')]
    param(
        [Parameter(ParameterSetName = 'String', Mandatory = $true, Position = 0)]
        [string] $InputString,

        [Parameter(ParameterSetName = 'Object', Mandatory = $true, Position = 0)]
        [object] $InputObject
    )

    # Helper: determine whether a value is a scalar (string/number/bool/null)
    function Is-Scalar($v) {
        if ($null -eq $v) { return $true }
        switch -regex ($v.GetType().Name) {
            'String' { return $true }
            'Int32|Int64|Double|Decimal|Boolean|Byte' { return $true }
            default { return $false }
        }
    }

    # Common non-deterministic property names (case-insensitive)
    $IgnoredPropertyRegexes = @(
        '^system\.(created|changed).*',
        '.*created(date)?$',
        '.*changed(date)?$',
        '.*last.*modified.*',
        '.*history.*',
        '^id$',
        '^system\.id$',
        'azureid',
        '^_.*' # internal/temporary fields prefixed with underscore
    )

    # Normalize attachments: keep only deterministic fields (path/name/url). Drop azure ids
    function Normalize-Attachment($att) {
        if ($null -eq $att) { return $null }
        if ($att -is [string]) { return $att.Trim() }
        # treat as hashtable/psobject
        $result = [ordered]@{}
        foreach ($k in ($att.Keys | Sort-Object -CaseSensitive)) {
            $kLower = $k.ToString().ToLower()
            if ($kLower -match 'azureid') { continue }
            if ($kLower -match 'id' -and $kLower -eq 'id') { continue }
            # Keep common deterministic properties
            if ($kLower -in @('path','filename','name','url','uri','relativepath')) {
                $result[$k] = ($att[$k] -as [string])?.Trim()
            }
        }
        return $result
    }

    # Recursively normalize objects/arrays/primitives
    function Normalize-Value($value) {
        if ($null -eq $value) { return $null }

        # Scalars: trim strings
        if ($value -is [string]) { return $value.Trim() }
        # Use TypeCode to detect primitive/value types. If the TypeCode is not Object,
        # treat as scalar and return as-is.
        try {
            $typeCode = [System.Type]::GetTypeCode($value.GetType())
            if ($typeCode -ne [System.TypeCode]::Object) { return $value }
        }
        catch {
            # If GetType or GetTypeCode fails, fall through to other handlers
        }

        # Hashtable or PSCustomObject: handle dictionaries/objects before generic IEnumerable
        if ($value -is [System.Collections.IDictionary] -or $value -is [PSCustomObject]) {
            $dict = @{}
            # Use .psobject.properties when PSCustomObject
            if ($value -is [PSCustomObject]) {
                foreach ($p in $value.PSObject.Properties) { $dict[$p.Name] = $p.Value }
            }
            else {
                foreach ($k in $value.Keys) { $dict[$k] = $value[$k] }
            }

            # Remove ignored keys
            $normalized = [ordered]@{}
            foreach ($k in ($dict.Keys | Where-Object { $_ } | Sort-Object -CaseSensitive)) {
                $shouldIgnore = $false
                foreach ($rx in $IgnoredPropertyRegexes) {
                    if ($k.ToString().ToLower() -match $rx) { $shouldIgnore = $true; break }
                }
                if ($shouldIgnore) { continue }

                $v = $dict[$k]

                # Special handling for well-known fields
                if ($k -ieq 'steps') {
                    # normalize steps array
                    $normalizedSteps = Normalize-Value $v
                    # For each step, ensure ordering of properties
                    $orderedSteps = @()
                    foreach ($s in $normalizedSteps) {
                        $stepObj = [ordered]@{}
                        # Prefer numeric stepNumber as first property if present
                        if ($s -ne $null -and ($s.PSObject.Properties.Name -contains 'stepNumber')) { $stepObj['stepNumber'] = [int]$s.stepNumber }
                        # Normalize attachments inside step
                        if ($s -ne $null -and ($s.PSObject.Properties.Name -contains 'attachments')) {
                            $atts = @()
                            foreach ($a in $s.attachments) { $atts += (Normalize-Attachment $a) }
                            $stepObj['attachments'] = $atts
                        }
                        # other properties: action, expectedResult, etc. Add sorted
                        $otherProps = ($s.PSObject.Properties.Name | Where-Object { $_ -ne 'stepNumber' -and $_ -ne 'attachments' } | Sort-Object -CaseSensitive)
                        foreach ($op in $otherProps) { $stepObj[$op] = Normalize-Value $s.$op }
                        $orderedSteps += $stepObj
                    }
                    $normalized[$k] = $orderedSteps
                    continue
                }

                if ($k -ieq 'tags' -or $k -ieq 'Tags') {
                    $normalized[$k] = (Normalize-Value $v)
                    continue
                }

                if ($k -ieq 'customFields' -or $k -ieq 'customfields') {
                    # normalize nested custom fields as ordered object
                    $cf = Normalize-Value $v
                    if ($cf -is [System.Collections.IDictionary]) {
                        $cfOrdered = [ordered]@{}
                        foreach ($ck in ($cf.Keys | Sort-Object -CaseSensitive)) { $cfOrdered[$ck] = Normalize-Value $cf[$ck] }
                        $normalized[$k] = $cfOrdered
                    }
                    else { $normalized[$k] = $cf }
                    continue
                }

                # attachments at top-level or other objects
                if ($k.ToString().ToLower() -match 'attachment') {
                    if ($v -is [System.Collections.IEnumerable] -and -not ($v -is [string])) {
                        $resAtt = @()
                        foreach ($a in $v) { $resAtt += (Normalize-Attachment $a) }
                        $normalized[$k] = $resAtt
                        continue
                    }
                }

                # Default: recursively normalize the value
                $normalized[$k] = Normalize-Value $v
            }

            return $normalized
        }

        # Arrays / generic IEnumerable (exclude IDictionary which was handled above)
        if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string]) -and -not ($value -is [System.Collections.IDictionary])) {
            $list = @()
            foreach ($item in $value) { $list += (Normalize-Value $item) }

            # If list of scalars, sort for deterministic order
            $allScalar = $true
            foreach ($i in $list) { if (-not (Is-Scalar $i)) { $allScalar = $false; break } }
            if ($allScalar) { return ($list | Sort-Object -Unique) }

            # If items are objects and have stepNumber, sort by it
            $hasStepNumber = $false
            foreach ($i in $list) { if ($i -ne $null -and ($i.PSObject.Properties.Name -contains 'stepNumber')) { $hasStepNumber = $true; break } }
            if ($hasStepNumber) {
                return ($list | Sort-Object {[int]($_.stepNumber)})
            }

            # Otherwise sort by JSON representation to get deterministic order
            $withJson = $list | ForEach-Object { @{ obj = $_; json = (ConvertTo-Json -InputObject $_ -Depth 50 -Compress) } }
            return ($withJson | Sort-Object -Property json | ForEach-Object { $_.obj })
        }

        # Hashtable or PSCustomObject
        if ($value -is [System.Collections.IDictionary] -or $value -is [PSCustomObject]) {
            $dict = @{}
            # Use .psobject.properties when PSCustomObject
            if ($value -is [PSCustomObject]) {
                foreach ($p in $value.PSObject.Properties) { $dict[$p.Name] = $p.Value }
            }
            else {
                foreach ($k in $value.Keys) { $dict[$k] = $value[$k] }
            }

            # Remove ignored keys
            $normalized = [ordered]@{}
            foreach ($k in ($dict.Keys | Where-Object { $_ } | Sort-Object -CaseSensitive)) {
                $shouldIgnore = $false
                foreach ($rx in $IgnoredPropertyRegexes) {
                    if ($k.ToString().ToLower() -match $rx) { $shouldIgnore = $true; break }
                }
                if ($shouldIgnore) { continue }

                $v = $dict[$k]

                # Special handling for well-known fields
                if ($k -ieq 'steps') {
                    # normalize steps array
                    $normalizedSteps = Normalize-Value $v
                    # For each step, ensure ordering of properties
                    $orderedSteps = @()
                    foreach ($s in $normalizedSteps) {
                        $stepObj = [ordered]@{}
                        # Prefer numeric stepNumber as first property if present
                        if ($s -ne $null -and ($s.PSObject.Properties.Name -contains 'stepNumber')) { $stepObj['stepNumber'] = [int]$s.stepNumber }
                        # Normalize attachments inside step
                        if ($s -ne $null -and ($s.PSObject.Properties.Name -contains 'attachments')) {
                            $atts = @()
                            foreach ($a in $s.attachments) { $atts += (Normalize-Attachment $a) }
                            $stepObj['attachments'] = $atts
                        }
                        # other properties: action, expectedResult, etc. Add sorted
                        $otherProps = ($s.PSObject.Properties.Name | Where-Object { $_ -ne 'stepNumber' -and $_ -ne 'attachments' } | Sort-Object -CaseSensitive)
                        foreach ($op in $otherProps) { $stepObj[$op] = Normalize-Value $s.$op }
                        $orderedSteps += $stepObj
                    }
                    $normalized[$k] = $orderedSteps
                    continue
                }

                if ($k -ieq 'tags' -or $k -ieq 'Tags') {
                    $normalized[$k] = (Normalize-Value $v)
                    continue
                }

                if ($k -ieq 'customFields' -or $k -ieq 'customfields') {
                    # normalize nested custom fields as ordered object
                    $cf = Normalize-Value $v
                    if ($cf -is [System.Collections.IDictionary]) {
                        $cfOrdered = [ordered]@{}
                        foreach ($ck in ($cf.Keys | Sort-Object -CaseSensitive)) { $cfOrdered[$ck] = Normalize-Value $cf[$ck] }
                        $normalized[$k] = $cfOrdered
                    }
                    else { $normalized[$k] = $cf }
                    continue
                }

                # attachments at top-level or other objects
                if ($k.ToString().ToLower() -match 'attachment') {
                    if ($v -is [System.Collections.IEnumerable] -and -not ($v -is [string])) {
                        $resAtt = @()
                        foreach ($a in $v) { $resAtt += (Normalize-Attachment $a) }
                        $normalized[$k] = $resAtt
                        continue
                    }
                }

                # Default: recursively normalize the value
                $normalized[$k] = Normalize-Value $v
            }

            return $normalized
        }

        # Fallback: return as-is
        return $value
    }

    # Resolve input into an object to normalize
    $objToNormalize = $null
    if ($PSCmdlet.ParameterSetName -eq 'String') {
        # Try parse JSON; if fails, treat as raw string and hash directly
        try {
            $objToNormalize = ConvertFrom-Json -InputObject $InputString -Depth 100 -ErrorAction Stop
        }
        catch {
            # Not JSON: hash raw string like prior behavior
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
            $hashBytes = $hasher.ComputeHash($bytes)
            $hasher.Dispose()
            return ([System.BitConverter]::ToString($hashBytes) -replace '-', '').ToLower()
        }
    }
    else {
        $objToNormalize = $InputObject
    }

    # Normalize the object
    $normalized = Normalize-Value $objToNormalize

    # Convert normalized object to canonical JSON (sorted keys preserved via ordered hashtables)
    $json = ConvertTo-Json -InputObject $normalized -Depth 100 -Compress

    # Finally compute SHA256
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $hashBytes = $hasher.ComputeHash($bytes)
    $hash = ([System.BitConverter]::ToString($hashBytes) -replace '-', '').ToLower()
    $hasher.Dispose()

    return $hash
}