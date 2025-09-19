---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Resolve-ApiProject

## SYNOPSIS
Finds a project in the global cache.

## SYNTAX

```
Resolve-ApiProject [[-Project] <Object>] [[-CollectionUri] <Object>] [[-Patterns] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Finds a project in the global cache based on the provided parameters.
The function supports finding a project by any combination of the following parameters:
- ProjectUri
- CollectionUri + ProjectUri
- CollectionUri + ProjectId
- CollectionUri + ProjectName

## EXAMPLES

### EXAMPLE 1
```
Resolve-ApiProject -CollectionUri 'https://dev.azure.com/myorg' -Project 'MyProject'
Finds a project with the name 'MyProject' in the collection 'https://dev.azure.com/myorg'.
```

### EXAMPLE 2
```
Resolve-ApiProject -CollectionUri 'https://dev.azure.com/myorg' -Project 'ab1c2d3e-4f56-7890-abcd-ef0123456789'
Finds a project with the ID 'ab1c2d3e-4f56-7890-abcd-ef0123456789' in the collection 'https://dev.azure.com/myorg'.
```

### EXAMPLE 3
```
Resolve-ApiProject -ProjectUri 'https://dev.azure.com/myorg/MyProject'
Finds a project with the URI 'https://dev.azure.com/myorg/MyProject'.
```

## PARAMETERS

### -CollectionUri
The URI of the project collection.

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
Position: 3
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
The project can be an actual Project object, a string that contains the URI of the project,
Name or Identifier of the project.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
