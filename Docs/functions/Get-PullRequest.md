---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-PullRequest

## SYNOPSIS
Returns a pull request.

## SYNTAX

```
Get-PullRequest [-PullRequest] <Object> [[-CollectionUri] <Object>] [[-Project] <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns a pull request.

## EXAMPLES

### EXAMPLE 1
```
# All items represent the same PullRequest
# Assuming project was accessed previously
Get-PullRequest -PullRequest @(
    'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357'
    'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/pullrequests/8357'
    'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/pullrequests/8357'
    'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo/pullrequests/8357'
    'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed/pullrequests/8357'
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

### -PullRequest
Pull request to load.
Valid inputs:
- Pull request artifact uri
  'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357'
- Pull request url
  'https://dev-tfs/tfs/internal_projects/zvjs/_apis/git/pullrequests/8357'
  'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/pullrequests/8357'
  'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/zvjs_feoo/pullrequests/8357'
  'https://dev-tfs/tfs/internal_projects/9d7a1154-1315-433e-96e5-11f160256a1d/_apis/git/repositories/96e0832a-94a2-4c0c-887e-48b8f3d2e7ed/pullrequests/8357'
- Pull request id, must specify CollectionUri, otherwise default will be used
  8357

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
