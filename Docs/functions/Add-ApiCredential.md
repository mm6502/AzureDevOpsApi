---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Add-ApiCredential

## SYNOPSIS
Creates an object that contains credentials for the Azure DevOps API calls
and stores it in the global cache associated with the collection URI and project.

## SYNTAX

### Credential (Default)
```
Add-ApiCredential [-CollectionUri <Object>] [-Project <Object>] [-AlsoUseForCollection]
 [-Authorization <String>] [-Credential <PSCredential>] [-SkipValidation] [-PassThru]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ApiCredential
```
Add-ApiCredential [-CollectionUri <Object>] [-Project <Object>] [-AlsoUseForCollection]
 [-Authorization <String>] -ApiCredential <PSObject> [-SkipValidation] [-PassThru]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Token
```
Add-ApiCredential [-CollectionUri <Object>] [-Project <Object>] [-AlsoUseForCollection]
 [-Authorization <String>] [-Token <Object>] [-SkipValidation] [-PassThru] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function is used to create an object that contains credentials for the Azure DevOps API.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AlsoUseForCollection
{{ Fill AlsoUseForCollection Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ForCollection

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiCredential
Adds ApiCredentials previously created via New-ApiCredential.

```yaml
Type: PSObject
Parameter Sets: ApiCredential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Authorization
The authorization used to authenticate to the Azure DevOps API.
Possible values are:
- $null or '' - autodetect the type of authorization, based on the value of
   the $Token and $Credential parameters.
- 'Default' - Use the default network credentials.
- 'Basic' - Use given $apiCredential.
- 'PAT' or 'PersonalAccessToken' - Use a Personal Access Token.
- 'Bearer' - Use a Bearer token.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionUri
The URI of the Azure DevOps collection.

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

### -Credential
The \[PSCredential\] used to authenticate to the Azure DevOps API.

```yaml
Type: PSCredential
Parameter Sets: Credential
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
If specified, returns the ApiCredential object.

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

### -Project
The name of the Azure DevOps project.

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

### -SkipValidation
Skips validation of the ApiCredential.

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

### -Token
The token used to authenticate to the Azure DevOps API.

```yaml
Type: Object
Parameter Sets: Token
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

### PSTypeNames.AzureDevOpsApi.ApiCredential
## NOTES

## RELATED LINKS
