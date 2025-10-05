---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Sync-TcmTestCaseFromRemote

## SYNOPSIS
Pulls test case(s) from Azure DevOps to local YAML files.

## SYNTAX

```
Sync-TcmTestCaseFromRemote [[-Id] <String>] [[-OutputPath] <String>] [[-TestCasesRoot] <String>] [-Force]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
When called with -Id (numeric), treats Id as an Azure DevOps Work Item ID.
The corresponding local YAML file will be updated or created.
When -Id is omitted, the
cmdlet pulls all test cases that have remote changes by scanning local YAML files.

## EXAMPLES

### EXAMPLE 1
```
# Pull a single work item and create/update the local YAML file
Sync-TcmTestCaseFromRemote -Id 12345
```

### EXAMPLE 2
```
# Pull all test cases with remote changes
Sync-TcmTestCaseFromRemote
```

## PARAMETERS

### -Force
Force pull even if there are local changes (overwrite local).

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

### -Id
The Azure DevOps Work Item ID to pull (numeric).
If omitted, pulls all
test cases that need updating.

```yaml
Type: String
Parameter Sets: (All)
Aliases: WorkItemId

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Relative path where to create the test case file (used when pulling a
Work Item as a new test case file).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### -TestCasesRoot
Root directory for test cases.
If not specified, uses the default TestCases directory.

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

## OUTPUTS

## NOTES

## RELATED LINKS
