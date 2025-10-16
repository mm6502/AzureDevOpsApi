function Test-ApiCredential {

    <#
        .SYNOPSIS
            Tests Azure DevOps API credentials to verify they are valid and have required permissions.

        .DESCRIPTION
            Validates API credentials by making a test call to Azure DevOps. Returns detailed information
            about the connection status, authenticated user, and permissions.

            This function is useful for:
            - Troubleshooting authentication issues (401, 403 errors)
            - Verifying PAT tokens before use
            - Checking token expiration
            - Validating permissions

        .PARAMETER CollectionUri
            The URI of the Azure DevOps collection to test against.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-ApiVariables) is used.

        .PARAMETER ApiCredential
            The credentials to test.
            If not specified, $global:AzureDevOpsApi_ApiCredential (set by Set-ApiVariables) is used.

        .PARAMETER Token
            Personal Access Token (PAT) to test.
            If specified, creates a temporary ApiCredential for testing.

        .PARAMETER Quiet
            If specified, returns only $true or $false instead of detailed information.
            Useful for scripting.

        .OUTPUTS
            PSCustomObject with the following properties:
            - Success: $true if credentials are valid
            - StatusCode: HTTP status code (200 = success, 401 = unauthorized, 403 = forbidden)
            - User: Authenticated user information (if successful)
            - CollectionUri: The collection URI tested
            - ErrorMessage: Error details (if failed)

            When -Quiet is specified, returns $true or $false.

        .EXAMPLE
            Test-ApiCredential

            Tests the currently configured credentials (from Set-ApiVariables).

        .EXAMPLE
            Test-ApiCredential -Token "your-pat-token-here" -CollectionUri "https://dev.azure.com/myorg"

            Tests a specific PAT token against a collection.

        .EXAMPLE
            if (Test-ApiCredential -Quiet) {
                Write-Host "✅ Credentials are valid"
            } else {
                Write-Host "❌ Credentials are invalid"
            }

            Quick validation in a script.

        .EXAMPLE
            $result = Test-ApiCredential
            if ($result.Success) {
                Write-Host "✅ Connected as: $($result.User.displayName)"
                Write-Host "   Email: $($result.User.mailAddress)"
            } else {
                Write-Host "❌ Failed: $($result.ErrorMessage)"
            }

            Detailed validation with user information.

        .LINK
            Add-ApiCredential
        .LINK
            Set-ApiVariables
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([PSCustomObject])]
    [OutputType([bool])]
    param(
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Token')]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Uri')]
        $CollectionUri,

        [Parameter(ParameterSetName = 'Default')]
        [AllowNull()]
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiCredential')]
        [PSCustomObject] $ApiCredential,

        [Parameter(ParameterSetName = 'Token', Mandatory)]
        [string] $Token,

        [switch] $Quiet
    )

    process {

        # If Token is provided, create temporary ApiCredential
        if ($PSCmdlet.ParameterSetName -eq 'Token') {
            $ApiCredential = New-ApiCredential -Token $Token -Authorization 'PAT'
        }

        # Build result object
        $result = [PSCustomObject]@{
            PSTypeName    = 'PSTypeNames.AzureDevOpsApi.TestCredentialResult'
            Success       = $false
            StatusCode    = $null
            User          = $null
            CollectionUri = $CollectionUri
            ErrorMessage  = $null
        }

        try {
            # Attempt to get current user (simple API call that requires authentication)
            $user = Get-CurrentUser `
                -CollectionUri $CollectionUri `
                -ApiCredential $ApiCredential

            # If we got here, credentials are valid
            $result.Success = $true
            $result.StatusCode = 200
            $result.User = $user

            if (-not $Quiet) {
                Write-Verbose "✅ Credentials are valid"
                Write-Verbose "   User: $($user.displayName) ($($user.mailAddress))"
                Write-Verbose "   Collection: $($result.CollectionUri)"
            }

        }
        catch {
            # Parse error information
            $result.Success = $false
            $result.ErrorMessage = $_.Exception.Message

            # Try to extract HTTP status code
            if ($_.Exception.Response) {
                $result.StatusCode = [int]$_.Exception.Response.StatusCode
            }
            elseif ($_.Exception.Message -match '\((\d{3})\)') {
                $result.StatusCode = [int]$matches[1]
            }

            # Provide helpful error messages
            if (-not $Quiet) {
                switch ($result.StatusCode) {
                    401 {
                        Write-Warning "❌ 401 Unauthorized: Credentials are invalid or expired"
                        Write-Warning "   Check that your PAT token is set correctly and hasn't expired"
                    }
                    403 {
                        Write-Warning "❌ 403 Forbidden: Credentials lack required permissions"
                        Write-Warning "   Ensure your PAT has at least 'Read' access to the organization"
                    }
                    default {
                        Write-Warning "❌ Connection failed: $($result.ErrorMessage)"
                    }
                }
            }

            Write-Verbose "Error details: $($_.Exception | Format-List * | Out-String)"
        }

        # Return result
        if ($Quiet) {
            return $result.Success
        }
        else {
            return $result
        }
    }
}
