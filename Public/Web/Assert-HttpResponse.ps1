
function Assert-HttpResponse {

    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord] $ErrorRecord
    )

    # Handle common network problems
    $baseException = $ErrorRecord.Exception.GetBaseException()

    # We want to read api error json response from Http exception
    # Powershell 5 does not have [Microsoft.PowerShell.Commands.HttpResponseException]
    $continue = $false

    if ($baseException -is [System.Net.WebException]) {
        $continue = $true
    }

    if ((Get-PSVersion) -gt 5) {
        if ($baseException -is [Microsoft.PowerShell.Commands.HttpResponseException]) {
            $continue = $true
        }
    }

    # All other exceptions, just throw as they are
    if (!$continue) {
        throw $ErrorRecord
    }

    # Try to parse the response as json (if server responded with json error)
    # (and remove the whitespace first...)
    try {
        $errorResponse = $ErrorRecord.ErrorDetails.Message `
        | ConvertFrom-JsonCustom
    } catch {
        $errorResponse = $ErrorRecord.ErrorDetails.Message
    }

    # If the response is json, use the message property of the json object as error message

    # Get error details for Create and Update errors;
    # they will have attribute validation errors
    if ($baseException.StatusCode -eq [System.Net.HttpStatusCode]::BadRequest) {
        $errorDetails = $errorResponse.customProperties.RuleValidationErrors.errorMessage
    }

    # Get error details for other errors
    if (!$errorDetails) {
        if ($errorResponse.message) {
            $errorDetails = $errorResponse.message
        } else {
            $errorDetails = $ErrorRecord.Exception.Message
        }
    }

    # Add the error response to the error details
    $newException = [System.Net.WebException]::new($errorDetails, $baseException)

    # Create new error record, with the error message from the json object
    $newErrorRecord = [System.Management.Automation.ErrorRecord]::new($ErrorRecord, $newException)
    $newErrorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($errorDetails)

    # Throw the error record
    # Note: NOT using WriteTerminatingError(), because it does not respect $ErrorActionPreference
    #       values 'SilentlyContinue' (writes the error to console anyway)
    #       and 'Stop' (does not stop execution of the script)
    # Note: NOT using Write-Error, because it does not set '$?' to $false
    throw $newErrorRecord

    # if ($ErrorActionPreference -eq 'Stop') {
    #     throw $newErrorRecord
    # } else {
    #     $PSCmdlet.WriteError($newErrorRecord)
    # }
}