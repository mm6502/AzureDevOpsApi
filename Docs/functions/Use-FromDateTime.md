---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Use-FromDateTime

## SYNOPSIS
Gets the FromDateTime to use for given Azure DevOps collection URI.

## SYNTAX

```
Use-FromDateTime [[-Value] <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets the FromDateTime to use for given Azure DevOps collection URI.
If the FromDateTime is not given, will use the default value from
$global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables).
If the FromDateTime is not determined, it will default to '2000-01-01T00:00:00Z'

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
Aliases: From, FromDateTime, FromDate, FromTime, DateTime, DateTimeFrom, Date, DateFrom, Time, TimeFrom

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
