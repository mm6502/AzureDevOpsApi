---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Add-ReleaseNotesDataItemRelation

## SYNOPSIS
Add a link between two given Work Items.

## SYNTAX

```
Add-ReleaseNotesDataItemRelation [-ReleaseNotesData] <Hashtable> [-SourceWorkItemUrl] <String>
 [-TargetWorkItemUrl] <String> [[-RelationName] <Object>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
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

### -RelationName
The name of the link.
(e.g.
Parent)

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseNotesData
Data for release notes.
The data type is hashtable, where the key is \[string\] WorkItemId and the
value is PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
(for info see function New-ReleaseNotesDataItem)

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceWorkItemUrl
Url of the work item from which the link originates.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetWorkItemUrl
Url of the work item the link targets.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItemRelation
## NOTES

## RELATED LINKS
