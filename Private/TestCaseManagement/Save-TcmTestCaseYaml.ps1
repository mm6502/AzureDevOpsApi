function Save-TcmTestCaseYaml {
    <#
        .SYNOPSIS
            Save a test case object to YAML ensuring 'steps' is the last property inside testCase
            and each step's keys are rendered in the explicit order: stepNumber, attachments, action, expectedResult.

        .PARAMETER FilePath
            Path to the YAML file to write.

        .PARAMETER Data
            The full test case object (expects at least testCase, optionally history).

        .PARAMETER TestCasesRoot
            Root directory for test cases. Used for relative path calculations when creating folder structure.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath,

        [Parameter(Mandatory)]
        $Data,

        [string] $TestCasesRoot
    )

    try {
        # Handle folder structure creation - always enabled
        if ($Data.testCase -and $Data.testCase.areaPath) {
            $areaPath = $Data.testCase.areaPath

            # Get folder path from area path
            $folderPath = Get-TcmFolderPathFromAreaPath -AreaPath $areaPath

            if (-not [string]::IsNullOrEmpty($folderPath)) {
                # If TestCasesRoot is provided, make FilePath relative to it first
                if ($TestCasesRoot) {
                    $FilePath = [System.IO.Path]::GetRelativePath($TestCasesRoot, $FilePath)
                }

                # Combine folder path with existing file path
                $folderPath = $folderPath.TrimEnd('/')
                $fileName = [System.IO.Path]::GetFileName($FilePath)
                $FilePath = Join-Path $folderPath $fileName

                # If TestCasesRoot was provided, make it absolute again
                if ($TestCasesRoot) {
                    $FilePath = Join-Path $TestCasesRoot $FilePath
                }
            }
        }

        # deep copy
        $copy = $Data | ConvertTo-Json -Depth 20 | ConvertFrom-Json

        # Drop legacy metadata block from the serialized output while still
        # allowing callers to pass it for backward compatibility.
        if ($copy.PSObject.Properties.Name -contains 'metadata') {
            $copy.PSObject.Properties.Remove('metadata') | Out-Null
        }

        if ($copy.PSObject.Properties.Name -contains 'testCase') {
            $tc = $copy.testCase

            # Build ordered testCase: ensure specific important fields appear first in requested order
            $orderedTc = [ordered]@{}

            # Preferred ordering at the top of testCase
            $preferred = @('id', 'title', 'areaPath', 'iterationPath', 'tags', 'assignedTo', 'description')
            foreach ($key in $preferred) {
                if ($tc.PSObject.Properties.Name -contains $key) {
                    $orderedTc[$key] = $tc.$key
                }
            }

            # Add remaining properties (except steps) in their existing order if not already added
            foreach ($p in $tc.PSObject.Properties) {
                if ($p.Name -ne 'steps' -and -not ($orderedTc.Contains($p.Name))) {
                    $orderedTc[$p.Name] = $p.Value
                }
            }

            $stepsArray = @()
            if ($tc.steps) {
                foreach ($s in $tc.steps) {
                    $os = [ordered] @{
                        stepNumber     = $s.stepNumber
                        attachments    = $s.attachments
                        action         = $s.action
                        expectedResult = $s.expectedResult
                    }
                    $stepsArray += $os
                }
            }

            $orderedTc['steps'] = $stepsArray
            $copy.testCase = $orderedTc

        }

        $yaml = ConvertTo-Yaml $copy

        # Manual rendering of steps block to guarantee key order
        $lines = $yaml -split "\r?\n"
        $stepsIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^(\s*)steps:\s*$') {
                $found = $false
                for ($k = $i - 1; $k -ge [Math]::Max(0, $i - 8); $k--) { if ($lines[$k] -match '^\s*testCase:\s*$') { $found = $true; break } }
                if ($found) { $stepsIdx = $i; break }
            }
        }

        if ($stepsIdx -ge 0) {
            $indent = ([regex]::Match($lines[$stepsIdx], '^(\s*)')).Groups[1].Value
            $end = $stepsIdx + 1
            while ($end -lt $lines.Count) {
                $lineIndent = ([regex]::Match($lines[$end], '^(\s*)')).Groups[1].Value
                if ($lineIndent.Length -le $indent.Length -and $lines[$end].Trim() -ne '') { break }
                $end++
            }

            $out = New-Object System.Collections.Generic.List[string]
            $out.Add("$indent`steps:")
            foreach ($s in $copy.testCase.steps) {
                $out.Add($indent + '- ' + "stepNumber: $($s.stepNumber)")
                $out.Add($indent + '  attachments: ' + (if ($s.attachments -and $s.attachments.Count -gt 0) { '[]' } else { '[]' }))
                $actionText = if ([string]::IsNullOrEmpty($s.action)) { '""' } else { '"' + ($s.action -replace '"', '""') + '"' }
                $expText = if ([string]::IsNullOrEmpty($s.expectedResult)) { '""' } else { '"' + ($s.expectedResult -replace '"', '""') + '"' }
                $out.Add($indent + '  action: ' + $actionText)
                $out.Add($indent + '  expectedResult: ' + $expText)
            }

            $new = @()
            if ($stepsIdx -gt 0) { $new += $lines[0..($stepsIdx - 1)] }
            $new += $out
            if ($end -lt $lines.Count) { $new += $lines[$end..($lines.Count - 1)] }

            $yaml = ($new -join "`n")
        }

        # Ensure output directory exists
        $outputDir = Split-Path -Parent $FilePath
        if (-not (Test-Path $outputDir)) {
            New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
        }

        Set-Content -Path $FilePath -Value $yaml -Encoding UTF8

        return $FilePath
    } catch {
        throw "Failed to save YAML to '$FilePath': $($_.Exception.Message)"
    }
}
