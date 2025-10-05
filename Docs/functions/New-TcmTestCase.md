---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-TcmTestCase

## SYNOPSIS
Creates a new test case YAML file with the specified properties.

## SYNTAX

```
New-TcmTestCase [-Id] <String> [-Title] <String> [[-Description] <String>] [[-AreaPath] <String>]
 [[-IterationPath] <String>] [[-Priority] <Int32>] [[-Tags] <String[]>] [[-Steps] <Hashtable[]>]
 [[-OutputPath] <String>] [[-TestCasesRoot] <String>] [-Force] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a new test case in YAML format that can be synchronized with Azure DevOps.
The test case is saved to a file in a folder structure based on the area path.
If no configuration exists, you must first create a .tcm-config.yaml file.

The function validates input parameters, creates the necessary directory structure,
and generates a properly formatted YAML file containing all test case metadata.

## EXAMPLES

### EXAMPLE 1
```
New-TcmTestCase -Id "TC001" -Title "Login Test" -Description "Test user login functionality"
```

Creates a basic test case with default values for area path, iteration path, and priority.

### EXAMPLE 2
```
$steps = @(
    @{ action = "Navigate to login page"; expectedResult = "Login form displayed" },
    @{ action = "Enter valid credentials"; expectedResult = "User logged in successfully" },
    @{ action = "Click logout button"; expectedResult = "User logged out" }
)
PS C:\> New-TcmTestCase -Id "TC002" -Title "Login Flow" -Steps $steps -AreaPath "MyProject\Authentication"
```

Creates a test case with multiple test steps and a specific area path.

### EXAMPLE 3
```
New-TcmTestCase -Id "TC003" -Title "API Test" -OutputPath "api/TC003-api-test.yaml" -TestCasesRoot "C:\MyTestCases" -Force
```

Creates a test case in a specific file path within a custom test cases root directory,
overwriting any existing file.

## PARAMETERS

### -AreaPath
The area path for the test case in Azure DevOps (e.g., "Project\Area\Component").
If not specified, uses the default from the configuration file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
A description of what the test case validates.
Defaults to empty string if not specified.

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

### -Force
Overwrites the test case file if it already exists without prompting.

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
The unique identifier for the test case (e.g., "TC001").
This will be used as the filename and must contain only letters, numbers, underscores, and hyphens.
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IterationPath
The iteration path for the test case in Azure DevOps.
If not specified, uses the default from the configuration file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
The relative path where the test case file should be created.
If not specified, the file is created in a folder structure based on the area path.
Should include the filename with .yaml extension.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority
The priority of the test case (1-4, where 1 is highest priority).
If not specified, uses the default from the configuration file.
Valid values are 1, 2, 3, or 4.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 0
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

### -Steps
An array of test steps.
Each step should be a hashtable with 'action' and 'expectedResult' properties.
Additional properties like 'attachments' are supported but not required.
If not specified, a default empty step will be created.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of tags to associate with the test case.
Tags help categorize and filter test cases in Azure DevOps.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -TestCasesRoot
The root directory for test cases.
If not specified, uses the current directory or the directory containing the .tcm-config.yaml file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
The title of the test case.
This parameter is mandatory.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. This function does not accept pipeline input.
## OUTPUTS

### System.Collections.Hashtable
### Returns a hashtable containing the created test case data with the following structure:
### - testCase: The test case metadata
### - metadata: File path and creation information
## NOTES
- Requires a .tcm-config.yaml file in the test cases root directory or a parent directory.
- The test case ID must be unique within the test cases root.
- Test steps are optional but recommended for comprehensive test cases.
- The created YAML file can be synchronized with Azure DevOps using Sync-TcmTestCase.
- Invalid characters in the ID will cause the function to throw an error.

## RELATED LINKS

[Sync-TcmTestCase]()

[New-TcmConfig]()

[Get-TcmTestCase]()

