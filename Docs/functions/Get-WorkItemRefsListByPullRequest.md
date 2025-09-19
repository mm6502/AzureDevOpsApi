---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-WorkItemRefsListByPullRequest

## SYNOPSIS
Return the list of work item ids referenced in given pull requests.

## SYNTAX

### Parameters (Default)
```
Get-WorkItemRefsListByPullRequest [-Project <Object>] [-CollectionUri <Object>] [-DateFrom <Object>]
 [-DateTo <Object>] [-TargetRepository <Object>] [-TargetBranch <String>] [-CreatedBy <Object>] [-FromCommits]
 [-ActivityParentId <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Pipeline
```
Get-WorkItemRefsListByPullRequest [-PullRequest <Object>] [-Project <Object>] [-CollectionUri <Object>]
 [-FromCommits] [-ActivityParentId <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Return the list of work item ids referenced in given pull requests.
Combines consecutive calls to Get-PullRequestsList and Get-PullRequestAssociatedWorkItemIds.

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
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

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
Only pull requests created by given users will be returned.
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
Starting date & time of the time period we want to search.
If not specified, $global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables) is used.

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
Ending date & time of the time period we want to search.
If not specified, \[DateTime\]::UTCNow is used.

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

### -FromCommits
If specified, work items associated with commits in the pull request will be also returned.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: IncludeFromCommits

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

### -PullRequest
List of pull requests to process.

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

### -TargetBranch
Target branch in the target repository.

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

### -TargetRepository
List of target repositories.
Can be passed as a name or identifier.
If not specified, all repositories will be used.

```yaml
Type: Object
Parameter Sets: Parameters
Aliases: Repository

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

## RELATED LINKS
