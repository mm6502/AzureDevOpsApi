# 06 - Advanced Scenarios

This example demonstrates advanced TestCaseManagement features including custom fields, bulk operations, and integration patterns.

## Overview

The TestCaseManagement system supports advanced scenarios beyond basic test case creation and synchronization.

## Custom Fields

### Adding Custom Fields to Test Cases

```powershell
# Create a test case with custom fields
New-TcmTestCase -Title "Advanced API Test" -OutputPath "APITests/advanced-api-test.yaml" -CustomFields @{
    "Custom.TestPriority" = "High"
    "Custom.TestEnvironment" = "Production"
    "Custom.EstimatedHours" = 4
}
```

### YAML Structure with Custom Fields

```yaml
testCase:
  id: 12345
  title: "Advanced API Test"
  areaPath: "Project\\API"
  customFields:
    Custom.TestPriority: "High"
    Custom.TestEnvironment: "Production"
    Custom.EstimatedHours: 4
    Custom.TestCategory: "Integration"
  steps:
    - stepNumber: 1
      action: "Send POST request to /api/users"
      expectedResult: "User created successfully"
```

### Updating Custom Fields

```powershell
# Update custom fields in existing test case
# Method 1: Edit the YAML file directly in your editor
# Open TestCases/TC001.yaml and add/modify under customFields section

# Method 2: Programmatically update the YAML file
$yamlPath = "TestCases/TC001.yaml"
$content = Get-Content $yamlPath -Raw
# Modify content as needed, then save
$content | Set-Content $yamlPath

# Push the changes
Sync-TcmTestCase -InputObject "TC001" -Push
```

## Bulk Operations

### Creating Multiple Test Cases

```powershell
# Create test cases from a CSV file
$testCases = Import-Csv "test-cases.csv"

foreach ($tc in $testCases) {
    New-TcmTestCase -Title $tc.Title -OutputPath "Bulk/$($tc.Id).yaml" -CustomFields @{
        "Custom.TestType" = $tc.Type
        "Custom.Priority" = $tc.Priority
    }
}
```

### Bulk Synchronization

```powershell
# Sync all test cases in a folder
Get-ChildItem "TestCases/Sprint-25/*.yaml" | Sync-TcmTestCase -Push

# Sync with error handling
$files = Get-ChildItem "TestCases/**/*.yaml" -Recurse
$results = @()

foreach ($file in $files) {
    try {
        Sync-TcmTestCase -InputObject $file.FullName -Push -ErrorAction Stop
        $results += [PSCustomObject]@{ File = $file.Name; Status = "Success" }
    } catch {
        $results += [PSCustomObject]@{ File = $file.Name; Status = "Failed"; Error = $_.Exception.Message }
    }
}

$results | Format-Table
```

### Bulk Status Check

```powershell
# Get sync status for all test cases
$statusReport = Get-TcmTestCase -IncludeSyncStatus

# Group by status
$statusReport | Group-Object SyncStatus | Select-Object Name, Count

# Export report
$statusReport | Export-Csv "sync-status-report.csv" -NoTypeInformation
```

## Advanced Test Case Structures

### Shared Test Steps

```yaml
# Shared steps file (not a complete test case)
sharedSteps:
  loginSteps:
    - stepNumber: 1
      action: "Navigate to login page"
      expectedResult: "Login form is displayed"
    - stepNumber: 2
      action: "Enter valid credentials"
      expectedResult: "Credentials accepted"

# Main test case referencing shared steps
testCase:
  id: 12345
  title: "User Profile Update"
  steps:
    - stepNumber: 1
      action: "Execute login steps"
      expectedResult: "User is logged in"
    - stepNumber: 2
      action: "Navigate to profile page"
      expectedResult: "Profile page loads"
    - stepNumber: 3
      action: "Update profile information"
      expectedResult: "Profile updated successfully"
```

### Parameterized Test Cases

```yaml
testCase:
  id: 12346
  title: "Data Validation Test - {parameter}"
  parameters:
    - name: "parameter"
      values: ["Email", "Phone", "Address"]
  steps:
    - stepNumber: 1
      action: "Enter {parameter} value"
      expectedResult: "{parameter} is accepted"
    - stepNumber: 2
      action: "Submit form"
      expectedResult: "Form submits successfully"
```

## Integration with Azure DevOps Features

### Linking to Work Items

```powershell
# Create test case linked to a user story
$testCase = New-TcmTestCase -Title "User Story Implementation Test" -OutputPath "linked-test.yaml"

# Add link to user story (requires work item ID)
# Note: This would need to be added to the work item after creation
# Update-WorkItem -WorkItem $testCase.Id -AddLink @{ url = "https://dev.azure.com/org/project/_workitems/edit/12345"; type = "Related" }
```

### Test Suites Integration

```powershell
# Add test case to test suite
Add-TestCaseToTestSuite -TestCaseId 12345 -TestSuiteId 67890

# Get test cases in a suite
Get-TestSuiteTestCasesList -TestSuiteId 67890
```

### Test Plans

```powershell
# Get available test plans
Get-TestPlansList -Project "MyProject"

# Associate test case with test plan
# (This would typically be done through the Azure DevOps UI or additional API calls)
```

## Automation Integration

### Automated Test Cases

```yaml
testCase:
  id: 12347
  title: "Automated Login Test"
  automationStatus: "Automated"
  customFields:
    Custom.AutomationScript: "LoginTests.ps1"
    Custom.TestFramework: "Pester"
  steps:
    - stepNumber: 1
      action: "Execute automated test script"
      expectedResult: "All assertions pass"
```

### Linking Automation Results

```powershell
# Update test case with automation results
# Edit the YAML file directly to add automation results
$yamlPath = "TestCases/TC001.yaml"
$content = Get-Content $yamlPath -Raw

# Update custom fields in the YAML content
# Or manually edit the file to add:
#   customFields:
#     Custom.LastRunDate: "2025-10-16"
#     Custom.LastRunResult: "Passed"

$content | Set-Content $yamlPath

Sync-TcmTestCase -InputObject "TC001" -Push
```

## Advanced Configuration

### Multiple Configurations

```powershell
# Create different configurations for different environments
New-TcmConfig -CollectionUri "https://dev.azure.com/org" -Project "DevProject" -OutputPath ".tcm-config.dev.yaml"
New-TcmConfig -CollectionUri "https://dev.azure.com/org" -Project "TestProject" -OutputPath ".tcm-config.test.yaml"
New-TcmConfig -CollectionUri "https://dev.azure.com/org" -Project "ProdProject" -OutputPath ".tcm-config.prod.yaml"

# Use specific config by copying it to your test cases directory
# The functions will automatically find .tcm-config.yaml in the test cases root
Copy-Item ".tcm-config.dev.yaml" "TestCases-Dev/.tcm-config.yaml"
Set-Location "TestCases-Dev"
```

### Environment-Specific Settings

```yaml
# .tcm-config.yaml with environment settings
azureDevOps:
  collectionUri: "https://dev.azure.com/myorg"
  project: "MyProject"

sync:
  defaultConflictResolution: "manual"
  autoBackup: true
  excludePatterns:
    - "**/*-draft.yaml"
    - "**/archive/**"

customFields:
  defaults:
    Custom.Environment: "Development"
    Custom.TestedBy: "Automation"
  mappings:
    priority: "Custom.TestPriority"
    severity: "Custom.BugSeverity"
```

## Performance Optimization

### Large-Scale Operations

```powershell
# Process test cases in batches
$batchSize = 10
$allFiles = Get-ChildItem "TestCases/**/*.yaml" -Recurse

for ($i = 0; $i -lt $allFiles.Count; $i += $batchSize) {
    $batch = $allFiles[$i..([Math]::Min($i + $batchSize - 1, $allFiles.Count - 1))]
    $batch | Sync-TcmTestCase -Push

    Write-Progress -Activity "Syncing test cases" -Status "$($i + $batch.Count) of $($allFiles.Count)" -PercentComplete (($i + $batch.Count) / $allFiles.Count * 100)
}
```

### Parallel Processing

```powershell
# Use PowerShell workflows for parallel processing (PowerShell 5.1+)
workflow Sync-TestCasesParallel {
    param([string[]]$FilePaths)

    foreach -parallel ($path in $FilePaths) {
        InlineScript {
            Sync-TcmTestCase -InputObject $using:path -Push
        }
    }
}

$files = Get-ChildItem "TestCases/**/*.yaml" -Recurse | Select-Object -ExpandProperty FullName
Sync-TestCasesParallel -FilePaths $files
```

## Error Handling and Logging

### Comprehensive Error Handling

```powershell
function Sync-WithLogging {
    param([string]$Path)

    try {
        $testCase = Get-TcmTestCase -InputObject $Path -IncludeSyncStatus

        Write-Verbose "Processing $($testCase.Id) - Status: $($testCase.SyncStatus)"

        switch ($testCase.SyncStatus) {
            "synced" {
                Write-Verbose "Already synced: $($testCase.Id)"
                return [PSCustomObject]@{ Id = $testCase.Id; Status = "Skipped"; Reason = "Already synced" }
            }
            "conflict" {
                Write-Warning "Conflict detected: $($testCase.Id)"
                return [PSCustomObject]@{ Id = $testCase.Id; Status = "Failed"; Reason = "Conflict detected" }
            }
            default {
                Sync-TcmTestCase -InputObject $testCase.Id -Push
                return [PSCustomObject]@{ Id = $testCase.Id; Status = "Success" }
            }
        }
    } catch {
        Write-Error "Failed to sync $($Path): $($_.Exception.Message)"
        return [PSCustomObject]@{ Id = $testCase.Id; Status = "Error"; Error = $_.Exception.Message }
    }
}

# Process all files with logging
$results = Get-ChildItem "TestCases/**/*.yaml" -Recurse | ForEach-Object { Sync-WithLogging -Path $_.FullName }
$results | Export-Csv "sync-results.csv" -NoTypeInformation
```

## Migration and Data Management

### Migrating from Other Systems

```powershell
# Import from Excel
$excelData = Import-Excel "legacy-test-cases.xlsx"

foreach ($row in $excelData) {
    $steps = @()
    for ($i = 1; $i -le 10; $i++) {
        if ($row."Step${i}" -and $row."Expected${i}") {
            $steps += @{
                stepNumber = $i
                action = $row."Step${i}"
                expectedResult = $row."Expected${i}"
            }
        }
    }

    New-TcmTestCase -Title $row.Title -OutputPath "Migrated/$($row.Id).yaml" -Steps $steps -CustomFields @{
        "Custom.LegacyId" = $row.Id
        "Custom.MigratedDate" = Get-Date -Format "yyyy-MM-dd"
    }
}
```

## Related Examples

- [01-setup-configuration.md](01-setup-configuration.md) - Basic setup
- [02-creating-test-cases.md](02-creating-test-cases.md) - Basic test case creation
- [03-folder-organization.md](03-folder-organization.md) - Organization patterns
- [04-sync-workflows.md](04-sync-workflows.md) - Sync operations
- [05-conflict-resolution.md](05-conflict-resolution.md) - Handling conflicts
