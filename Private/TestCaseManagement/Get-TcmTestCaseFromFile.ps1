function Get-TcmTestCaseFromFile {
    <#
        .SYNOPSIS
            Loads a test case from a YAML file.

        .PARAMETER FilePath
            Full path to the YAML file.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.TcmTestCaseLocalData')]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    if (-not (Test-Path $FilePath -PathType Leaf)) {
        throw "Test case file not found: $FilePath"
    }

    try {
        $yamlContent = Get-Content -Path $FilePath -Raw
        $testCase = ConvertFrom-Yaml $yamlContent

        # Handle empty or invalid YAML files
        if (-not $testCase) {
            throw "YAML file is empty or invalid"
        }

        # Ensure testCase object exists and has title/id keys
        if (-not $testCase.testCase) { $testCase.testCase = @{} }
        if (-not $testCase.testCase.PSObject.Properties.Name -contains 'title') { $testCase.testCase.title = '' }
        if (-not $testCase.testCase.PSObject.Properties.Name -contains 'id') { $testCase.testCase.id = $null }

        # Calculate content hash for sync purposes
        $contentForHash = $testCase.testCase
        $hash = Get-TcmStringHash -InputObject $contentForHash

        # Convert to PSCustomObject first
        $result = [PSCustomObject]$testCase
        $result.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseLocalData)

        # Add computed properties AFTER conversion to PSCustomObject
        # (NoteProperties added to hashtables are lost during [PSCustomObject] conversion)
        $result | Add-Member -NotePropertyName 'FilePath' -NotePropertyValue $FilePath -Force
        $result | Add-Member -NotePropertyName 'FileName' -NotePropertyValue (Split-Path -Leaf $FilePath) -Force
        $result | Add-Member -NotePropertyName 'LocalDataHash' -NotePropertyValue $hash -Force

        return $result
    }
    catch {
        throw "Failed to parse test case file '$FilePath': $($_.Exception.Message)"
    }
}