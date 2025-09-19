---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Join-Uri

## SYNOPSIS
Joins the given base Uri with the given relative Uri.

## SYNTAX

```
Join-Uri [[-BaseUri] <Object>] [[-RelativeUri] <Object>] [-NoTrailingSlash] [[-Parameters] <Object>]
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

### -BaseUri
Base Uri to append to.
Example: https://dev.azure.com/MyOrganization/
Example: https://dev.azure.com/MyOrganization

```yaml
Type: Object
Parameter Sets: (All)
Aliases: CollectionUri

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoTrailingSlash
If specified, the trailing slash is removed from the Uri.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: RemoveTrailingSlash, LastSegment

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parameters
An optional hashtable or PSCustomObject of key-value pairs representing the query parameters to add or set.

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

### -RelativeUri
Relative Uri to append to the base Uri.
May be a collection of relative Uris.
Example: _apis/projects
Example: /_apis/projects
Example: _apis, projects

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

## NOTES

## RELATED LINKS
