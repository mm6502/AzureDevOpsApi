---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-Changeset

## SYNOPSIS
Returns a changeset.

## SYNTAX

```
Get-Changeset [-Changeset] <Object> [[-CollectionUri] <Object>] [[-Project] <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns a changeset.

## EXAMPLES

### EXAMPLE 1
```
# All items represent the same Changeset
# Assuming project was accessed previously
Get-Changeset -Changeset @(
  'https://dev-tfs/tfs/internal_projects/_apis/tfvc/changesets/182559'
  'https://dev-tfs/tfs/internal_projects/FS_TKD-TARIC/_apis/tfvc/changesets/182559'
  'https://dev-tfs/tfs/internal_projects/c0b54941-d244-45e8-8673-1eb18fc2abc9/_apis/tfvc/changesets/182559'
)
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

### -Changeset
Pull request to load.
Valid inputs:
- Changeset url
  'https://dev-tfs/tfs/internal_projects/_apis/tfvc/changesets/182559'
  'https://dev-tfs/tfs/internal_projects/FS_TKD-TARIC/_apis/tfvc/changesets/182559'
  'https://dev-tfs/tfs/internal_projects/c0b54941-d244-45e8-8673-1eb18fc2abc9/_apis/tfvc/changesets/182559'
- Changeset id, must specify CollectionUri, otherwise default will be used
  182559

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
Project name, identifier, full project URI, or object with any one these properties.
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
