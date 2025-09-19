---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-WebException

## SYNOPSIS
Creates a new web exception object with a custom status code, reason phrase, and message.

## SYNTAX

### Default (Default)
```
New-WebException [-StatusCode <Object>] [-ReasonPhrase <Object>] [-Content <Object>] [-ContentType <Object>]
 [-Message <Object>] [-Legacy] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Response
```
New-WebException [-Response <Object>] [-Message <Object>] [-Legacy] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The \`New-WebException\` function creates a new web exception object with a custom status code,
reason phrase, and message.
The exception can be used to represent errors that occur when
making web requests.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Content
The content to include in the exception.

```yaml
Type: Object
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: "{ message: ""$($Message)"" }"
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentType
The content type of the exception content.

```yaml
Type: Object
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: Application/json
Accept pipeline input: False
Accept wildcard characters: False
```

### -Legacy
Indicates whether to create a legacy \`System.Net.WebException\` object for PowerShell 5.1
or a \`Microsoft.PowerShell.Commands.HttpResponseException\` object for PowerShell 7 and later.

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

### -Message
The message to include in the exception.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Requested object does not exist.
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

### -ReasonPhrase
The reason phrase for the HTTP status code.

```yaml
Type: Object
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: Not Found
Accept pipeline input: False
Accept wildcard characters: False
```

### -Response
{{ Fill Response Description }}

```yaml
Type: Object
Parameter Sets: Response
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StatusCode
The HTTP status code for the exception.

```yaml
Type: Object
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: 404
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.ErrorRecord
### The web exception object.
## NOTES

## RELATED LINKS
