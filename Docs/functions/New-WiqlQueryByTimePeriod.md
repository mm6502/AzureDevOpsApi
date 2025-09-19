---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-WiqlQueryByTimePeriod

## SYNOPSIS
Creates a WIQL query that returns all work items of the types given by the WorkItemTypes parameter,
which were switched to the Resolved state in the specified time frame and are in this state
at the query launch or the time specified with AsOf parameter.

## SYNTAX

```
New-WiqlQueryByTimePeriod [[-Project] <Object>] [[-WorkItemTypes] <String[]>] [[-WorkItemStates] <String[]>]
 [[-DateFrom] <Object>] [[-DateTo] <Object>] [[-AsOf] <Object>] [[-DateAttribute] <Object>]
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

### -AsOf
Reference date and time.
For the purposes of the WIQL query, it takes the objects
in the state they were in at this date and time.
If not specified, UTCNow is used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $DateTo
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateAttribute
Attribute name against which the date parameters will be compared.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: Microsoft.VSTS.Common.ResolvedDate
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateFrom
Start of the time interval we want to search.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Start, From, FromDate

Required: False
Position: 4
Default value: $global:AzureDevOpsApi_DefaultFromDate
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
End of the time interval we want to search.
If not specified, UTCNow is used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: End, To, ToDate

Required: False
Position: 5
Default value: [DateTime]::UtcNow
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

### -Project
Name or identifier of a project in the $Collection.
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $global:AzureDevOpsApi_Project
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkItemStates
{{ Fill WorkItemStates Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: WIStates, WIState, States, State

Required: False
Position: 3
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkItemTypes
List of types of work items that interest us.
Default value is @('Requirement', 'Bug').

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: WITypes, WIType, Types, Type

Required: False
Position: 2
Default value: @('Requirement', 'Bug')
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/wiql/query-by-wiql?view=azure-devops-rest-5.0&tabs=HTTP

## RELATED LINKS
