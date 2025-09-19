---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-WorkItemRelationDescriptor

## SYNOPSIS
Creates a new link descriptor between work items -
object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.

## SYNTAX

```
New-WorkItemRelationDescriptor [-Relation] <String> [[-FollowFrom] <String[]>] [[-NameOnSource] <String>]
 [-NameOnTarget] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -FollowFrom
List of types of work items on which this type of link is to be tracked.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -NameOnSource
The name of the link on the source work item.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NameOnTarget
The name of the link on the target work item.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### -Relation
System link type as used in Azure DevOps.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject with PSTypeName 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.
### [PSCustomObject] @{
###     PSTypeName   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
###     Relation     = 'System.LinkTypes.Hierarchy-Reverse'
###     FollowFrom   = @('Task','Bug','Requirement')
###     NameOnSource = 'Child'
###     NameOnTarget = 'Parent'
### }
### Relation     - System link type as used in Azure DevOps.
### FollowFrom   - List of types of work items on which this type of link is to be tracked.
### NameOnSource - The name of the link on the source work item.
### NameOnTarget - The name of the link on the target work item.
## NOTES

## RELATED LINKS
