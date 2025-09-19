---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-SubscriptionsList

## SYNOPSIS
Returns list of service hook subscriptions from the specified project.

## SYNTAX

```
Get-SubscriptionsList [[-Project] <Object>] [[-CollectionUri] <Object>] [[-Top] <Object>] [[-Skip] <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns list of service hook subscriptions from the specified project in Azure DevOps.

## EXAMPLES

### EXAMPLE 1
```
Get-SubscriptionsList
```

Lists all subscriptions from all projects in the default collection.

### EXAMPLE 2
```
Get-SubscriptionsList -Project 'MyProject'
```

Lists all subscriptions from the specified project in the default collection.

### EXAMPLE 3
```
$projectsList | Get-SubscriptionsList
```

Lists all subscriptions from specified projects.

## PARAMETERS

### -CollectionUri
Url for project collection on Azure DevOps server instance.
If not specified and could not be determined from $Project,
$global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

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
Project to get subscriptions for.
Can be passed as a name, identifier, full project URI,
or object with any one of these properties.

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

### -Top
Count of records per page.

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

### -Skip
Count of records to skip before returning the $Top count of records.
If not specified, iterates the request with increasing $Skip by $Top,
while records are being returned.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
