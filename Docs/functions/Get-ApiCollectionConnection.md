---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-ApiCollectionConnection

## SYNOPSIS
Returns new connection object.

Used to determine the correct url for the collection and the correct api version to use
for given Url.

Properties of the returned object are:
- CollectionUri: Url for project collection on Azure DevOps server instance.
- ApiCredential: Default ApiCredential object to use for authentication on given CollectionUri.
- ApiVersion: Version of Azure DevOps API to use.

## SYNTAX

```
Get-ApiCollectionConnection [[-Uri] <Object>] [[-CollectionUri] <Object>] [[-ApiCredential] <PSObject>]
 [[-ApiVersion] <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -ApiCredential
ApiCredential object to use for authentication on given CollectionUri.
If not specified, $global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiVersion
Version of Azure DevOps API to use.
If not specified, $global:AzureDevOpsApi_ApiVersion (set by Set-AzureDevopsVariables) is used.

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

### -CollectionUri
Url for project collection on Azure DevOps server instance.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

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

### -Uri
Uri to Rest Api endpoint on Azure DevOps server instance.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSTypeNames.AzureDevOpsApi.ApiCollectionConnection
## NOTES

## RELATED LINKS
