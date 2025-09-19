---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Add-WorkItemToReleaseNotesData

## SYNOPSIS
Adds the given work items to the release notes data.

## SYNTAX

```
Add-WorkItemToReleaseNotesData [[-CollectionUri] <Object>] [[-Project] <Object>]
 [[-ReleaseNotesData] <Hashtable>] [[-AsOf] <Object>] [-WorkItem] <Object> [[-Reason] <String>]
 [[-Recursive] <Boolean>] [[-RelationDescriptors] <Object>] [[-Filter] <ScriptBlock>]
 [[-ActivityParentId] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -ActivityParentId
ID of the parent activity.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsOf
Reference date and time.
Takes objects in the state they were in at this date and time.
If not specified, the current date and time will be used.
I.e.
including all changes today, up to the moment the query is run.

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

### -CollectionUri
{{ Fill CollectionUri Description }}

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

### -Filter
Filter to be used on acquired work items.
Included are only passing ones.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
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

### -Project
{{ Fill Project Description }}

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

### -Reason
Reason for adding the work item to the release notes data.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recursive
If $true, it goes through the relationships between work items and adds new ones
according to the RelationDescriptors.
If $false, it will only add work items given by the WorkItemId parameter.
The default value is $true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: True
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

Required: False
Position: 8
Default value: @(Get-DefaultWorkItemRelationDescriptorsList)
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

Required: False
Position: 3
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkItem
Work item to be added.
May be specified as
- WorkItem object
- WorkItem Ref
- WorkItem Url
- WorkItem ID (if also $Project is specified)

```yaml
Type: Object
Parameter Sets: (All)
Aliases: WorkItems, Items

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
