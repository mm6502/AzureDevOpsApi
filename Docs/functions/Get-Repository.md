---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-Repository

## SYNOPSIS
Returns a repository.

## SYNTAX

```
Get-Repository [-Repository] <Object> [[-CollectionUri] <Object>] [[-Project] <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns a repository.

## EXAMPLES

### EXAMPLE 1
```
# All items represent the same repository
# Assuming project was accessed previously
Get-Repository -Repository @(
    'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/repositories/zvjs_feoo'
    'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo'
    'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed'
    'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed'
)
```

### EXAMPLE 2
```
In case the project was not accessed previously, ApiCredentials must be specified:
Get-Repository `
    -CollectionUri 'https://dev-tfs/tfs/internal_projects/' `
    -Project 'zvjs' `
    -Repository 'zvjs_feoo' `
    -ApiCredential $credential
```

## PARAMETERS

### -CollectionUri
Url for project collection on Azure DevOps server instance.
Can be ommitted if $CollectionUri was previously accessed via this API.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

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
Project name, identifier, full project URI, or object with any one
these properties.
Can be ommitted if $Project was previously accessed via this API (will be extracted from the $ArtifactUri).
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository
{{ Fill Repository Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
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
