---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-PatchDocumentCreate

## SYNOPSIS
Create a JSON Patch document for creating work item.
The document can be used with New-WorkItem to create work item.

## SYNTAX

```
New-PatchDocumentCreate [[-SourceWorkItem] <Object>] [[-WorkItemType] <Object>] [[-Properties] <String[]>]
 [[-Data] <Hashtable>] [-CopyTags] [[-TagsToAdd] <String[]>] [[-TagsToRemove] <String[]>] [-AsChild]
 [-CopyRelations] [[-Callback] <ScriptBlock>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -AsChild
Flag, whether to create as child of the source work item.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Callback
Callback function to process the patch document before it is sent to the server.
Takes single parameter - the patch document.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CopyRelations
Flag, whether to copy relations from the source work item.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CopyTags
Flag, whether to copy tags from the source work item.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Data
Additional data to add to the patch document.
Default is empty hashtable.
If specified, overrides the value set by $Properties.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

### -Properties
Properties to copy from source work item.

Default list is:
- 'System.WorkItemType',
- 'System.Title',
- 'System.Description',
- 'System.Tags',
- 'System.AreaPath',
- 'System.IterationPath',
- 'Microsoft.VSTS.Common.Priority'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceWorkItem
Source work item to copy properties from.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Source

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TagsToAdd
Tags to add to the work item.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TagsToRemove
Tags to remove from the work item.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkItemType
Type of work item to create.
If specified, overrides the value set by $Properties and $Data.
Default is 'Task'.

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

### PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument
## NOTES
https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/create?view=azure-devops-rest-5.0&tabs=HTTP

## RELATED LINKS
