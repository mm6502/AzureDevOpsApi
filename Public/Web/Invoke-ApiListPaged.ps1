function Invoke-ApiListPaged {

    <#
        .SYNOPSIS
            Calls web API returning paged list of records.
            For example to list all PullRequests for a project.

        .DESCRIPTION
            Calls web API returning paged list of records.
            If both $Top and $Skip are not specified, iterates the request with increasing
            $Skip by $Top on each iteration, until records are no longer returned.

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

        .PARAMETER PageSize
            Count of records per page.
            Used when function should iterate through the records.
            If not specified, 100 is used, because for many API functions that is the maximum
            allowed by Azure DevOps.

        .PARAMETER Top
            Count of records to return page.
            Used when function should NOT iterate through the records - calling function is
            responsible for paging. If not specified, 100 is used, because for many API
            functions that is the maximum allowed by Azure DevOps.

        .PARAMETER Skip
            Count of records to skip before returning the $Top count of records.
            If not specified, iterates the request with increasing $Skip by $Top,
            while records are being returned.

        .PARAMETER AsHashTable
            If specified, deserializes the JSON response to a hashtable, instead of standard [PSObject].

        .PARAMETER RetryCount
            The maximum number of retry attempts for transient failures. Default is 3.

        .PARAMETER RetryDelay
            The base delay in seconds between retry attempts. Default is 1 second.

        .PARAMETER DisableRetry
            Disables retry logic completely.
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
        [switch] $AsHashTable,
        $PageSize,
        $Top,
        $Skip,

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

        # If Paging is not driven by caller, iterate through the records
        $paging = Use-PagingParameters -Top:$Top -Skip:$Skip -PageSize:$PageSize

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

        do {
            if ($showProgress) {
                Write-Progress -Activity $Activity -Status $paging.Skip
            }

            $finalUri = Add-QueryParameter -Uri $genericUrl -Parameters @{
                '$skip' = $paging.Skip
                '$top'  = $paging.Top
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

            # Sends data down the pipeline
            if ($data.value) {
                Write-Output $data.value
            }

            # Adjust paging
            $paging.Skip += $data.value.Count
        }
        # Iterate as needed
        while ((!$paging.ShouldPage) -and ($data.value.Count -eq $paging.Top))
    }

    end {
        if ($showProgress) {
            Write-Progress -Activity $Activity -Completed
        }
    }
}

Set-Alias -Name Invoke-ApiList -Value Invoke-ApiListPaged
