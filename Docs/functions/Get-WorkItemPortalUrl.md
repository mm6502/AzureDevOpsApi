---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-WorkItemPortalUrl

## SYNOPSIS
Work items loaded as revision (e.g.
due to the AsOf parameter)
do not contain a link for editing on the portal.
For these we
need to assemble the link.

## SYNTAX

### FromId (Default)
```
Get-WorkItemPortalUrl [-CollectionUri <Object>] [-Project <Object>] [-WorkItem] <Object>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### FromPipeline
```
Get-WorkItemPortalUrl -InputObject <Object> [-ProgressAction <ActionPreference>] [<CommonParameters>]
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
{{ Fill CollectionUri Description }}

```yaml
Type: Object
Parameter Sets: FromId
Aliases: Collection, Uri

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
{{ Fill InputObject Description }}

```yaml
Type: Object
Parameter Sets: FromPipeline
Aliases:

Required: True
Position: Named
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
Name or identifier of a project in the $Collection.
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: FromId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkItem
Work item loaded from API or its id.
In case of id, relies on $Collection and $Project to construct the url.

```yaml
Type: Object
Parameter Sets: FromId
Aliases: WorkItemUrl, Url, Id

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
