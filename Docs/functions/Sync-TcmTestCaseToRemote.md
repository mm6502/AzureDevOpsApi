---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Sync-TcmTestCaseToRemote

## SYNOPSIS
Pushes a local test case to Azure DevOps.

## SYNTAX

```
Sync-TcmTestCaseToRemote [-InputObject] <Object> [[-TestCasesRoot] <String>] [-Force]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Sync-TcmTestCaseToRemote -InputObject "TC001"
```

### EXAMPLE 2
```
Sync-TcmTestCaseToRemote -InputObject "TestCases/area/TC001.yaml"
```

### EXAMPLE 3
```
Get-ChildItem "TestCases/*.yaml" | Resolve-TcmTestCaseFilePathInput | Sync-TcmTestCaseToRemote
```

### EXAMPLE 4
```
Sync-TcmTestCaseToRemote -InputObject "TC001" -Force
```

## PARAMETERS

### -Force
Force push even if there are remote changes (overwrite remote).

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
The test case to push.
Can be a test case ID (string), file path (string), or resolved object from Resolve-TcmTestCaseFilePathInput.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Path, FilePath, Id, TestCaseId, WorkItemId

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

### -TestCasesRoot
Root directory for test cases.
If not specified, uses the default TestCases directory.

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
