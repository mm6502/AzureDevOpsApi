---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Invoke-CustomWebRequest

## SYNOPSIS
Helper function for calling a web service.

## SYNTAX

```
Invoke-CustomWebRequest [[-ApiCredential] <PSObject>] [[-Uri] <Object>] [[-Body] <Object>] [[-Method] <Object>]
 [[-ContentType] <Object>] [[-Headers] <Hashtable>] [[-RetryCount] <Int32>] [[-RetryDelay] <Double>]
 [-DisableRetry] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function is used by the module to call web services.
It is not intended to be called directly.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ApiCredential
Credential to use for authentication.
If not specified,
$global:AzureDevOpsApi_ApiCredential (set by Set-AzureDevopsVariables) is used.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
Object that should be POSTed as request.

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

### -ContentType
The Content-Type header for the POST method.
Default is 'application/json'.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Application/json
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

### -Headers
{{ Fill Headers Description }}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
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
Position: 4
Default value: GET
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
Position: 7
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
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
Web service call address including query parameters.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
