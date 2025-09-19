---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Export-ReleaseNotesFromGitToExcel

## SYNOPSIS
Runs compilation of release notes data from Git based project.

## SYNTAX

```
Export-ReleaseNotesFromGitToExcel [[-CollectionUri] <Object>] [[-Project] <Object>] [[-DateFrom] <DateTime>]
 [[-DateTo] <DateTime>] [[-AsOf] <DateTime>] [[-ByUser] <Object>] [[-TargetRepository] <Object>]
 [[-TargetBranch] <Object>] [[-Path] <Object>] [[-TimeZone] <String>] [-FromCommits] [-Show] [-PassThru]
 [-UseConstantFileName] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -PassThru
Flag, whether return the generated file.

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

### -Path
Path or filename for the exported data to be saved to.
If not specified, the file will be saved to the current directory.
If points to a directory and $UseConstantFileName is specified,
the file will be named "ReleaseNotes.xlsx", otherwise the filename
will be "ReleaseNotes_$Project_$CreatedOnDateTime.xlsx".

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: .\
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

### -Show
Flag, whether open the exported document.

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

### -TimeZone
All times from AzureDevOps API are in UTC.
Parameter determines the time zone all date times will be converted to.

Uses .net TimeZoneInfo class to resolve and calculate the date times.

Possible values are:
IANA style zone ids, f.e.
"Europe/Bratislava"
Windows style zone ids, f.e.
"Central Europe Standard Time"

Default value is "Central Europe Standard Time".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: UTC
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseConstantFileName
Flag, whether to use constant file name.
If $Path is a directory, the file will be named "ReleaseNotes.xlsx"
Ignored if $Path is a filename.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
