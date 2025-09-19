---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Invoke-ApiListPaged

## SYNOPSIS
Calls web API returning paged list of records.
For example to list all PullRequests for a project.

## SYNTAX

```
Invoke-ApiListPaged [-ApiCredential <PSObject>] [-ApiVersion <Object>] -Uri <Object> [-Body <Object>]
 [-Method <Object>] [-AsHashTable] [-PageSize <Object>] [-Top <Object>] [-Skip <Object>] [-Activity <Object>]
 [-RetryCount <Int32>] [-RetryDelay <Double>] [-DisableRetry] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Calls web API returning paged list of records.
If both $Top and $Skip are not specified, iterates the request with increasing
$Skip by $Top on each iteration, until records are no longer returned.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Activity
{{ Fill Activity Description }}

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

### -ApiCredential
Credential to use for authentication.
If not specified,
$global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiVersion
Requested version of Azure DevOps API.
If not specified, $global:AzureDevOpsApi_ApiVersion (set by Set-AzureDevopsVariables) is used.

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

### -AsHashTable
If specified, deserializes the JSON response to a hashtable, instead of standard \[PSObject\].

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

### -Body
Object to POST as a request.

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

### -DisableRetry
Disables retry logic completely.

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

### -Method
The HTTP method to use.
If not specified, it is decided according to
whether the Body parameter is given.
If not, GET is used, otherwise POST.

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

### -PageSize
Count of records per page.
Used when function should iterate through the records.
If not specified, 100 is used, because for many API functions that is the maximum
allowed by Azure DevOps.

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

### -RetryCount
The maximum number of retry attempts for transient failures. Default is 3.

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

### -RetryDelay
The base delay in seconds between retry attempts. Default is 1 second.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Top
Count of records per page.
If not specified, 100 is used.

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

### -Uri
Address of the service including query parameters.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
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
