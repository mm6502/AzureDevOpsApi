---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Submit-PullRequests

## SYNOPSIS
Submits pull requests for the specified repositories and branches.

## SYNTAX

```
Submit-PullRequests [[-Project] <Object>] [[-CollectionUri] <Object>] [[-IncludeRepository] <Object>]
 [[-ExcludeRepository] <Object>] [-SourceBranch] <Object> [-TargetBranch] <Object> [-AutoComplete] [-PassThru]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Submit-PullRequests function submits pull requests for the specified repositories and branches.
It gets a list of repositories, filters them, and creates a pull request for each one if needed.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AutoComplete
Whether the pull request should be autocompleted.

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

### -CollectionUri
Url for project collection on Azure DevOps server instance.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

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

### -ExcludeRepository
Names or masks of the git repositories to NOT make the pullrequests for.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Exclude

Required: False
Position: 4
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeRepository
Names or masks of the git repositories to make the pullrequests for.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Include

Required: False
Position: 3
Default value: @('*')
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies whether the function should return objects to the pipeline.
When you use the -PassThru switch, the function returns an object
that you can work with further.
Without -PassThru, the function may execute silently
without returning any data.

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
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceBranch
Name of the base branch.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetBranch
Name of the target branch.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
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
