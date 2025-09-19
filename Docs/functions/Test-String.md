---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Test-String

## SYNOPSIS
Tests strings for match include and exclude masks.
Case sensitivity can be controlled via the -CaseSensitive switch.

## SYNTAX

```
Test-String [-InputObject] <String[]> [[-Include] <String[]>] [[-Exclude] <String[]>] [-CaseSensitive]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Tests strings for match include and exclude masks.
Case sensitivity can be controlled via the -CaseSensitive switch.

## EXAMPLES

### EXAMPLE 1
```
$inputs = @('abc', 'bcd', 'cde', 'def')
$inlude = @('*d*')
$exclude = @('*e*')
$result = $inputs | Where-Object { $_ | Test-String -Exclude $exclude -Include $inlude }
$result # -> @('bcd')
```

## PARAMETERS

### -CaseSensitive
Switch to control case sensitivity of the filters.
Default is to be case insensitive.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude
The strings to exclude.
Default is to exclude none.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
The strings to include.
Default is to include all.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('*')
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
The array of strings to filter.

```yaml
Type: String[]
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
### System.Boolean[]
## NOTES
Regex implementation is approximately 8x faster than double filtering.
Tested on a 100_000 element array of strings.
Regex implementation took ~10s.
Filtering implementation took ~80s.

## RELATED LINKS
