---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-TcmTestCase

## SYNOPSIS
Retrieves test case data from YAML files.

## SYNTAX

```
Get-TcmTestCase [[-InputObject] <Object>] [-TestCasesRoot <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves test case information from local YAML files.
Can return a single test case by ID or path,
or return all test cases in the repository.

The function searches for YAML files in the test cases root directory and parses them
into structured PowerShell objects for further processing or display.

## EXAMPLES

### EXAMPLE 1
```
Get-TcmTestCase -Id "TC001"
```

Retrieves the test case with ID "TC001" and returns its data.

### EXAMPLE 2
```
Get-TcmTestCase -Path "authentication/TC001-login.yaml"
```

Loads the test case from the specified file path.

### EXAMPLE 3
```
Get-TcmTestCase | Where-Object { $_.testCase.state -eq "Design" }
```

Retrieves all test cases and filters for those in "Design" state.

## PARAMETERS

### -InputObject
Test case input from pipeline. Accepts:
- Test case ID (string) - e.g., "TC001"
- File path (string) - relative or absolute path to YAML file
- Test case object (hashtable) - from previous operations
Accepts pipeline input by value or property name.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Id, Path

Required: False
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
The root directory containing test case YAML files.
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Collections.Hashtable
### Accepts test case IDs, file paths, or test case objects from the pipeline.
## OUTPUTS

### PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended
### Returns objects that extend TcmTestCaseInput with test case data in the LocalData property.
### LocalData contains the parsed test case properties (id, title, state, etc.).
## NOTES
- Searches recursively through the test cases root directory for .yaml files.
- Test case IDs are extracted from filenames (e.g., "TC001-test-name.yaml" has ID "TC001").
- Invalid YAML files are skipped with warnings.

## RELATED LINKS

[New-TcmTestCase]()

[Sync-TcmTestCase]()

[New-TcmConfig]()

