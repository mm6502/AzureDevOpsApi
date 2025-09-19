---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Use-ApiCredential

## SYNOPSIS
Determines the API credential to use for given CollectionUri.
If none is provided, tries to find usable credentials
in cached credentials (added by Add-ApiCredential) or default
credential by Set-ApiVariables.

## SYNTAX

```
Use-ApiCredential [[-ApiCredential] <PSObject>] [[-CollectionUri] <Object>] [[-Project] <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Determines the API credential to use for given CollectionUri.
If none is provided, tries to find usable credentials
in cached credentials (added by Add-ApiCredential) or default
credential by Set-ApiVariables.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ApiCredential
The API credential to use.
If not provided, will try to find one
in cache or default credential.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionUri
The collection Uri of target API endpoint.
Determined by lookup in registered
collections (added by Add-ApiCollection or by Set-ApiVariables).

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
The target project from given CollectionUri to use.
Used to lookup
ApiCredential if not given.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
