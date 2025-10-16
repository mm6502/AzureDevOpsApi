---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Sync-TcmTestCase

## SYNOPSIS
Synchronizes test cases between local YAML files and Azure DevOps.

## SYNTAX

### Explicit (Default)
```
Sync-TcmTestCase [-InputObject <Object>] [-Direction <String>] [-TestCasesRoot <String>] [-Force]
 [-ConflictResolution <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### GitStyle
```
Sync-TcmTestCase [-InputObject <Object>] [-TestCasesRoot <String>] [-Push] [-Pull] [-Force]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Synchronizes test case data between local YAML files and Azure DevOps work items.
Supports bidirectional synchronization, push-only, and pull-only operations.
Automatically detects sync status and handles conflicts based on the specified resolution strategy.

The function compares content hashes to determine if local and remote versions differ,
and performs the appropriate sync operation based on the direction and conflict resolution settings.

### Parameter Sets

This function provides two parameter sets for different use cases:

**GitStyle (Recommended for interactive use):**
- Uses `-Push`, `-Pull`, and `-Force` switches
- Intuitive for users familiar with Git workflows
- Example: `Sync-TcmTestCase -Push`

**Explicit (Better for automation):**
- Uses `-Direction` parameter with values: ToRemote, FromRemote, Bidirectional
- Allows dynamic direction calculation at runtime
- Example: `Sync-TcmTestCase -Direction $direction`

## EXAMPLES

### EXAMPLE 1
```
Sync-TcmTestCase -InputObject "TC001"
```

Synchronizes test case TC001 bidirectionally using default settings.

### EXAMPLE 2
```
Get-TcmTestCase -Id "TC*" | Sync-TcmTestCase -Direction ToRemote
```

Gets all test cases matching "TC*" and pushes them to Azure DevOps.

### EXAMPLE 3
```
Sync-TcmTestCase -InputObject "authentication/TC001-login.yaml" -Direction FromRemote -ConflictResolution RemoteWins
```

Pulls the latest version from Azure DevOps for the specified file, using remote version in case of conflicts.

### EXAMPLE 4
```
Sync-TcmTestCase -WhatIf
```

Shows what sync operations would be performed without making any changes.

## PARAMETERS

### -ConflictResolution
How to handle conflicts when both local and remote versions have changes:
- Manual: Stop and require manual resolution (default)
- LocalWins: Use local version, overwrite remote
- RemoteWins: Use remote version, overwrite local
- LatestWins: Use the version with the most recent modification date

```yaml
Type: String
Parameter Sets: Explicit
Aliases:

Required: False
Position: Named
Default value: Manual
Accept pipeline input: False
Accept wildcard characters: False
```

### -Direction
Direction of synchronization:
- Bidirectional: Push local changes and pull remote changes (default)
- ToRemote: Only push local changes to Azure DevOps
- FromRemote: Only pull changes from Azure DevOps

```yaml
Type: String
Parameter Sets: Explicit
Aliases:

Required: False
Position: Named
Default value: Bidirectional
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
When used with -Push or -Pull, forces the sync by choosing the respective version in case of conflicts.

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

### -InputObject
The local test case to synchronize.
Accepts:
- Test case ID (string) - e.g., "TC001"
- File path (string) - relative or absolute path to YAML file
- Test case object (hashtable) - from Get-TcmTestCase
Accepts pipeline input by value or property name.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Path, Id, TestCaseId, WorkItemId

Required: False
Position: Named
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

### -Pull
Git-style switch to pull changes from Azure DevOps. Equivalent to -Direction FromRemote -ConflictResolution Manual. Use with -Force to set -ConflictResolution RemoteWins.

```yaml
Type: SwitchParameter
Parameter Sets: GitStyle
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Push
Git-style switch to push local changes to Azure DevOps. Equivalent to -Direction ToRemote -ConflictResolution Manual. Use with -Force to set -ConflictResolution LocalWins.

```yaml
Type: SwitchParameter
Parameter Sets: GitStyle
Aliases:

Required: False
Position: Named
Default value: False
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
Position: Named
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
Shows what would happen if the cmdlet runs without actually performing the sync operations.

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
### System.Collections.Hashtable
### Accepts test case IDs, file paths, or test case objects from the pipeline.
## OUTPUTS

### None. The function displays progress and results to the console.
## NOTES
- Requires a valid .tcm-config.yaml configuration file.
- Azure DevOps credentials must be configured for the target collection and project.
- Sync operations are atomic per test case to prevent partial updates.
- Use -WhatIf to preview changes before executing.
- Conflict resolution strategies only apply when both versions have changes.

## RELATED LINKS

[Get-TcmTestCase]()

[Resolve-TcmTestCaseConflict]()

[New-TcmConfig]()

