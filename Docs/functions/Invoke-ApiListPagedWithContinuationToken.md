---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Invoke-ApiListPagedWithContinuationToken

## SYNOPSIS
Calls web API returning paged list of records using continuation token pagination.

## SYNTAX

```
Invoke-ApiListPagedWithContinuationToken [-ApiCredential <PSObject>] [-ApiVersion <Object>] -Uri <Object>
 [-Body <Object>] [-Method <Object>] [-ContinuationTokenParameterName <String>] [-AsHashTable]
 [-Activity <Object>] [-RetryCount <Int32>] [-RetryDelay <Double>] [-DisableRetry]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Calls web API returning paged list of records using continuation token pagination.
This is used for APIs that use the x-ms-continuationtoken header for pagination
instead of $skip and $top query parameters.

The function iterates through all pages by following the continuation token
returned in the response header until no more pages are available.

## EXAMPLES

### EXAMPLE 1
```
$uri = "https://dev.azure.com/myorg/myproject/_apis/testplan/Plans/123/suites"
$results = Invoke-ApiListPagedWithContinuationToken -Uri $uri
```

### EXAMPLE 2
```
$uri = "https://dev.azure.com/myorg/myproject/_apis/testplan/Plans/123/suites"
$results = Invoke-ApiListPagedWithContinuationToken `
    -Uri $uri `
    -ContinuationTokenParameterName 'continuationToken'
```

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

### -ContinuationTokenParameterName
The name of the query parameter to use for the continuation token.
Default is 'continuationToken'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: ContinuationToken
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
The maximum number of retry attempts for transient failures.
Default is 3.

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
The base delay in seconds between retry attempts.
Default is 1 second.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function is designed for Azure DevOps APIs that use continuation token pagination,
such as the Test Plans API (v7.1+).

## RELATED LINKS
