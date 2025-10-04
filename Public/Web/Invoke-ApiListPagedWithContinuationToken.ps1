function Invoke-ApiListPagedWithContinuationToken {

    <#
        .SYNOPSIS
            Calls web API returning paged list of records using continuation token pagination.

        .DESCRIPTION
            Calls web API returning paged list of records using continuation token pagination.
            This is used for APIs that use the x-ms-continuationtoken header for pagination
            instead of $skip and $top query parameters.

            The function iterates through all pages by following the continuation token
            returned in the response header until no more pages are available.

        .PARAMETER ApiCredential
            Credential to use for authentication. If not specified,
            $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

        .PARAMETER ApiVersion
            Requested version of Azure DevOps API.
            If not specified, $global:AzureDevOpsApi_ApiVersion (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Uri
            Address of the service including query parameters.

        .PARAMETER Body
            Object to POST as a request.

        .PARAMETER Method
            The HTTP method to use. If not specified, it is decided according to
            whether the Body parameter is given. If not, GET is used, otherwise POST.

        .PARAMETER ContinuationTokenParameterName
            The name of the query parameter to use for the continuation token.
            Default is 'continuationToken'.

        .PARAMETER AsHashTable
            If specified, deserializes the JSON response to a hashtable, instead of standard [PSObject].

        .PARAMETER RetryCount
            The maximum number of retry attempts for transient failures. Default is 3.

        .PARAMETER RetryDelay
            The base delay in seconds between retry attempts. Default is 1 second.

        .PARAMETER DisableRetry
            Disables retry logic completely.

        .NOTES
            This function is designed for Azure DevOps APIs that use continuation token pagination,
            such as the Test Plans API (v7.1+).

        .EXAMPLE
            $uri = "https://dev.azure.com/myorg/myproject/_apis/testplan/Plans/123/suites"
            $results = Invoke-ApiListPagedWithContinuationToken -Uri $uri

        .EXAMPLE
            $uri = "https://dev.azure.com/myorg/myproject/_apis/testplan/Plans/123/suites"
            $results = Invoke-ApiListPagedWithContinuationToken `
                -Uri $uri `
                -ContinuationTokenParameterName 'continuationToken'
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        $ApiVersion,

        [Parameter(Mandatory)]
        $Uri,

        $Body,

        $Method,

        [string]
        $ContinuationTokenParameterName = 'continuationToken',

        [switch]
        $AsHashTable,

        [Parameter(ParameterSetName = 'ShowProgress')]
        $Activity,

        [ValidateRange(0, 10)]
        [int] $RetryCount,

        [ValidateRange(0.1, 300)]
        [double] $RetryDelay,

        [switch] $DisableRetry
    )

    begin {
        $showProgress = $PSCmdlet.ParameterSetName -eq 'ShowProgress'

        # Use global configuration as defaults if not specified
        if (-not $PSBoundParameters.ContainsKey('RetryCount')) {
            $RetryCount = $global:AzureDevOpsApi_RetryConfig.RetryCount
        }
        if (-not $PSBoundParameters.ContainsKey('RetryDelay')) {
            $RetryDelay = $global:AzureDevOpsApi_RetryConfig.RetryDelay
        }
        if (-not $PSBoundParameters.ContainsKey('DisableRetry')) {
            $DisableRetry = $global:AzureDevOpsApi_RetryConfig.DisableRetry
        }
    }

    process {

        # Determine whether relative or absolute uri was given
        if (-not ([Uri]::new($Uri, [UriKind]::RelativeOrAbsolute)).IsAbsoluteUri) {
            throw "Uri must be absolute. Given: $Uri"
        }

        # If ApiVersion is not specified, use default value
        $ApiVersion = Use-ApiVersion -ApiVersion $ApiVersion

        # Add ApiVersion parameter to the Uri
        $genericUrl = Add-QueryParameter -Uri $Uri -Parameters @{
            'api-version' = $ApiVersion
        }

        $continuationToken = $null
        $pageCount = 0
        $maxPages = 1000  # Safety limit to prevent infinite loops

        do {
            $pageCount++

            if ($pageCount -gt $maxPages) {
                throw "Maximum page limit ($maxPages) exceeded. Possible infinite loop in continuation token pagination."
            }

            if ($showProgress) {
                Write-Progress -Activity $Activity -Status "Page $pageCount"
            }

            # Build the URI with continuation token if available
            if ($continuationToken) {
                $finalUri = Add-QueryParameter -Uri $genericUrl -Parameters @{
                    $ContinuationTokenParameterName = $continuationToken
                }
            } else {
                $finalUri = $genericUrl
            }

            # Get the data
            try {
                $httpResponse = Invoke-CustomWebRequest `
                    -ApiCredential $ApiCredential `
                    -Uri $finalUri `
                    -Body $Body `
                    -Method $Method `
                    -RetryCount $RetryCount `
                    -RetryDelay $RetryDelay `
                    -DisableRetry:$DisableRetry
            } catch {
                throw
            }

            $data = @($httpResponse.Content | ConvertFrom-JsonCustom -AsHashtable:$AsHashTable)

            # Send data down the pipeline
            if ($data.value) {
                Write-Output $data.value
            }

            # Check for continuation token in response headers
            if ($httpResponse.Headers -and $httpResponse.Headers['x-ms-continuationtoken']) {
                $continuationToken = $httpResponse.Headers['x-ms-continuationtoken']
                if ($continuationToken -is [array]) {
                    $continuationToken = $continuationToken[0]
                }
            } else {
                $continuationToken = $null
            }

        } while ($continuationToken)
    }

    end {
        if ($showProgress) {
            Write-Progress -Activity $Activity -Completed
        }
    }
}
