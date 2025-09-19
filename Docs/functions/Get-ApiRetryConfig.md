---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-ApiRetryConfig

## SYNOPSIS
Gets the current global retry configuration for Azure DevOps API calls.

## SYNTAX

```
Get-ApiRetryConfig [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function returns the current global retry configuration that is used
as default for all Azure DevOps API calls.

## EXAMPLES

### EXAMPLE 1
```
$config = Get-ApiRetryConfig
```

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
