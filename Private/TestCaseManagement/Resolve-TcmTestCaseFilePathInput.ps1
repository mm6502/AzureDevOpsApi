function Resolve-TcmTestCaseFilePathInput {
    <#
        .SYNOPSIS
            Helper to resolve file path input for sync functions, supporting pipeline and parameter input.
        .DESCRIPTION
            Accepts either a file path (string), array of file paths, or objects with a FilePath property from the pipeline.
            Returns a flat array of file paths for further processing.
        .PARAMETER InputObject
            The input object(s) from the pipeline or parameter.
        .OUTPUTS
            [string[]] Array of resolved file paths.
        .EXAMPLE
            'TestCases/area/TC001.yaml' | Resolve-TcmTestCaseFilePathInput
        .EXAMPLE
            Resolve-TcmTestCaseFilePathInput -InputObject @('a.yaml','b.yaml')
    #>
    [OutputType('PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $InputObject,

        [string] $TestCasesRoot
    )

    begin {
        $filePaths = @()
    }

    process {

        if ($null -eq $InputObject) {
            return
        }

        $item = $InputObject

        # If object is already a TcmTestCaseFileInput, pass through
        if ($item -and $item.PSTypeNames `
            -and $item.PSTypeNames -contains 'PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput') {
            $filePaths += $item
            return
        }

        # Handle TestCase objects from Get-TcmTestCaseFromFile
        if ($item -and $item.PSTypeNames `
            -and $item.PSTypeNames -contains $global:PSTypeNames.AzureDevOpsApi.TcmTestCase) {
            $filePaths += [PSCustomObject] @{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput'
                FilePath     = $item.FilePath
                TestCaseData = $item
                Id           = $item.testCase.id
            }
            return
        }

        # Handle hashtable/PSCustomObject from Get-TcmTestCase (has testCase.id property)
        if ($item -is [hashtable] -or $item -is [PSCustomObject]) {
            if ($item.testCase -and $item.testCase.id) {
                $filePaths += [PSCustomObject] @{
                    PSTypeName   = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput'
                    FilePath     = $item.FilePath
                    TestCaseData = $item
                    Id           = $item.testCase.id
                }
                return
            }
        }

        # Handle string input (file path or ID)
        if ($item -is [string] -and (Test-Path $item -PathType Leaf)) {
            try {
                $data = Get-TcmTestCaseFromFile -FilePath $item -IncludeMetadata -ErrorAction Stop
                $filePaths += [PSCustomObject] @{
                    PSTypeName   = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput'
                    FilePath     = $item
                    TestCaseData = $data
                    Id           = $data.testCase.id
                }
            } catch {
                Write-Warning "Failed to read test case file: $item. $_"
            }
        } else {
            # Treat as ID
            $filePaths += [PSCustomObject] @{
                PSTypeName   = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput'
                FilePath     = $null
                TestCaseData = $null
                Id           = $item
            }
        }
    }
    end {
        # If no input was provided and TestCasesRoot is specified, get all test cases
        if (-not $filePaths -and $TestCasesRoot) {
            $allTestCases = Get-TcmTestCase -TestCasesRoot $TestCasesRoot
            foreach ($item in $allTestCases) {
                # Handle hashtable/PSCustomObject from Get-TcmTestCase (has testCase.id property)
                if ($item -is [hashtable] -or $item -is [PSCustomObject]) {
                    if ($item.testCase -and $item.testCase.id) {
                        $filePaths += [PSCustomObject] @{
                            PSTypeName   = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput'
                            FilePath     = $item.FilePath
                            TestCaseData = $item
                            Id           = $item.testCase.id
                        }
                        continue
                    }
                }
            }
        }

        # Only return objects with Id
        $filePaths | Where-Object { $_ -and $_.Id }
    }
}