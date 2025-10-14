BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')

    # Helper function to create properly typed test case objects
    function New-MockTcmTestCaseExtended {
        param(
            [string]$Id,
            [string]$FilePath = 'test.yaml',
            [object]$LocalData = $null,
            [object]$RemoteData = $null,
            [string]$SyncStatus = $null
        )

        if ($null -eq $LocalData) {
            $LocalData = [ordered]@{
                id = $Id
                title = 'Test Case Title'
                areaPath = 'TestProject'
                iterationPath = 'TestProject'
                state = 'Design'
                priority = 2
                description = ''
                preconditions = ''
                steps = @()
                automationStatus = 'Not Automated'
                tags = @()
                assignedTo = ''
                customFields = @{}
            }
        }

        $obj = [PSCustomObject]@{
            Id = $Id
            FilePath = $FilePath
            LocalData = $LocalData
            RemoteData = $RemoteData
            SyncStatus = $SyncStatus
        }

        # Add the required PSTypeNames (TcmTestCaseExtended is a subtype of TcmTestCaseInput)
        $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended)
        $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseInput)

        return $obj
    }
}

Describe 'Sync-TcmTestCaseToRemote' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
    }

    Context 'Parameter validation' {

        It 'Should require InputObject parameter' {
            # Act & Assert
            { Sync-TcmTestCaseToRemote -TestCasesRoot 'test' } | Should -Throw
        }

        It 'Should accept objects with correct PSTypeName' {
            # Arrange
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
  project: "TestProject"
  pat: "dummy-pat"
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8

            $testCase = New-MockTcmTestCaseExtended -Id '123'

            Mock -ModuleName $ModuleName -CommandName Resolve-TcmTestCaseSyncStatus -MockWith {
                param($InputObject)
                $InputObject.SyncStatus = 'synced'
                $InputObject
            }

            # Act & Assert
            { $testCase | Sync-TcmTestCaseToRemote -TestCasesRoot $testRoot -WhatIf } | Should -Not -Throw
        }

        It 'Should reject objects without correct PSTypeName' {
            # Arrange
            $invalidObject = [PSCustomObject]@{ Id = '123' }

            # Act & Assert - The validation happens at parameter binding, so it will throw before reaching the function body
            { $invalidObject | Sync-TcmTestCaseToRemote -TestCasesRoot 'test' } | Should -Throw
        }

        It 'Should reject plain string input' {
            # Act & Assert - The validation happens at parameter binding, so it will throw before reaching the function body
            { 'TC001' | Sync-TcmTestCaseToRemote -TestCasesRoot 'test' } | Should -Throw
        }

        It 'Should reject numeric input' {
            # Act & Assert - The validation happens at parameter binding, so it will throw before reaching the function body
            { 12345 | Sync-TcmTestCaseToRemote -TestCasesRoot 'test' } | Should -Throw
        }
    }

    Context 'Configuration validation' {

        It 'Should throw when collectionUri is not configured' {
            # Arrange
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file without collectionUri
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  project: "TestProject"
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8

            $testCase = New-MockTcmTestCaseExtended -Id '123'

            # Act & Assert
            { $testCase | Sync-TcmTestCaseToRemote -TestCasesRoot $testRoot } | Should -Throw "*collectionUri*"
        }

        It 'Should throw when project is not configured' {
            # Arrange
            $testRoot = Join-Path -Path $TestDrive -ChildPath 'TestCases'
            New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

            # Create a test config file without project
            $configPath = Join-Path -Path $testRoot -ChildPath '.tcm-config.yaml'
            $configContent = @"
azureDevOps:
  collectionUri: "https://dev.azure.com/test"
"@
            Set-Content -Path $configPath -Value $configContent -Encoding UTF8

            $testCase = New-MockTcmTestCaseExtended -Id '123'

            # Act & Assert
            { $testCase | Sync-TcmTestCaseToRemote -TestCasesRoot $testRoot } | Should -Throw "*project*"
        }
    }
}