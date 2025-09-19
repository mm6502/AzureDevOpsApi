---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Update-PatchDocumentTags

## SYNOPSIS
Updates tags in a JSON Patch document.

## SYNTAX

```
Update-PatchDocumentTags [[-PatchDocument] <Object>] [[-Tags] <String[]>] [[-Add] <String[]>]
 [[-Remove] <String[]>] [-UseRegexPatterns] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Updates tags in a JSON Patch document.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Add
Tags to add to the work item.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: AddTags, ToAdd

Required: False
Position: 3
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -PatchDocument
{{ Fill PatchDocument Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Document

Required: False
Position: 1
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

### -Remove
Tags to remove from the work item.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: RemoveTags, ToRemove

Required: False
Position: 4
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
Tags to set on the the work item.
If specified,
overrides any existing tags on the work item.
Accepts array of strings.
Any of given string may be tags joined with semicolons
(as stored on Azure DevOps Server).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseRegexPatterns
Flag, whether to use regex patterns to match tags.
If specified, $Remove are treated as regex patterns.
Otherwise $Remove are treated as like patterns.
Default is false.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
