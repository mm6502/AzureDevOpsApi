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

### All (Default)
```
Get-TcmTestCase [-TestCasesRoot <String>] [-IncludeMetadata] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ById
```
Get-TcmTestCase [[-Id] <String>] [-TestCasesRoot <String>] [-IncludeMetadata]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ByPath
```
Get-TcmTestCase [-Path <String>] [-TestCasesRoot <String>] [-IncludeMetadata]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves test case information from local YAML files.
Can return a single test case by ID or path,
or return all test cases in the repository.
Optionally includes synchronization metadata.

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

### EXAMPLE 4
```
Get-TcmTestCase -IncludeMetadata | Select-Object @{Name="ID";Expression={$_.testCase.id}}, @{Name="Title";Expression={$_.testCase.title}}, @{Name="File";Expression={$_.metadata.filePath}}
```

Gets all test cases with metadata and displays ID, title, and file path.

## PARAMETERS

### -Id
The local identifier of a specific test case to retrieve (e.g., "TC001").
When specified, returns only the matching test case.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeMetadata
Includes synchronization metadata in the output, such as file paths, modification dates,
and sync status information.

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
The relative or absolute path to a specific test case YAML file.
When specified, loads and returns data from that specific file.

```yaml
Type: String
Parameter Sets: ByPath
Aliases:

Required: False
Position: Named
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

### None. This function does not accept pipeline input.
## OUTPUTS

### System.Collections.Hashtable[]
### Returns an array of hashtables, each containing:
### - testCase: The test case metadata and content
### - metadata: File information and sync status (if -IncludeMetadata specified)
## NOTES
- Searches recursively through the test cases root directory for .yaml files.
- Test case IDs are extracted from filenames (e.g., "TC001-test-name.yaml" has ID "TC001").
- Invalid YAML files are skipped with warnings.
- Use -IncludeMetadata to get file paths and sync information.

## RELATED LINKS

[New-TcmTestCase]()

[Sync-TcmTestCase]()

[New-TcmConfig]()

