---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Set-ApiVariables

## SYNOPSIS
Set commonly used parameters for Azure DevOps API calls:
$global:AzureDevOpsApi_DefaultFromDate
$global:AzureDevOpsApi_ApiVersion
$global:AzureDevOpsApi_CollectionUri
$global:AzureDevOpsApi_Project
$global:AzureDevOpsApi_Token

## SYNTAX

### Default (Default)
```
Set-ApiVariables [-ApiVersion <Object>] [-CollectionUri <Object>] [-Project <Object>]
 [-ApiCredential <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### OldStyleCredential
```
Set-ApiVariables [-ApiVersion <Object>] [-CollectionUri <Object>] [-Project <Object>] [-Authorization <Object>]
 [-Credential <PSCredential>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### OldStyleToken
```
Set-ApiVariables [-ApiVersion <Object>] [-CollectionUri <Object>] [-Project <Object>] [-Authorization <Object>]
 [-Token <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ApiCredential
The credential to use for Azure DevOps API calls.
If not provided, the
result of New-ApiCredential will be used (default netowrk credentials on Windows).

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

### -ApiVersion
Azure DevOps API version number.
Default is '5.0'.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5.0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Authorization
Obsolete. Only for compatibility with v0.0.*.
Authorization type to use.

Possible Values are:
- `Default` - Default authorization (uses -UseDefaultCredentials)
- `PersonalAccessToken` - Personal Access Token
- `PAT` - Personal Access Token (alias for PersonalAccessToken)
- `Bearer` - Bearer Token
- `Basic` - Basic authorization type

```yaml
Type: Object
Parameter Sets: OldStyleCredential, OldStyleToken
Aliases:

Required: False
Position: Named
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionUri
URL to a collection of projects on Azure DevOps.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Collection

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Obsolete. Only for compatibility with v0.0.*.
The credential to use for calling API in given $Collection,
when Authorization is set to `Basic`.

```yaml
Type: PSCredential
Parameter Sets: OldStyleCredential
Aliases:

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

### -Project
The name or identifier of the project in the given $CollectionUri.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token
Obsolete. Only for compatibility with v0.0.*.
The authorization token for calling API in given $Collection,
when Authorization is set to `Bearer`, `PAT` or `PersonalAccessToken`.

```yaml
Type: Object
Parameter Sets: OldStyleToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
