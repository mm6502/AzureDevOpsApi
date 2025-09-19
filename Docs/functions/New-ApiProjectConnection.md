---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# New-ApiProjectConnection

## SYNOPSIS
Creates a new API project connection object.

## SYNTAX

```
New-ApiProjectConnection [-ApiCollectionConnection] <Object> [[-ProjectName] <String>] [[-ProjectId] <String>]
 [[-ProjectUri] <String>] [[-ProjectBaseUri] <String>] [[-Verified] <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The \`New-ApiProjectConnection\` function creates a new API project connection object that
represents a connection to an Azure DevOps project.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ApiCollectionConnection
The API collection connection object that provides the base connection details.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Connection

Required: True
Position: 1
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

### -ProjectBaseUri
The base URI of the Azure DevOps project.

```yaml
Type: String
Parameter Sets: (All)
Aliases: BaseUri

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProjectId
The ID of the Azure DevOps project.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Id

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProjectName
The name of the Azure DevOps project.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProjectUri
The URI of the Azure DevOps project.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Uri

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Verified
Indicates whether the project connection has been verified.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A `PSCustomObject` representing the API project connection.
## NOTES

## RELATED LINKS
