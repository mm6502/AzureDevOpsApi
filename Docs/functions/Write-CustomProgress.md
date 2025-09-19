---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Write-CustomProgress

## SYNOPSIS
Reports progress with item count and percent complete.

## SYNTAX

### Collection
```
Write-CustomProgress [-Activity <Object>] [-Status <Object>] [-ParentId <Int32>] [-Id <Int32>]
 [-AllItems <Object>] [-CurrentItem <Object>] [-NoPercent] [-NoCount] [-NoProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Count
```
Write-CustomProgress [-Activity <Object>] [-Status <Object>] [-ParentId <Int32>] [-Id <Int32>] [-Count <Int32>]
 [-Index <Int32>] [-NoPercent] [-NoCount] [-NoProgress] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
$list1 = @(1, 2, 3)
$list2 = @('a', 'b', 'c')
```

foreach ($i in $list1) {

    Write-CustomProgress \`
        -Activity "A$($i)" \`
        -Status "S$($i)" \`
        -AllItems $list1 \`
        -Current $i

    foreach ($j in $list2) {

        Write-CustomProgress \`
            -Activity "B$($j)" \`
            -Status "T$($j)" \`
            -AllItems $list2 \`
            -ParentId 1 \`
            -Current $j \`

        Start-Sleep -Milliseconds 200
    }
}

## PARAMETERS

### -Activity
Activity description.

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

### -AllItems
Collection items to process.

```yaml
Type: Object
Parameter Sets: Collection
Aliases: Items

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count
Total number of items to process.

```yaml
Type: Int32
Parameter Sets: Count
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -CurrentItem
Current item being processed.

```yaml
Type: Object
Parameter Sets: Collection
Aliases: Current

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Current Activity ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Index
Current item index.

```yaml
Type: Int32
Parameter Sets: Count
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoCount
If $true, suppress showing item count.

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

### -NoPercent
If $true, suppress showing percent complete.

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

### -NoProgress
{{ Fill NoProgress Description }}

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

### -ParentId
Parent Activity ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -1
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

### -Status
Activity status.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
