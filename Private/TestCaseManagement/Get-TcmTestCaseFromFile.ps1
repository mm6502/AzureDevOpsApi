function Get-TcmTestCaseFromFile {
    <#
        .SYNOPSIS
            Loads a test case from a YAML file.

        .PARAMETER FilePath
            Full path to the YAML file.

        .PARAMETER IncludeMetadata
            Include the legacy metadata block in the output when present.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.TcmTestCase')]
    param(
        [Parameter(Mandatory)]
        [string] $FilePath,

        [switch] $IncludeMetadata
    )

    if (-not (Test-Path $FilePath)) {
        throw "Test case file not found: $FilePath"
    }

    try {
        $yamlContent = Get-Content -Path $FilePath -Raw
        $testCase = ConvertFrom-Yaml $yamlContent

        # Migrate legacy metadata fields into new layout if present
        if ($testCase.metadata) {
            # If metadata.id exists, rename to localId
            if ($testCase.metadata.PSObject.Properties.Name -contains 'id' -and -not ($testCase.metadata.PSObject.Properties.Name -contains 'localId')) {
                $testCase.metadata.localId = $testCase.metadata.id
                $testCase.metadata.PSObject.Properties.Remove('id') | Out-Null
            }

            # Move title and azureDevOpsId into testCase if they exist in metadata
            if ($testCase.metadata.PSObject.Properties.Name -contains 'title') {
                if (-not $testCase.testCase) { $testCase.testCase = @{} }
                if (-not $testCase.testCase.PSObject.Properties.Name -contains 'title') {
                    $testCase.testCase.title = $testCase.metadata.title
                }
                $testCase.metadata.PSObject.Properties.Remove('title') | Out-Null
            }

            if ($testCase.metadata.PSObject.Properties.Name -contains 'azureDevOpsId') {
                if (-not $testCase.testCase) { $testCase.testCase = @{} }
                if (-not $testCase.testCase.PSObject.Properties.Name -contains 'id') {
                    $testCase.testCase.id = $testCase.metadata.azureDevOpsId
                }
                $testCase.metadata.PSObject.Properties.Remove('azureDevOpsId') | Out-Null
            }
        }

        # Ensure testCase object exists and has title/id keys
        if (-not $testCase.testCase) { $testCase.testCase = @{} }
        if (-not $testCase.testCase.PSObject.Properties.Name -contains 'title') { $testCase.testCase.title = '' }
        if (-not $testCase.testCase.PSObject.Properties.Name -contains 'id') { $testCase.testCase.id = $null }

        # Calculate content hash for sync purposes (before removing metadata)
        $contentForHash = $testCase.testCase
        $hash = Get-TcmStringHash -InputObject $contentForHash

        # Remove metadata if not requested
        if (-not $IncludeMetadata) {
            $testCase.PSObject.Properties.Remove('metadata') | Out-Null
            $testCase.PSObject.Properties.Remove('history') | Out-Null
        }

        # Convert to PSCustomObject first
        $result = [PSCustomObject]$testCase
        $result.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCase)

        # Add computed properties AFTER conversion to PSCustomObject
        # (NoteProperties added to hashtables are lost during [PSCustomObject] conversion)
        $result | Add-Member -NotePropertyName 'FilePath' -NotePropertyValue $FilePath -Force
        $result | Add-Member -NotePropertyName 'FileName' -NotePropertyValue (Split-Path -Leaf $FilePath) -Force
        $result | Add-Member -NotePropertyName 'RelativePath' -NotePropertyValue (Get-TcmRelativeTestCasePath -FilePath $FilePath) -Force
        $result | Add-Member -NotePropertyName 'ContentHash' -NotePropertyValue $hash -Force

        return $result
    }
    catch {
        throw "Failed to parse test case file '$FilePath': $($_.Exception.Message)"
    }
}