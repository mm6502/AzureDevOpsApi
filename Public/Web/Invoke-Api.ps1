function Invoke-Api {

    <#
        .SYNOPSIS
            Helper function for calling a web service returning a single object.
            For example, for a project detail.

        .PARAMETER ApiCredential
            Credential to use for authentication. If not specified,
            $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

        .PARAMETER ApiVersion
            Requested version of Azure DevOps API.
            If not specified, $global:AzureDevOpsApi_ApiVersion (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Uri
            Web service call address including query parameters.

        .PARAMETER Body
            An object that can be POSTed as a request.

        .PARAMETER Method
            The HTTP method to use. If not specified, it is decided according to
            whether the Body parameter is given. If not, GET is used, otherwise POST.

        .PARAMETER ContentType
            The Content-Type header when sending Body. Default is 'application/json'.

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
        $Uri,
        $Body,
        $Method,
        $ContentType,
        [switch] $AsHashTable,

        [ValidateRange(0, 10)]
        [int] $RetryCount,

        [ValidateRange(0.1, 300)]
        [double] $RetryDelay,

        [switch] $DisableRetry
    )

    begin {
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

        # Use global variables if not specified
        $ApiVersion = Use-ApiVersion -ApiVersion $ApiVersion

        # Add api version parameter
        $genericUrl = Add-QueryParameter `
            -Uri $Uri `
            -Parameters @{ 'api-version' = $ApiVersion }

        try {
            # Call the api
            $httpResponse = Invoke-CustomWebRequest `
                -ApiCredential $ApiCredential `
                -Uri $genericUrl `
                -Body $Body `
                -Method $Method `
                -ContentType $ContentType `
                -RetryCount $RetryCount `
                -RetryDelay $RetryDelay `
                -DisableRetry:$DisableRetry
        } catch {
            # In some cases 404 can be returned
            # for example requesting work item before its creation date time using AsOf parameter
            # Standard WebExceptions
            if ($ErrorActionPreference -eq 'Stop') {
                Assert-HttpResponse -Error $_
                return
            }

            if ($_.Exception.Response.StatusCode -eq 404) {
                return
            }
            # For testing purposes, since I can not simulate standard WebExceptions thrown in Powershell 5
            if ($_.TargetObject.StatusCode -eq 404) {
                return
            }
        }

        $result = $httpResponse.Content `
        | ConvertFrom-JsonCustom -AsHashtable:$AsHashTable

        if ($null -ne $result) {
            return $result
        }
    }
}

Set-Alias -Name Invoke-ApiGet -Value Invoke-Api
