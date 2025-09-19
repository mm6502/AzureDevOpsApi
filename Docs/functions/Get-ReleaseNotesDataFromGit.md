---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-ReleaseNotesDataFromGit

## SYNOPSIS
Gets release notes data from Git based project.

## SYNTAX

```
Get-ReleaseNotesDataFromGit [[-CollectionUri] <Object>] [[-Project] <Object>] [[-DateFrom] <DateTime>]
 [[-DateTo] <DateTime>] [[-AsOf] <DateTime>] [[-ByUser] <Object>] [[-TargetRepository] <Object>]
 [[-TargetBranch] <Object>] [-FromCommits] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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
Gets the Work Items as they were at this date and time.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ByUser
User(s) whose PullRequests will be used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionUri
Url for project collection on Azure DevOps server instance.
Can be ommitted if $CollectionUri was previously accessed via this API.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

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

### -DateFrom
Starting date for the considered PullRequests.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: FromDate, From

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
Ending date for the considered PullRequests.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: ToDate, To

Required: False
Position: 4
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
Project name, identifier, full project URI, or object with any one
these properties.
Can be ommitted if $Project was previously accessed via this API (will be extracted from the $ArtifactUri).
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

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

### -TargetBranch
Target branch for PullRequests.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Branch

Required: False
Position: 8
Default value: Main
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetRepository
List of target repositories.
Can be passed as a name or identifier.
If not specified, all repositories will be used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Repository

Required: False
Position: 7
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
