---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Format-Uri

## SYNOPSIS
Normalizes the given Uri of an Azure DevOps Rest Api.
End all uris with a '/' character.
Adds or sets query parameters.

## SYNTAX

### Parameters (Default)
```
Format-Uri [-Uri] <Object> [[-Parameters] <Object>] [-NoTrailingSlash] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Pipeline
```
Format-Uri [-Uri] <Object> [-NoTrailingSlash] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function takes a Uri and a hashtable of parameters.
It normalizes the given Uri and adds or sets the specified query parameters in the
query string of the Uri.
End all Uri paths with a '/' character.

## EXAMPLES

### EXAMPLE 1
```
$uri = "https://example.com?a=1&b=2"
$params = @{ c = 3; d = 4 }
$newUri = Add-QueryParameter -Uri $uri -Parameters $params
```

$newUri will be "https://example.com?a=1&b=2&c=3&d=4"

## PARAMETERS

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
Parameter Sets: Parameters
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

### -Uri
The Uri to to normalize and add or set the query parameters in.

```yaml
Type: Object
Parameter Sets: Parameters
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: Pipeline
Aliases:

Required: True
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
