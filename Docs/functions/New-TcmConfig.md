---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-TcmConfig

## SYNOPSIS
Creates a new TestCaseManagement configuration file (.tcm-config.yaml).

## SYNTAX

```
New-TcmConfig [[-CollectionUri] <String>] [[-Project] <String>] [[-Token] <String>] [[-OutputPath] <String>]
 [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates a configuration file that defines settings for TestCaseManagement operations.
The configuration includes Azure DevOps connection details, sync preferences, and default values.
This file is required for all TestCaseManagement operations.

The configuration file is created as .tcm-config.yaml in the specified directory
and contains settings for Azure DevOps connection, sync behavior, and test case defaults.

## EXAMPLES

### EXAMPLE 1
```
New-TcmConfig -CollectionUri "https://dev.azure.com/my-org" -Project "MyProject"
```

Creates a basic configuration file with environment variable placeholder for the PAT.

### EXAMPLE 2
```
New-TcmConfig -CollectionUri "my-org" -Project "MyProject" -Token "your-pat-here" -OutputPath "C:\TestCases" -Force
```

Creates a configuration file with explicit PAT in the specified directory, overwriting any existing file.

### EXAMPLE 3
```
New-TcmConfig -CollectionUri "https://dev.azure.com/my-org" -Project "MyProject" -OutputPath ".\TestCases\.tcm-config.yaml"
```

Creates the configuration file with a specific filename in the TestCases directory.

## PARAMETERS

### -CollectionUri
The Azure DevOps organization/collection URI (e.g., "https://dev.azure.com/my-org" or "my-org").
This is the base URL for your Azure DevOps organization.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrites an existing configuration file without prompting for confirmation.

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

### -OutputPath
The directory path where the .tcm-config.yaml file will be created.
If a full file path is provided, the directory containing the file will be used.
Defaults to the current working directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: $PWD.Path
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
The name of the Azure DevOps project where test cases will be synchronized.

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

### -Token
Azure DevOps Personal Access Token for authentication.
If not provided, the configuration will use an environment variable placeholder.
The token should have appropriate permissions for work item read/write operations.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. This function does not accept pipeline input.
## OUTPUTS

### System.String
### Returns the path to the created configuration file.
## NOTES
- The configuration file is required for all TestCaseManagement operations.
- Use environment variables for sensitive information like PATs in production.
- The file will be searched for starting from the current directory and moving up parent directories.
- Default sync settings can be modified by editing the generated YAML file.

## RELATED LINKS

[Get-TcmTestCaseConfig]()

[New-TcmTestCase]()

[Sync-TcmTestCase]()

