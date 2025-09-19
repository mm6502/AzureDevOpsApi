---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Add-WorkItemToReleaseNotesDataAddToQueue

## SYNOPSIS
Adds a new item to the download list as well as data for the Release Notes.

## SYNTAX

### Relation
```
Add-WorkItemToReleaseNotesDataAddToQueue -Queue <ArrayList> -ReleaseNotesData <Hashtable>
 -RelationDescriptors <Object> -ReleaseNotesDataItem <Object> -Relation <Object>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Reason
```
Add-WorkItemToReleaseNotesDataAddToQueue -Queue <ArrayList> -ReleaseNotesData <Hashtable>
 -RelationDescriptors <Object> -TargetWorkItemUrl <String> -Reason <Object>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -Queue
List of data to download.

```yaml
Type: ArrayList
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Reason
The reason for including the target work item in the data for Release Notes.

```yaml
Type: Object
Parameter Sets: Reason
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Relation
{{ Fill Relation Description }}

```yaml
Type: Object
Parameter Sets: Relation
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelationDescriptors
List of descriptors of relationships between work items.
Defacto configuration of how relationships are crawled when adding data to release notes.
The default value is the return value of the Get-DefaultWorkItemRelationDescriptorsList function.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseNotesData
List of release notes data to which loaded data should be added.
The data type is hashtable, where the key is \[string\] WorkItemId and the
value is PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
(for info see function New-ReleaseNotesDataItem)

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseNotesDataItem
{{ Fill ReleaseNotesDataItem Description }}

```yaml
Type: Object
Parameter Sets: Relation
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetWorkItemUrl
Url of the work item to which the tracked relationship points.

```yaml
Type: String
Parameter Sets: Reason
Aliases:

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

### PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem
## NOTES

## RELATED LINKS
