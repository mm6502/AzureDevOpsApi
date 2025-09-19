Add-Type -AssemblyName System.Net.Http

function New-WebException {

    <#
        .SYNOPSIS
            Creates a new web exception object with a custom status code, reason phrase, and message.

        .DESCRIPTION
            The `New-WebException` function creates a new web exception object with a custom status code,
            reason phrase, and message. The exception can be used to represent errors that occur when
            making web requests.

        .PARAMETER StatusCode
            The HTTP status code for the exception.

        .PARAMETER ReasonPhrase
            The reason phrase for the HTTP status code.

        .PARAMETER Message
            The message to include in the exception.

        .PARAMETER Content
            The content to include in the exception.

        .PARAMETER ContentType
            The content type of the exception content.

        .PARAMETER Legacy
            Indicates whether to create a legacy `System.Net.WebException` object for PowerShell 5.1
            or a `Microsoft.PowerShell.Commands.HttpResponseException` object for PowerShell 7 and later.

        .OUTPUTS
            System.Management.Automation.ErrorRecord
            The web exception object.
#>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Default')]
        $StatusCode = 404,
        [Parameter(ParameterSetName = 'Default')]
        $ReasonPhrase = "Not Found",
        [Parameter(ParameterSetName = 'Default')]
        $Content = "{ message: ""$($Message)"" }",
        [Parameter(ParameterSetName = 'Default')]
        $ContentType = 'application/json',
        [Parameter(ParameterSetName = 'Response')]
        $Response,
        $Message = 'Requested object does not exist.',
        [Switch] $Legacy
    )

    if ((Get-PSVersion) -lt 6) {
        if ($Legacy.IsPresent -or $Legacy -ne $true) {
            $Legacy = $true
        }
    }

    if (!$Response) {
        $responseObj = [System.Net.Http.HttpResponseMessage]::new($StatusCode)
        $responseObj.ReasonPhrase = $ReasonPhrase
        $responseObj.Content = [System.Net.Http.StringContent]::new($Content)
        $mediaTypeHeaderValue = [System.Net.Http.Headers.MediaTypeHeaderValue]::new($ContentType)
        $responseObj.Content.Headers.ContentType = $mediaTypeHeaderValue
    } elseif (-not ($Response -is [System.Net.Http.HttpResponseMessage])) {
        $responseObj = [System.Net.Http.HttpResponseMessage]::new($Response.StatusCode)
        $responseObj.ReasonPhrase = $Response.ReasonPhrase
        $responseObj.Content = [System.Net.Http.StringContent]::new($Response.Content)
        $mediaTypeHeaderValue = [System.Net.Http.Headers.MediaTypeHeaderValue]::new($Response.ContentType)
        $responseObj.Content.Headers.ContentType = $mediaTypeHeaderValue
    }

    if ($Legacy -or ((Get-PSVersion) -lt 6)) {
        # PowerShell 5.1
        # Original exception type is System.Net.WebException,
        # but I can not find a way instantiate it
        $exception = [System.Exception]::new(
            "The remote server returned an error: $statusCode ($($responseObj.ReasonPhrase))."
        )
    } else {
        # PowerShell 7+
        $exception = [Microsoft.PowerShell.Commands.HttpResponseException]::new(
            "The remote server returned an error: $statusCode ($($responseObj.ReasonPhrase)).", $responseObj
        )
    }

    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidResult
    $errorRecord = [Management.Automation.ErrorRecord]::new($exception, $null, $errorCategory, $responseObj)
    $errorRecord.ErrorDetails = $Content

    return $errorRecord
}
