---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-ApiCredential

## SYNOPSIS
Creates an object that contains credentials for the Azure DevOps API.

## SYNTAX

```
New-ApiCredential [[-Authorization] <String>] [[-Token] <Object>] [[-Credential] <PSCredential>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function is used to create an object that contains credentials for the Azure DevOps API.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Authorization
The authorization used to authenticate to the Azure DevOps API.
Possible values are:
- $null or '' - autodetect the type of authorization, based on the value of the $Token and $Credential parameters.
- 'Default' - Use the default network credentials.
- 'Basic' - Use given $Credential.
- 'PAT' - Use a Personal Access Token.
- 'Bearer' - Use a Bearer token.
- 'OAuth' - Use a OAuth token.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The credential used to authenticate to the Azure DevOps API.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### -Token
The token used to authenticate to the Azure DevOps API.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSTypeNames.AzureDevOpsApi.ApiCredential
## NOTES

## RELATED LINKS
