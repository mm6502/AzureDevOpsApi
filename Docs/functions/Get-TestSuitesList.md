---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-TestSuitesList

## SYNOPSIS
Gets list of test suites for a test plan.

## SYNTAX

### FromId (Default)
```
Get-TestSuitesList [[-Project] <Object>] [-CollectionUri <Object>] [-Plan] <Object> [-Expand <String>]
 [-AsTreeView] [-Top <Object>] [-Skip <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### FromPipeline
```
Get-TestSuitesList -InputObject <Object> [-Expand <String>] [-AsTreeView] [-Top <Object>] [-Skip <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets list of test suites for a test plan using Azure DevOps Test Plans API.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AsTreeView
If the suites returned should be in a tree structure.

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

### -CollectionUri
Url for project collection on Azure DevOps server instance.
If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: FromId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Expand
Include children suites and/or default testers details.
Valid values: None, Children, DefaultTesters.
Can be combined, e.g., "Children, DefaultTesters".

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

### -InputObject
{{ Fill InputObject Description }}

```yaml
Type: Object
Parameter Sets: FromPipeline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Plan
Test plan object (with id and project properties) or test plan ID.
When providing an object, the Project and CollectionUri are extracted from it.
When providing an ID, relies on Project and CollectionUri parameters or global defaults.

```yaml
Type: Object
Parameter Sets: FromId
Aliases: PlanId, Id

Required: True
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
Project name, identifier, full project URI, or object with any one
these properties.
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

```yaml
Type: Object
Parameter Sets: FromId
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
https://learn.microsoft.com/en-us/rest/api/azure/devops/testplan/test-suites/get-test-suites-for-plan?view=azure-devops-rest-7.1

## RELATED LINKS
