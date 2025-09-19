---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-PatchDocumentRelation

## SYNOPSIS
Adds a relation to a patch document.

## SYNTAX

```
New-PatchDocumentRelation [[-TargetWorkItem] <Object>] [[-RelationType] <Object>] [[-RelationName] <Object>]
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

### -RelationName
Relation name to add (from point of view of the PatchDocument).
User friendly name of the relation.
For example:
'Parent' for 'Parent' end of the Parent-Child relation.

Read as "I (work item being updated) have 'Parent' TargetWorkItem".
Read as "I (work item being updated) am 'Affected By' TargetWorkItem".
Read as "I (work item being updated) 'Tests' TargetWorkItem".

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

### -RelationType
Relation type to add (from point of view of the PatchDocument).
Fully qualified name of the relation type.
For example:
'System.LinkTypes.Hierarchy-Reverse' for 'Parent' end of the Parent-Child relation.

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

### -TargetWorkItem
Target work item of the relation,
Or Uri of the target work item of the relation.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Target, Uri, TargetUri

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

## NOTES
https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/update?view=azure-devops-rest-5.0&tabs=HTTP#add-a-link

## RELATED LINKS
