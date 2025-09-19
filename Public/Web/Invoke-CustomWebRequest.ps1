function Invoke-CustomWebRequest {

    <#
        .SYNOPSIS
            Helper function for calling a web service.

        .DESCRIPTION
            This function is used by the module to call web services.
            It is not intended to be called directly.

        .PARAMETER Method
            The HTTP method to use. If not specified, it is decided according to
            whether the Body parameter is given. If not, GET is used, otherwise POST.

        .PARAMETER Uri
            Web service call address including query parameters.

        .PARAMETER Body
            Object that should be POSTed as request.

        .PARAMETER ContentType
            The Content-Type header for the POST method. Default is 'application/json'.

        .PARAMETER ApiCredential
            Credential to use for authentication. If not specified,
            $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

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
        $Uri,
        $Body,
        $Method = 'GET',
        $ContentType = 'application/json',
        [hashtable] $Headers,

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

        $params = @{}

        # If called with headers, use them; otherwise, create new hashtable
        if (!$Headers) {
            $Headers = @{}
        }

        # Set uri
        $params['Uri'] = $Uri

        # Request json response
        $Headers['Accept'] = 'application/json'

        # Set body, alter method and content type if body is given
        if ($Body) {
            $params['Body'] = $Body
            if (!$Method -or $Method -eq 'GET') {
                $Method = 'POST'
            }
            if (!$ContentType) {
                $ContentType = 'application/json'
            }
            $params['ContentType'] = $ContentType
        }

        # Set requested method
        if ($Method) {
            $params['Method'] = $Method
        }

        # Determine authorization method, if not given
        if ($Headers.ContainsKey('Authorization')) {
            Write-Verbose "Using from Authorization Header"
            if ($ApiCredential) {
                Write-Warning "ApiCredential is ignored when Authorization is given in Headers"
            }
        } elseif ($ApiCredential) {

            # Add credentials, if given
            switch ($ApiCredential.Authorization) {
                'Basic' {
                    Write-Verbose "Using Basic authorization"
                    $params['Credential'] = $ApiCredential.Credential
                }
                'OAuth' {
                    Write-Verbose "Using OAuth Token"
                }
                'Bearer' {
                    Write-Verbose "Using Bearer Token"
                }
                'PAT' {
                    Write-Verbose "Using Personal Access Token"
                }
                default {
                    Write-Verbose "Using Default credentials"
                    $params['UseDefaultCredentials'] = $true
                }
            }

            # If using tokens, add to headers;
            # PS 5.1 and 6.0 do not support the Token parameter
            if ($ApiCredential.Authorization -in 'PAT', 'Bearer', 'OAuth') {
                # @formatter:off
                $token = switch (Get-PSVersion) {
                    { $_ -ge '7' } { ConvertFrom-SecureString -AsPlainText -SecureString $ApiCredential.Token }
                    '6' { [System.Net.NetworkCredential]::new('', $ApiCredential.Token).Password }
                    default {
                        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ApiCredential.Token)
                        )
                    }
                }
                # @formatter:on

                if ($ApiCredential.Authorization -in 'Bearer', 'OAuth') {
                    # Bearer and OAuth tokens are already encoded
                    $encodedToken = $token
                    $Headers['Authorization'] = "Bearer $($encodedToken)"
                } else {
                    # PAT tokens need to be encoded for Http Basic authentication
                    $encodedToken = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$($token)"))
                    $Headers['Authorization'] = "Basic $($encodedToken)"
                }
            }
        } else {
            $params['UseDefaultCredentials'] = $true

            if ((Get-OSVersion).Platform -notlike 'Win*') {
                throw "No credentials given, and default credentials are not supported on this platform."
            }

            if ($VerbosePreference -eq 'Continue') {
                Write-Warning "No credentials given, using default credentials."
            }
        }

        # Determine whether to use Invoke-WebRequest or curl
        do {
            # Default to Invoke-WebRequest
            $useInvokeWebRequest = $true

            # Use Invoke-WebRequest only if
            # 1. curl is not explicitly requested (TODO: make this configurable)
            if ($CurlIsRequested -eq $true) {
                $useInvokeWebRequest = $false
                break
            }

            # 2. Calling curl on PS5 is broken
            if ((Get-PSVersion) -lt 6) {
                break
            }

            # 3. and we are using default credentials
            #    (curl does not support default credentials)
            if ($true -eq $params['UseDefaultCredentials']) {
                break
            }

            $useInvokeWebRequest = $false

        } while ($false)

        # Add special parameters for Invoke-WebRequest if needed
        if ($useInvokeWebRequest) {
            if ((Get-PSVersion) -gt 5) {
                $params['AllowUnencryptedAuthentication'] = $true
                $params['SkipCertificateCheck'] = $true
            }

            # Prevent errors for users on linux, or without loaded profiles on windows
            # (Internet Explorer engine is used by default in PS 5.1 and older);
            # UseBasicParsing is default in PS 6.0 and later
            if ((Get-PSVersion) -lt 6) {
                $params['UseBasicParsing'] = $true
            }
        }

        # Write verbose output, if requested.
        # Invoke-CurlWebRequest has verbose output built in.
        if ($useInvokeWebRequest) {
            if ($VerbosePreference -eq 'Continue') {
                $headersWithValues = ($Headers.GetEnumerator() `
                    | ForEach-Object { "  $($_.Key): $($_.Value)" } `
                ) -join "`n"

                $paramsWithValues = ($params.GetEnumerator() `
                    | Where-Object { $_.Key -ne 'Headers' } `
                    | ForEach-Object { "  $($_.Key): $($_.Value)" } `
                ) -join "`n"

                Write-Verbose "Invoke-WebRequest `n$($headersWithValues)`n$($paramsWithValues)"
            }
        }

        # Add headers, if not empty
        if ($Headers) {
            $params['Headers'] = $Headers
        }

        # Execute the web request with retry logic (if enabled)
        if ($DisableRetry.IsPresent -and $DisableRetry -eq $true) {
            # No retry logic - execute directly
            if ($useInvokeWebRequest) {
                # Always disable progress bars
                $ProgressPreference = 'SilentlyContinue'
                $response = Invoke-WebRequest @params
            } else {
                $response = Invoke-CurlWebRequest $params
            }
        } else {
            # Use retry logic
            $response = Invoke-WithRetry -ScriptBlock {
                if ($useInvokeWebRequest) {
                    # Always disable progress bars
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest @params
                } else {
                    Invoke-CurlWebRequest $params
                }
            } -RetryCount $RetryCount `
              -RetryDelay $RetryDelay `
              -MaxRetryDelay $global:AzureDevOpsApi_RetryConfig.MaxRetryDelay `
              -UseExponentialBackoff $global:AzureDevOpsApi_RetryConfig.UseExponentialBackoff `
              -UseJitter $global:AzureDevOpsApi_RetryConfig.UseJitter
        }

        # Return the response
        return $response
    }
}
