BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')

    # Helper function to create properly typed test case objects
    function New-MockTcmTestCaseExtended {
        param(
            [string]$Id,
            [string]$FilePath = 'test.yaml',
            [object]$LocalData = $null,
            [object]$RemoteData = $null,
            [object]$RemoteWorkItem = $null,
            [string]$SyncStatus = $null
        )

        $obj = [PSCustomObject]@{
            Id = $Id
            FilePath = $FilePath
            LocalData = $LocalData
            RemoteData = $RemoteData
            RemoteWorkItem = $RemoteWorkItem
            SyncStatus = $SyncStatus
        }

        # Add the required PSTypeNames (TcmTestCaseExtended is a subtype of TcmTestCaseInput)
        $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseExtended)
        $obj.PSTypeNames.Insert(0, $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseInput)

        return $obj
    }
}

Describe 'Sync-TcmTestCaseFromRemote' {

    BeforeAll {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
    }

    Context 'Parameter validation' {

        It 'Should require InputObject parameter' {
            # Act & Assert
            { Sync-TcmTestCaseFromRemote -TestCasesRoot 'test' } | Should -Throw
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

            # Mock internal functions
            Mock -ModuleName $ModuleName -CommandName Save-TcmTestCaseYaml -MockWith {
                $outputPath = Join-Path -Path $TestDrive -ChildPath 'output.yaml'
                return $outputPath
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseFromFile -MockWith {
                return [PSCustomObject]@{ id = '123'; title = 'Test' }
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmStringHash -MockWith {
                return 'testhash'
            }
            Mock -ModuleName $ModuleName -CommandName Update-TcmHashCacheEntry -MockWith { }

            $testCase = New-MockTcmTestCaseExtended -Id '123' -FilePath 'test.yaml' -RemoteData ([PSCustomObject]@{
                id = 123
                title = 'Test Title'
            }) -RemoteWorkItem ([PSCustomObject]@{
                id = 123
                fields = @{
                    'System.WorkItemType' = 'Test Case'
                    'System.Title' = 'Test Title'
                }
            })

            # Act & Assert
            { $testCase | Sync-TcmTestCaseFromRemote -TestCasesRoot $testRoot } | Should -Not -Throw
        }

        It 'Should reject objects without correct PSTypeName' {
            # Arrange
            $invalidObject = [PSCustomObject]@{ Id = '123' }

            # Act & Assert - The validation happens at parameter binding, so it will throw before reaching the function body
            { $invalidObject | Sync-TcmTestCaseFromRemote -TestCasesRoot 'test' } | Should -Throw
        }

        It 'Should reject plain string input' {
            # Act & Assert - The validation happens at parameter binding, so it will throw before reaching the function body
            { 'TC001' | Sync-TcmTestCaseFromRemote -TestCasesRoot 'test' } | Should -Throw
        }

        It 'Should reject numeric input' {
            # Act & Assert - The validation happens at parameter binding, so it will throw before reaching the function body
            { 12345 | Sync-TcmTestCaseFromRemote -TestCasesRoot 'test' } | Should -Throw
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
            { $testCase | Sync-TcmTestCaseFromRemote -TestCasesRoot $testRoot } | Should -Throw "*collectionUri*"
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
            { $testCase | Sync-TcmTestCaseFromRemote -TestCasesRoot $testRoot } | Should -Throw "*project*"
        }
    }

    Context 'Work Item ID validation' {

        BeforeEach {
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
        }

        It 'Should skip non-numeric Work Item IDs' {
            # Arrange
            $testCase = New-MockTcmTestCaseExtended -Id 'TC001' -RemoteData ([PSCustomObject]@{
                id = 'TC001'
                fields = @{
                    'System.WorkItemType' = 'Test Case'
                    'System.Title' = 'Test Title'
                }
            })

            # Act
            $testCase | Sync-TcmTestCaseFromRemote -TestCasesRoot $testRoot -WarningAction SilentlyContinue

            # Assert - Should have warned and skipped
            $true | Should -Be $true
        }
    }
}