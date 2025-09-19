---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-ApiProjectConnection

## SYNOPSIS
Creates a connection object to a project in Azure DevOps.

## SYNTAX

```
Get-ApiProjectConnection [[-Project] <Object>] [[-CollectionUri] <Object>] [[-ApiCredential] <PSObject>]
 [[-Patterns] <String[]>] [-AllowFallback] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates a connection object to a project in Azure DevOps.

The $Project parameter can be a project object, a project name, a project ID,
or a project URI.

This function will try to find the project in the cache first.
If the project is not found in the cache, it will try to construct it from given parameters.

The returned connection object has the following properties:
- CollectionUri: The URI of the collection the project belongs to.
- ApiVersion: The API version to use for the connection.
- ApiCredential: The API credential to use for the connection.
- ProjectUri: The URI of the project.
- ProjectId: The ID of the project.
- ProjectName: The name of the project.
- ProjectBaseUri: The base URI for the project's resources.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AllowFallback
If set, the function will try to construct the project connection.
If the project could not be determined, or is not found in the cache,
it will try to return a collection connection.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: WithFallback, Fallback

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiCredential
The API credential to use for the connection.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionUri
The URI of the collection the project belongs to.

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

### -Patterns
A list of additional patterns to use to extract the Project and CollectionUri
when the Project parameter is an Uri.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
The project to create a connection for.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
