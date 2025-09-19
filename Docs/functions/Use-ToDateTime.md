---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Use-ToDateTime

## SYNOPSIS
Gets the ToDateTime to use for given Azure DevOps collection URI.

## SYNTAX

```
Use-ToDateTime [[-Value] <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets the ToDateTime to use for given Azure DevOps collection URI.
If the ToDateTime is not given, will use the current date & time in UTC.

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

### -Value
{{ Fill Value Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: To, ToDateTime, ToDate, ToTime, DateTime, DateTimeTo, Date, DateTo, Time, TimeTo

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [DateTime]
### Date & time of the time period we want to search in UTC.
## NOTES

## RELATED LINKS
