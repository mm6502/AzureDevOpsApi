---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Reset-WorkItemRelationDescriptorsList

## SYNOPSIS
Resets the configuration file to the default work item relationship descriptors.

## SYNTAX

```
Reset-WorkItemRelationDescriptorsList [-Default] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -Default
If specified, removes the existing configuration file.

On the next Get-WorkItemRelationDescriptorsList call, the default values
returned by Get-DefaultWorkItemRelationDescriptorsList will be loaded
into cache and returned to caller.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Permanent, Persistent

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Overwrites the existing configuration file with default values.

## RELATED LINKS
