---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Test-ApiCredential

## SYNOPSIS
Tests Azure DevOps API credentials to verify they are valid and have required permissions.

## SYNTAX

### Default (Default)
```
Test-ApiCredential [-CollectionUri <Object>] [-ApiCredential <PSObject>] [-Quiet]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Token
```
Test-ApiCredential [-CollectionUri <Object>] -Token <String> [-Quiet] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Validates API credentials by making a test call to Azure DevOps.
Returns detailed information
about the connection status, authenticated user, and permissions.

This function is useful for:
- Troubleshooting authentication issues (401, 403 errors)
- Verifying PAT tokens before use
- Checking token expiration
- Validating permissions

## EXAMPLES

### EXAMPLE 1
```
Test-ApiCredential
```

Tests the currently configured credentials (from Set-ApiVariables).

### EXAMPLE 2
```
Test-ApiCredential -Token "your-pat-token-here" -CollectionUri "https://dev.azure.com/myorg"
```

Tests a specific PAT token against a collection.

### EXAMPLE 3
```
if (Test-ApiCredential -Quiet) {
    Write-Host "✅ Credentials are valid"
} else {
    Write-Host "❌ Credentials are invalid"
}
```

Quick validation in a script.

### EXAMPLE 4
```
$result = Test-ApiCredential
if ($result.Success) {
    Write-Host "✅ Connected as: $($result.User.displayName)"
    Write-Host "   Email: $($result.User.mailAddress)"
} else {
    Write-Host "❌ Failed: $($result.ErrorMessage)"
}
```

Detailed validation with user information.

## PARAMETERS

### -ApiCredential
The credentials to test.
If not specified, $global:AzureDevOpsApi_ApiCredential (set by Set-ApiVariables) is used.

```yaml
Type: PSObject
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionUri
The URI of the Azure DevOps collection to test against.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-ApiVariables) is used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Uri

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
If specified, returns only $true or $false instead of detailed information.
Useful for scripting.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token
Personal Access Token (PAT) to test.
If specified, creates a temporary ApiCredential for testing.

```yaml
Type: String
Parameter Sets: Token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject with the following properties:
### - Success: $true if credentials are valid
### - StatusCode: HTTP status code (200 = success, 401 = unauthorized, 403 = forbidden)
### - User: Authenticated user information (if successful)
### - CollectionUri: The collection URI tested
### - ErrorMessage: Error details (if failed)
### When -Quiet is specified, returns $true or $false.
## NOTES

## RELATED LINKS

[Add-ApiCredential]()

[Set-ApiVariables]()

