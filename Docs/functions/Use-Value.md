---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Use-Value

## SYNOPSIS
Returns the first non-empty value.

## SYNTAX

### Parameters (Default)
```
Use-Value -ValueA <Object> -ValueB <Object> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### PipeLine
```
Use-Value -ValueA <Object> -ValueB <Object> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns the first non-empty value.
If both values are empty, returns null.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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

### -ValueA
First value to check.

```yaml
Type: Object
Parameter Sets: Parameters
Aliases: A, InputObject

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: PipeLine
Aliases: A, InputObject

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValueB
Second value to check.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: B

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

## NOTES

## RELATED LINKS
