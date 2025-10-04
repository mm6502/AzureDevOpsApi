---
external help file: AzureDevOpsApi-help.xml
Module Name: AzureDevOpsApi
online version:
schema: 2.0.0
---

# Get-TestSuiteTestCasesList

## SYNOPSIS
Gets list of test cases for a test suite.

## SYNTAX

### FromId (Default)
```
Get-TestSuiteTestCasesList [[-Project] <Object>] [-CollectionUri <Object>] [[-Plan] <Object>] [-Suite] <Object>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### FromPipeline
```
Get-TestSuiteTestCasesList -InputObject <Object> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets list of test cases for a test suite using Azure DevOps Test Plans API.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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
Optional if Suite object has TestPlanId or plan property.

```yaml
Type: Object
Parameter Sets: FromId
Aliases: PlanId, Id

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

### -Suite
Test suite object (with id and optionally TestPlanId or plan property) or test suite ID.
Can be piped from Get-TestSuitesList.

```yaml
Type: Object
Parameter Sets: FromId
Aliases: SuiteId

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
https://learn.microsoft.com/en-us/rest/api/azure/devops/test/test-case/list?view=azure-devops-rest-5.0

## RELATED LINKS
