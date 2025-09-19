---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Add-QueryParameter

## SYNOPSIS
Adds or sets a query parameter in the given URI.

## SYNTAX

```
Add-QueryParameter [-Uri] <Object> [-Parameters] <Object> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function takes a URI and a hashtable of parameters, and adds or sets the specified
parameters in the query string of the URI.

## EXAMPLES

### EXAMPLE 1
```
$uri = "https://example.com/xyz/?a=1&b=2"
$params = @{ c = 3; d = 4 }
$newUri = Add-QueryParameter -Uri $uri -Parameters $params
# $newUri will be "https://example.com/xyz?a=1&b=2&c=3&d=4"
```

## PARAMETERS

### -Parameters
A hashtable or PSCustomObject of key-value pairs representing the query parameters to add or set.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
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
The URI to add or set the query parameters in.

```yaml
Type: Object
Parameter Sets: (All)
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
