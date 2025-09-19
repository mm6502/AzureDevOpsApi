---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-CommitsList

## SYNOPSIS
Gets list of all commits meeting given criteria.

## SYNTAX

```
Get-CommitsList [[-Project] <Object>] [[-CollectionUri] <Object>] [[-Author] <Object>] [[-Repository] <Object>]
 [[-Branch] <Object>] [[-DateFrom] <Object>] [[-DateTo] <Object>] [-Simple]
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

### -Author
Author of the commits.
API searches for partial match on system name and display name.
For 'Mra' will find 'Michal Mracka'   (system name 'DITEC\mracka')
For '*Mra*' will find 'Michal Mracka' (system name 'DITEC\mracka')
For 'M*a' will find 'Michal Mracka'   (system name 'DITEC\mracka')

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

### -Branch
Name of a branch to search.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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

### -DateFrom
Lists commits created on or after specified date time.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: From, FromDate

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
Lists commits created on or before specified date time.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: To, ToDate

Required: False
Position: 7
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
Project to get.
Can be passed as a name, identifier, full project URI, or object with any one
these properties.
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

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

### -Repository
Name of the git repository to search.
Can use '*' as wildcard.
For '*POD' will find 'POD','EPOD'.
For 'P*D' will find 'PAD','POD'.

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

### -Simple
Flag, whether return raw data as returned from the server (when $false) or
adjusted for output to console (when $true).

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
https://learn.microsoft.com/en-us/rest/api/azure/devops/git/commits/get-commits?view=azure-devops-rest-5.0&tabs=HTTP

## RELATED LINKS
