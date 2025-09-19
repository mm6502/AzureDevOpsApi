---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Set-ProjectProperty

## SYNOPSIS
Sets properties of given project.

## SYNTAX

### Parameter (Default)
```
Set-ProjectProperty [[-Project] <Object>] [-CollectionUri <Object>] [-Property <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Pipeline
```
Set-ProjectProperty [-Project] <Object> [-CollectionUri <Object>] [-Property <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -CollectionUri
Url for project collection on Azure DevOps server instance.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: (All)
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

### -Project
Project to get.
Can be passed as a name, identifier, full project URI, or object with any one
these properties.
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: Parameter
Aliases: Uri

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: Pipeline
Aliases: Uri

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Property
Dictionary, HashTable, or PSCustomObject of properties to set.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Properties, Value, Values

Required: False
Position: Named
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/get-project-properties?view=azure-devops-rest-5.0&tabs=HTTP

## RELATED LINKS
