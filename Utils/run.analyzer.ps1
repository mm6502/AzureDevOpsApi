#requires -version 5
#requires -modules 'PSScriptAnalyzer'

Import-Module -Name 'PSScriptAnalyzer' -Force

<#
    .SYNOPSIS
        Invokes the Script Analyzer with custom configuration.
#>
function Invoke-Analyzer {

    <#
        .SYNOPSIS
            Invokes the Script Analyzer.

        .PARAMETER Path
            List of paths to search the scripts on.

        .PARAMETER ExcludeRules
            List of analyzer rule names to disregard.

        .PARAMETER ExcludePaths
            List of path regexes to exclude from analyzing.

        .PARAMETER Limit
            Limit the output to this number of items.
            Default is 10.
    #>

    [CmdletBinding()]
    param(
        $Path,
        [string[]] $ExcludeRules,
        [string[]] $ExcludePaths,
        $Limit = 10
    )

    # Write out intent
    Show-Host -ForegroundColor Magenta -Object 'Running analysis'

    # Run the analyzer
    $data = $Path `
    | Where-Object { $_ } `
    | ForEach-Object { Get-ChildItem -Path $_ -Recurse -File } `
    | Where-Object {
        # Apply the exclude paths
        $path = $_.FullName
        foreach ($excludePath in $ExcludePaths) {
            if ($path -imatch $excludePath) {
                return $false
            }
        }
        return $true
    } `
    | ForEach-Object { Invoke-ScriptAnalyzer -Path $_ -Recurse } `
    | Where-Object { $_.RuleName -inotin $ExcludeRules }

    # Compile the data
    $outputData = $data `
    | Group-Object 'ScriptName' `
    | Sort-Object 'Count' -Descending `
    | Select-Object -First $Limit -ExpandProperty 'Group'

    # Write out the violations
    if (!$outputData) {
        Show-Host -ForegroundColor Green "No violations found."
        return
    }

    $outputData `
    | Format-Table 'RuleName', 'Severity', 'Line', 'ScriptName'

    # Write out the messages
    $outputData `
    | Group-Object 'RuleName' `
    | ForEach-Object { $_.Group | Select-Object -First 1 } `
    | Sort-Object -Descending `
        @{ Expression = { $_.Severity -eq 'Error' }; Descending = $true }, `
        @{ Expression = { $_.Severity -eq 'Warning' }; Descending = $true }, `
        @{ Expression = { $_.Severity -eq 'Information' }; Descending = $true } `
    | Format-Table 'RuleName', 'Severity', 'Message' -Wrap
}

$rootPath = Join-Path -Path $PSScriptRoot -ChildPath '..'
. (Join-Path -Path $rootPath -ChildPath 'Public/Internal/Show-Host.ps1')

$path = @(
    '.\Public\**'
    '.\Private\**'
    '.\Tests\**'
) `
| ForEach-Object { Join-Path -Path $rootPath -ChildPath $_ }

$rulesToExclude = @(
    'PSUseToExportFieldsInManifest'
    'PSAvoidGlobalVars'
#    'PSUseShouldProcessForStateChangingFunctions'
#    'PSUseSingularNouns'
#    'PSReviewUnusedParameter'
)

$pathsToExclude += @(
    # Any script that runs something;
    # /run.ps1
    # /Utils/run.tests.ps1
    '(^|[\\/])run(?:[.].*)?[.]ps1'
    # Any include script for tests
    '(^|[\\/])BeforeAll[.]ps1'
)

Invoke-Analyzer `
    -Path $path `
    -ExcludeRules $rulesToExclude `
    -ExcludePaths $pathsToExclude
