---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Resolve-TcmTestCaseConflict

## SYNOPSIS
Resolves synchronization conflicts for test cases.

## SYNTAX

```
Resolve-TcmTestCaseConflict [-Id] <String> [-Strategy] <String> [[-TestCasesRoot] <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Resolves conflicts that occur when both local and remote versions of a test case have changes.
Provides multiple resolution strategies and supports interactive conflict resolution.

Conflicts occur when content has changed in both the local YAML file and the Azure DevOps work item
since the last synchronization.
This function helps choose which version to keep or merge changes.

## EXAMPLES

### EXAMPLE 1
```
Resolve-TcmTestCaseConflict -Id "TC001" -Strategy LocalWins
```

Resolves the conflict for TC001 by keeping the local version.

### EXAMPLE 2
```
Resolve-TcmTestCaseConflict -Id "TC001" -Strategy RemoteWins
```

Resolves the conflict for TC001 by using the Azure DevOps version.

### EXAMPLE 3
```
Resolve-TcmTestCaseConflict -Id "TC001" -Strategy LatestWins
```

Resolves the conflict by choosing the version that was modified most recently.

### EXAMPLE 4
```
"TC001", "TC002" | Resolve-TcmTestCaseConflict -Strategy Manual
```

Interactively resolves conflicts for multiple test cases.

## PARAMETERS

### -Id
The local identifier of the test case with the conflict (e.g., "TC001").
Accepts pipeline input by value or property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### -Strategy
The conflict resolution strategy to use:
- Manual: Interactive resolution allowing user to choose (default)
- LocalWins: Use the local version, overwrite remote changes
- RemoteWins: Use the remote version, overwrite local changes
- LatestWins: Use the version with the most recent modification timestamp

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TestCasesRoot
Root directory containing test case YAML files.
If not specified, uses the current directory or searches parent directories for .tcm-config.yaml.

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

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### Accepts test case IDs from the pipeline.
## OUTPUTS

### None. Displays resolution results to the console.
## NOTES
- Manual strategy will prompt for user input to choose resolution approach.
- LatestWins compares file modification timestamps vs. work item changed dates.
- Resolution is atomic per test case to prevent inconsistent states.
- After resolution, the test case will be marked as synced.

## RELATED LINKS

[Sync-TcmTestCase]()

[Get-TcmTestCaseSyncStatus]()

