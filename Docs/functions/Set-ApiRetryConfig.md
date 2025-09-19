---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Set-ApiRetryConfig

## SYNOPSIS
Configures global retry behavior for Azure DevOps API calls.

## SYNTAX

```
Set-ApiRetryConfig [[-RetryCount] <Int32>] [[-RetryDelay] <Double>] [-DisableRetry] [[-MaxRetryDelay] <Double>]
 [[-UseExponentialBackoff] <Boolean>] [[-UseJitter] <Boolean>] [-PassThru] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function allows you to configure the default retry behavior for all Azure DevOps API calls.
These settings will be used by default unless overridden in individual function calls.

## EXAMPLES

### EXAMPLE 1
```
Set-ApiRetryConfig -RetryCount 5 -RetryDelay 2
```

### EXAMPLE 2
```
Set-ApiRetryConfig -DisableRetry
```

### EXAMPLE 3
```
$config = Set-ApiRetryConfig -PassThru
```

## PARAMETERS

### -DisableRetry
Disables retry logic completely for all API calls.

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

### -MaxRetryDelay
The maximum delay in seconds between retries.
Default is 30 seconds.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 30.0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns the current retry configuration.

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
Position: 1
Default value: 3
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
Position: 2
Default value: 1.0
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseExponentialBackoff
Whether to use exponential backoff for retry delays.
Default is $true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseJitter
Whether to add random jitter to retry delays.
Default is $true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
