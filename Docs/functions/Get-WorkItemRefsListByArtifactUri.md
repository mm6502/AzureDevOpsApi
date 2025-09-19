---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-WorkItemRefsListByArtifactUri

## SYNOPSIS
Gets list of work item references associated with given artifacts.

## SYNTAX

```
Get-WorkItemRefsListByArtifactUri [[-ArtifactUri] <Object>] [[-Project] <Object>] [[-CollectionUri] <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets list of work item references associated with given artifacts.

## EXAMPLES

### EXAMPLE 1
```
Get-WorkItemRefsListByArtifactUri `
    -ArtifactUri 'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357' `
    -CollectionUri 'https://dev-tfs/tfs/internal_projects'
```

id     url
--     ---
405200 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/405200

### EXAMPLE 2
```
# Assuming both projects are in the same collection and were accessed previously
Get-WorkItemRefsListByArtifactUri `
    -ArtifactUri `
    'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357',
    'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2fc5538a9c-ad60-426a-8898-b50a44ee9e72%2f7179',
    'vstfs:///Git/PullRequestId/5e62fde7-1b9d-40d1-b69c-787f9b7aaadb%2ffccd7d08-bf7c-4995-a1e5-60524f9aab20%2f8636'
```

id     url
--     ---
405200 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/405200
422660 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/422660

## PARAMETERS

### -ArtifactUri
List of Artifact Uris to query work items for.
All Artifact Uris must be from the same project collection.

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

### -CollectionUri
Url for project collection on Azure DevOps server instance.
Can be ommitted if $CollectionUri was previously accessed via this API.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### WorkItemRef object, deduplicated by url.
## NOTES
https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/artifact-uri-query/query?view=azure-devops-rest-6.0&tabs=HTTP

## RELATED LINKS
