---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-WorkItemRefsListByChangeset

## SYNOPSIS
Return the list of work item ids referenced in given changesets.

## SYNTAX

### Parameters (Default)
```
Get-WorkItemRefsListByChangeset [-Project <Object>] [-CollectionUri <Object>] [-DateFrom <Object>]
 [-DateTo <Object>] [-TargetBranch <String>] [-CreatedBy <Object>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Pipeline
```
Get-WorkItemRefsListByChangeset [-Changeset <Object>] [-Project <Object>] [-CollectionUri <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Return the list of work item ids referenced in given changesets.
Combines consecutive calls to Get-ChangesetsList and Get-ChangesetAssociatedWorkItemIds.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CollectionUri
Url for project collection on Azure DevOps server instance.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedBy
Author of the commits.
API searches for partial match on system name and display name.
For '*Mra*' will find 'Michal Mracka' (system name 'DITEC\mracka')
For 'M*a' will find 'Michal Mracka' (system name 'DITEC\mracka')

```yaml
Type: Object
Parameter Sets: Parameters
Aliases: Author

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateFrom
Lists commits created on or after specified date time.

```yaml
Type: Object
Parameter Sets: Parameters
Aliases: FromDate, From

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
Lists commits created on or before specified date time.

```yaml
Type: Object
Parameter Sets: Parameters
Aliases: ToDate, To

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Changeset
{{ Fill Changeset Description }}

```yaml
Type: Object
Parameter Sets: Pipeline
Aliases: InputObject

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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
Project to get.
Can be passed as a name, identifier, full project URI, or object with any one
these properties.
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetBranch
Name of a branch to search.

```yaml
Type: String
Parameter Sets: Parameters
Aliases: Branch

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

### System.String[]
## NOTES

## RELATED LINKS
