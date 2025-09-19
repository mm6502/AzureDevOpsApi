---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Find-ApiCredential

## SYNOPSIS
Finds an API credential in the cache.

## SYNTAX

```
Find-ApiCredential [-CollectionUri] <String> [[-Project] <String>] [-PreventFallback]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Finds an API credential in the cache.

If the credential is not found, the function will try to find the default credentials, if any.
If the credential is not found, the function will return $null.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CollectionUri
The URI of the Azure DevOps collection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreventFallback
If set, the function will not try to find the default credentials, if any.

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
The name of the Azure DevOps project.

```yaml
Type: String
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
