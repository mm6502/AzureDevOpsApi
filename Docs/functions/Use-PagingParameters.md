---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Use-PagingParameters

## SYNOPSIS
Returns paging parameters for iterating through a list of records.

## SYNTAX

```
Use-PagingParameters [[-Top] <Object>] [[-Skip] <Object>] [[-PageSize] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Returns paging parameters for iterating through a list of records.

## EXAMPLES

### EXAMPLE 1
```
$paging = Use-PagingParameters -Top 100 -Skip 0
$paging.Top
$paging.Skip
$paging.ShouldPage
```

## PARAMETERS

### -PageSize
Count of records per page.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -Top
Count of records per page.

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

### -Skip
Count of records to skip before returning the $Top count of records.

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
