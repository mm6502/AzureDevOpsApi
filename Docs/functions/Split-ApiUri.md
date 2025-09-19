---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Split-ApiUri

## SYNOPSIS
Splits the given URI of an Azure DevOps collection into the collection URI and the project name.

## SYNTAX

```
Split-ApiUri [[-Uri] <String>] [[-Patterns] <String[]>] [-AsHashTable] [-UseOnlyProvidedPatterns]
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

### -AsHashTable
If set, the output will be a HashTable instead of a PSCustomObject.

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

### -Patterns
The regex patterns to use for splitting the URI.
Captured groups are returned as properties of the output object.

```yaml
Type: String[]
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

### -Uri
The Uri of some Azure DevOps collection related object.
The Uri is formatted with Format-Uri.
before being processed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseOnlyProvidedPatterns
If set, only the provided patterns will be used for splitting the URI.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Only, OnlyProvided, OnlyPatterns, OnlyProvidedPatterns

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A hashtable or PSCustomObject with the captured groups as keys.
## NOTES

## RELATED LINKS
