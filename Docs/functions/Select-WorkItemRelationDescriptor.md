---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Select-WorkItemRelationDescriptor

## SYNOPSIS
Return the link descriptor between work items -
object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.
For information, see the New-WorkItemRelationDescriptor function.

## SYNTAX

```
Select-WorkItemRelationDescriptor [[-RelationDescriptors] <Object>] [[-WorkItem] <Object>]
 [[-Relation] <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -Relation
One of the bindings on the given work item object.
Eg: $WorkItem.relations\[0\]

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

### -RelationDescriptors
List of descriptors of relationships between work items.
Defacto configuration of how work items are crawled when adding data to release notes.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkItem
Work item whose bindings we are evaluating (source).

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

### Object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.
### For information, see the New-Work Item Relation Descriptor function.
## NOTES

## RELATED LINKS
