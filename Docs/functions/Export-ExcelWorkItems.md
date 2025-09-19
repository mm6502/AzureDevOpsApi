---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Export-ExcelWorkItems

## SYNOPSIS
Exports work items to an Excel worksheet.

## SYNTAX

```
Export-ExcelWorkItems [-ExportData] <Object> [-ExcelPackage <Object>] [-Styles <Object>]
 [-WorksheetName <Object>] [-Filter <ScriptBlock>] [-IncludeProperties <Object>] [-ExcludeProperties <Object>]
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

### -ExcelPackage
Package to add the worksheet to.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: WorkBook, Excel, Package

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeProperties
List of patterns for properties to exclude.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @( )
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportData
Export data prepared by ConvertTo-ExportData.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Data

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Scriptblock filter for $ExportData.WorkItems to be included on this worksheet.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: { $true }
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeProperties
List of patterns for properties to include.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @( '*' )
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

### -Styles
Style properties for different cell types.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorksheetName
Name of the worksheet to create.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: WorkItems
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
