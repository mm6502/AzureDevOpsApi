---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# ConvertTo-ExportData

## SYNOPSIS
Converts set of ReleaseNotesDataItems to ExportData.

## SYNTAX

### List (Default)
```
ConvertTo-ExportData [-ItemsList] <Object[]> [-CollectionUri <Object>] [-Project <Object>] [-DateFrom <Object>]
 [-DateTo <Object>] [-AsOf <Object>] [-ByUser <Object>] [-TargetBranch <Object>] [-TrunkBranch <Object>]
 [-ReleaseBranch <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### HashTable
```
ConvertTo-ExportData [-ItemsTable] <Hashtable> [-CollectionUri <Object>] [-Project <Object>]
 [-DateFrom <Object>] [-DateTo <Object>] [-AsOf <Object>] [-ByUser <Object>] [-TargetBranch <Object>]
 [-TrunkBranch <Object>] [-ReleaseBranch <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -AsOf
Reference date and time in UTC.
Objects are listed in the state they were in at this date and time.

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

### -ByUser
Only pull requests created by given users will be returned.

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

### -CollectionUri
Url for project collection on Azure DevOps server instance.
If not specified, $global:AzureDevOpsApi_Collection (set by Set-AzureDevopsVariables) is used.

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

### -DateFrom
Starting date & time of the time period.
If not specified, $global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables) is used.

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

### -DateTo
Ending date & time of the time period.
If not specified, \[DateTime\]::UTCNow is used.

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

### -ItemsList
List of ReleaseNotesDataItems.

```yaml
Type: Object[]
Parameter Sets: List
Aliases: Items

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ItemsTable
Hashtable of ReleaseNotesDataItems, key is WorkItemId as string.

```yaml
Type: Hashtable
Parameter Sets: HashTable
Aliases:

Required: True
Position: 2
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
Name or identifier of a project in the $Collection.
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

### -ReleaseBranch
The release branch of TFVC repositories.

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
The target branch of pull requests.

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

### -TrunkBranch
The trunk branch of TFVC repositories.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSTypeNames.AzureDevOpsApi.ExportData
## NOTES

## RELATED LINKS
