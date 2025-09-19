[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingCmdletAliases', '',
    Justification = 'Intentional usage of curl executable.'
)]
param()

function Invoke-CurlWebRequest {

    <#
        .SYNOPSIS
            Using curl executable to invoke web request instead of Invoke-WebRequest.

        .DESCRIPTION
            This function is used by the module to call web services instead of Invoke-WebRequest.
            It is not intended to be called directly.

            Parameters are intended to be the same as in Invoke-WebRequest.
            Declared as single parameter due to simplicity of declaration.

        .NOTES
            username password *does* work on linux
            ssl certificate check *can* be skipped on linux
    #>

    [CmdletBinding()]
    param($params)

    process {

        if (!$Headers -and $params.ContainsKey('Headers')) {
            $Headers = $params['Headers']
        }

        # Report params when verbose requested
        if ($VerbosePreference -eq 'Continue') {
            $headersWithValues = ($Headers.GetEnumerator() `
                | ForEach-Object { "  $($_.Key): $($_.Value)" } `
            ) -join "`n"

            $paramsWithValues = ($params.GetEnumerator() `
                | Where-Object { $_.Key -ne 'Headers' } `
                | ForEach-Object { "  $($_.Key): $($_.Value)" } `
            ) -join "`n"

            Write-Verbose "curl `n$($headersWithValues)`n$($paramsWithValues)"
        }

        # Determine credentials and authentication type
        # use --anyauth or --ntlm for username/password (--anyauth does not work on linux...)
        # use --basic for PAT
        # use --anyauth for OAuth2
        $authParams = '--anyauth'

        if ($params.Credential) {
            # If Credentials are provided, use NTLM authentication
            $username = $params.Credential.GetNetworkCredential().UserName
            $password = $params.Credential.GetNetworkCredential().Password
            $authParams = '--ntlm', '--user', "$($username):$($password)"
        } elseif ($Headers['Authorization']) {
            # If Authorization header is provided, extract scheme and value
            $scheme, $authHeaderValue = ($Headers['Authorization'] -split ' ')
            if ($scheme -eq 'Bearer') {
                # curl --oauth2-bearer YOUR_TOKEN https://dev-tfs/tfs/internal_projects/zvjs/_apis...
                $authParams = '--oauth2-bearer', $authHeaderValue
            } elseif ($scheme -eq 'Basic') {
                # If scheme is Basic take username and password from it
                $username, $password = [System.Text.Encoding]::UTF8.GetString(
                    [System.Convert]::FromBase64String($authHeaderValue)
                ) -split ':'
                # If username is provided, default to NTLM authentication
                if ($username) {
                    $authParams = '--ntlm', '--user', "$($username):$($password)"
                } else {
                    # assuming it is a PAT auth
                    $authParams = '--basic', '--user', ":$($password)"
                }
            }
        }

        # Create the parameters for curl command
        $curlParams = @(
            # use progressbar instead of statistics
            # usefull when redirecting error output - won't clutter the output
            '-#'
            # silent
            '--silent'
            # show errors
            '--show-error'
            # no url globbing
            '--globoff'
            # include headers in output
            '--include'
            # disable certificate check
            '--insecure'
            # timeout
            '--connect-timeout', 5
            # url to call
            '--url', $params.uri
            # requested authorization parameters
            $authParams
        )

        # Add additional Headers (except Authorization)
        foreach ($header in $Headers.GetEnumerator()) {
            if ($header.Key -eq 'Authorization') {
                continue
            }

            $curlParams += '--header', "$($header.Key): $($header.Value)"
        }

        # Use given method
        if ($params.ContainsKey('Method')) {
            $curlParams += '--request', $params.Method
        }

        # Use Body
        if ($params.ContainsKey('Body')) {
            # Add Content-Type if provided Body
            if ($params.ContainsKey('ContentType')) {
                $curlParams += '--header', "Content-Type: $($params.ContentType)"
            }

            # Add the body if provided
            $curlParams += '--data', $params.Body
        }

        # Execute the curl command

        # Ensure the input / output is UTF-8 encoded
        $inputEncoding = [console]::InputEncoding
        $outputEncoding = [console]::OutputEncoding
        [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

        # If debug is enabled, show the curl command
        if ($DebugPreference -eq 'Continue') {
            Write-Verbose "curl $($curlParams)"
        }

        # Execute the curl executable
        if ((Get-PSVersion) -lt 6) {
            # PS5 does a lousy job of encoding the parameters
            $curlResponse = & curl.exe @curlParams *>&1

            # Tried a workaround, but could not figure out the right way to escape special
            # characters in input parameters
            # $psi = [System.Diagnostics.ProcessStartInfo]::new()
            # $psi.RedirectStandardOutput = $true
            # $psi.RedirectStandardError = $true
            # $psi.RedirectStandardInput = $true
            # $psi.UseShellExecute = $false
            # $psi.CreateNoWindow = $false
            # $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
            # $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8
            # $psi.FileName = 'curl.exe'
            # $psi.Arguments = ($curlParams | ForEach-Object {
            #         $tmp = $_
            #         # Handle quotes in argument values
            #         $tmp = $tmp -replace '"', '""'
            #         if ($tmp -notlike '-*') {
            #             # Handle special characters
            #             $tmp = [regex]::new("([()[\]{}^;!'+,`~])").Replace($tmp, '^$1')
            #             $tmp = $tmp -replace "&", "`&"
            #             $tmp = $tmp -replace "[$]", "`$"
            #             # Handle spaces in argument values
            #              if ($tmp -match "[ &()[\]{}^=;!'+,`~]") {
            #             if ($tmp -match "["":& `r`n]") {
            #                 $tmp = "`"$($tmp)`""
            #             }
            #         }
            #         $tmp
            #     }) -join ' '

            # Write-Host "curl $($psi.Arguments)"

            # # Output is read as a single string (then split into lines) to get the same output
            # # as the original curl command
            # $process = [System.Diagnostics.Process]::Start($psi)
            # $process.WaitForExit()

            # # Process output
            # $curlResponse1 = $process.StandardOutput.ReadToEnd()

            # # Detect end of line characters
            # $index10 = $curlResponse1.IndexOf([char]10)
            # $index13 = $curlResponse1.IndexOf([char]13)
            # # If index difference is 1, it's a line ending sequence
            # if ([Math]::Abs($index10 - $index13) -eq 1) {
            #     $ln = "`r`n"
            # } else {
            #     $ln = "`n"
            # }

            # $curlResponse = @($curlResponse1 -split $ln)
            # $curlExitCode = $process.ExitCode
        } else {
            # Output is read as array of strings
            $curlResponse = & curl @curlParams *>&1
            $curlExitCode = $LASTEXITCODE
        }

        # Ensure the input / output is encoding is reset
        [console]::InputEncoding = $inputEncoding
        [console]::OutputEncoding = $outputEncoding

        # are we in testing mode?
        if ($Pester) {
            # the output unusable because mangled by the Pester mock;
            # try to find the mock output
            $curlResponse = $curlResponse `
            | Where-Object { $_ -notmatch '^\[30m\[43mMock:' }
        }

        # Check for executing errors;
        # If anything other than 0, exit with error
        # 2 = curl: (2) unknown option
        # 6 = curl: (6) Could not resolve host: ...
        if (!$Pester -and $curlExitCode -ne 0) {
            # If $ErrorActionPreference is set to Stop, throw an exception
            # Otherwise, write the error to the error stream and return
            if ($ErrorActionPreference -eq 'Stop') {
                throw $curlResponse
            } else {
                # Write-Error cmdlet does not set the $? variable to $false;
                # so we have to use the $PSCmdlet.WriteError
                foreach ($line in $curlResponse) {
                    $PSCmdlet.WriteError($line)
                }
                return
            }
        }

        # Process the response
        # index the lines for easier processing
        $index = 0
        $response = @(
            $curlResponse `
            | ForEach-Object -Process {
                [PSCustomObject] @{
                    Index   = $index++
                    Content = $_
                }
            }
        )

        # Write out the response for debugging
        if ($DebugPreference -eq 'Continue' -and $VerbosePreference -eq 'Continue') {
            $response | Out-Host
        }

        # Find last line starting with "HTTP/"
        # There may be more than one if multiple requests were made -
        # for example due to redirection or authentication
        $lastHttpLine = $response `
        | Where-Object { $_.Content -like "HTTP/*" } `
        | Select-Object -Last 1

        # Find the end of the headers
        # (aka the next empty line)
        $endOfHeadersLine = $response `
        | Select-Object -Skip ($lastHttpLine.Index) `
        | Where-Object { -not ($_.Content) } `
        | Select-Object -First 1

        # Find last content-type header
        $lastContentTypeLine = $response `
        | Where-Object { $_.Index -lt $endOfHeadersLine.Index } `
        | Where-Object { $_.Content -like "Content-Type:*" } `
        | Select-Object -Last 1
        $contentType = ($lastContentTypeLine.Content -split '[:; ]')[2]

        # Find last content-length header
        $lastContentLengthLine = $response `
        | Where-Object { $_.Index -lt $endOfHeadersLine.Index } `
        | Where-Object { $_.Content -like "Content-Length:*" } `
        | Select-Object -Last 1
        $contentLength = ($lastContentLengthLine.Content -split ' ')[1]

        # Remaining response lines should be the payload;
        # join them together to a string
        $content = ($response `
            | Select-Object -Skip ($endOfHeadersLine.Index + 1) `
            | Select-Object -ExpandProperty Content
        ) -join "`n"

        # Report the content type and length
        Write-Verbose "Received $($contentLength) bytes of $($contentType)."

        # Parse the status code and reason phrase
        # HTTP/1.1 200 OK
        # HTTP/2 401 Unauthorized
        # HTTP/2 404 Not Found
        [int] $statusCode, [string] $reasonPhrase = ($lastHttpLine.Content -split ' ', 3)[1..2]
        if (!$reasonPhrase) {
            $reasonPhrase = [System.Net.HttpStatusCode] $statusCode
        }

        # Report the status code and reason phrase
        Write-Verbose "Status line: $($lastHttpLine.Content)"
        Write-Verbose "Status code: $($statusCode) $($reasonPhrase)"

        # Handle non-200 status codes
        if ($statusCode -eq '401') {
            $combinedErrorMessage = 'Access is denied due to invalid credentials.'
            $contentType = 'text/html'
        } elseif ($statusCode -ne '200') {

            # Try to find error message in response

            # 1/ From header
            # Find error in X-TFS-ServiceError header
            # X-TFS-ServiceError: TF400813%3A%20Resource%20not%20available%20for%20anonymous%20access...
            $lastXTfsServiceErrorLine = $response `
            | Where-Object { $_.Index -lt $endOfHeadersLine.Index } `
            | Where-Object { $_.Content -like "X-TFS-ServiceError:*" } `
            | Select-Object -Last 1

            if ($lastXTfsServiceErrorLine) {
                $errorMessage = [System.Web.HttpUtility]::UrlDecode(
                    $lastXTfsServiceErrorLine.Content.Split(':')[1].Trim()
                )
            }

            # 2/ From text/html payload
            # 45 <div id="content">
            # 46  <div class="content-container"><fieldset>
            # 47   <h2>401 - Unauthorized: Access is denied due to invalid credentials.</h2>
            # 48   <h3>You do not have permission to view this directory or page using the credentials that you supplied.</h3>
            # 49  </fieldset></div>
            if ($contentType -eq 'text/html') {

                $errorLine1 = $response `
                | Select-Object -Skip ($endOfHeadersLine.Index) `
                | Where-Object { $_.Content -like "*<h2>*" } `
                | Select-Object -First 1 -ExpandProperty Content

                $errorLine2 = $response `
                | Select-Object -Skip ($endOfHeadersLine.Index) `
                | Where-Object { $_.Content -like "*<h3>*" } `
                | Select-Object -First 1 -ExpandProperty Content

                if ($errorLine1 -match '<h2>(.*)</h2>') {
                    $errorMessage = $Matches[1]
                }

                if ($errorLine2 -match '<h3>(.*)</h3>') {
                    $errorDescription = $Matches[1]
                }
            }

            # 3/ From application/json payload
            if (-not $errorMessage -and ($contentType -eq 'application/json')) {
                $errorPayload = $content | ConvertFrom-JsonCustom
                # Get error details for Create and Update errors;
                # they will have attribute validation errors
                $errorDescription = $errorPayload.customProperties.RuleValidationErrors.errorMessage
                if ($errorDescription) {
                    $errorMessage = $errorDescription
                    $errorDescription = $null
                }
                if (!$errorMessage) {
                    $errorMessage = $errorPayload.value.message
                }
                if (!$errorMessage) {
                    $errorMessage = $errorPayload.Message
                }
            }

            if ($errorMessage -and $errorDescription) {
                $combinedErrorMessage = $errorMessage + ' ' + $errorDescription
            } else {
                $combinedErrorMessage = $errorMessage
            }
        }

        if ($statusCode -ne '200') {
            # Write-Verbose output
            Write-Verbose "Response: $($combinedErrorMessage)"
        }

        # Create a 'powershell-like' WebResponse object
        $webResponse = [PSCustomObject] @{
            StatusCode        = $statusCode
            StatusDescription = $reasonPhrase
            ContentType       = $contentType
            Content           = $content -join "`n"
            RawContent        = ($response `
                | Select-Object -Skip ($lastHttpLine.Index) `
                | Select-Object -ExpandProperty Content `
            ) -join "`n"
            Headers           = @{ }
            RawContentLength  = 0
        }

        # Finish the response
        # Set content length
        $webResponse.RawContentLength = $webResponse.RawContent.Length

        # Parse the headers
        $response `
        | Select-Object -Skip ($lastHttpLine.Index) `
        | Select-Object -First ($endOfHeadersLine.Index - $lastHttpLine.Index) `
        | Select-Object -ExpandProperty Content `
        | ForEach-Object {
            $headerName, $headerValue = $_.Split(':')
            if (!$headerName) {
                continue
            }
            if ($null -ne $headerValue) {
                $headerValue = $headerValue.Trim()
            }
            if (!$webResponse.Headers.ContainsKey($headerName)) {
                $webResponse.Headers[$headerName] = [string[]] $headerValue
            } else {
                $webResponse.Headers[$headerName] += $headerValue
            }
        }

        # Construct the Web Exception
        if ($combinedErrorMessage) {
            $webException = New-WebException `
                -Response $webResponse `
                -Message $combinedErrorMessage

            if ($ErrorActionPreference -eq 'Stop') {
                throw $webException
            } else {
                Write-Error $webException
            }
        }

        # Return the response
        return $webResponse
    }
}

Set-Alias -Name Invoke-WebRequestCurl -Value Invoke-CurlWebRequest
