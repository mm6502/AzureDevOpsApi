BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\BeforeAll.ps1')
}

Describe 'ConvertTo-TcmTestCaseInput' {

    Context 'TcmTestCaseInput pass-through' {

        It 'Should pass through existing TcmTestCaseInput objects' {
            # Arrange
            $inputObject = [PSCustomObject]@{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                FilePath   = 'C:\TestCases\TC001.yaml'
                Id         = 'TC001'
                SyncStatus = $null
                LocalData  = $null
                RemoteData = $null
            }

            # Act
            $result = $inputObject | ConvertTo-TcmTestCaseInput

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result.FilePath | Should -Be 'C:\TestCases\TC001.yaml'
            $result.Id | Should -Be 'TC001'
        }
    }

    Context 'TcmTestCase object handling' {

        It 'Should wrap TcmTestCaseLocalData objects from Get-TcmTestCaseFromFile' {
            # Arrange
            $testCaseObject = [PSCustomObject]@{
                PSTypeName = $global:PSTypeNames.AzureDevOpsApi.TcmTestCaseLocalData
                FilePath   = 'C:\TestCases\TC001.yaml'
                testCase   = @{ id = 'TC001'; title = 'Test Case 1' }
            }

            # Act
            $result = $testCaseObject | ConvertTo-TcmTestCaseInput

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result[0].PSTypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
            $result[0].FilePath | Should -Be 'C:\TestCases\TC001.yaml'
            $result[0].Id | Should -Be 'TC001'
            $result[0].LocalData | Should -Be $testCaseObject
        }
    }

    Context 'PSCustomObject/hashtable with testCase.id' {

        It 'Should wrap hashtable with testCase.id property' {
            # Arrange
            $hashtable = @{
                FilePath = 'C:\TestCases\TC001.yaml'
                testCase = @{ id = 'TC001'; title = 'Test Case 1' }
            }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $hashtable

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result[0].PSTypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
            $result[0].FilePath | Should -Be 'C:\TestCases\TC001.yaml'
            $result[0].Id | Should -Be 'TC001'
        }

        It 'Should wrap PSCustomObject with testCase.id property' {
            # Arrange
            $customObject = [PSCustomObject]@{
                FilePath = 'C:\TestCases\TC002.yaml'
                testCase = [PSCustomObject]@{ id = 'TC002'; title = 'Test Case 2' }
            }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $customObject

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result[0].PSTypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
            $result[0].Id | Should -Be 'TC002'
        }
    }

    Context 'PSCustomObject with Id property' {

        It 'Should wrap PSCustomObject with Id property' {
            # Arrange
            $customObject = [PSCustomObject]@{
                Id = 'TC003'
            }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $customObject

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result[0].PSTypeNames[0] | Should -Be 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
            $result[0].Id | Should -Be 'TC003'
            $result[0].FilePath | Should -Be $null
        }
    }

    Context 'File path handling' {

        It 'Should handle absolute file paths' {
            # Arrange
            $filePath = 'C:\TestCases\TC001.yaml'
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true } -ParameterFilter { $Path -eq $filePath -and $PathType -eq 'Leaf' }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $filePath

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result.FilePath | Should -Be $filePath
            $result.Id | Should -Be $null
        }

        It 'Should resolve relative paths against TestCasesRoot' {
            # Arrange
            $relativePath = 'TC001.yaml'
            $testCasesRoot = 'C:\TestCases'
            $expectedPath = Join-Path -Path $testCasesRoot -ChildPath $relativePath
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true } -ParameterFilter { $Path -eq $expectedPath -and $PathType -eq 'Leaf' }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $relativePath -TestCasesRoot $testCasesRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.FilePath | Should -Be $expectedPath
        }

        It 'Should error on invalid file paths' {
            # Arrange
            $invalidPath = 'C:\NonExistent\file.yaml'
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }

            # Act & Assert
            { ConvertTo-TcmTestCaseInput -InputObject $invalidPath -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Directory handling' {

        It 'Should handle directory paths and return multiple files' {
            # Arrange
            $directoryPath = 'C:\TestCases'
            $mockFiles = @(
                [PSCustomObject]@{ FullName = 'C:\TestCases\TC001.yaml' },
                [PSCustomObject]@{ FullName = 'C:\TestCases\TC002.yaml' }
            )
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true } -ParameterFilter { $Path -eq $directoryPath -and $PathType -eq 'Container' }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith { $mockFiles }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $directoryPath

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].FilePath | Should -Be 'C:\TestCases\TC001.yaml'
            $result[1].FilePath | Should -Be 'C:\TestCases\TC002.yaml'
        }

        It 'Should exclude dot-files from directory scanning' {
            # Arrange
            $directoryPath = 'C:\TestCases'
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true } -ParameterFilter { $Path -eq $directoryPath -and $PathType -eq 'Container' }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                , @([PSCustomObject]@{ FullName = 'C:\TestCases\.tcm-config.yaml' })
            }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $directoryPath

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'ID handling and caching' {

        It 'Should handle numeric IDs with local file match' {
            # Arrange
            $id = '123'
            $expectedFilePath = 'C:\TestCases\123-test.yaml'
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                , @([PSCustomObject]@{ FullName = $expectedFilePath; Name = '123-test.yaml' })
            }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $id -TestCasesRoot 'C:\TestCases'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result.Id | Should -Be $id
            $result.FilePath | Should -Be $expectedFilePath
        }

        It 'Should handle numeric IDs without local file match' {
            # Arrange
            $id = '456'
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith { @() }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $id -TestCasesRoot 'C:\TestCases'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result.Id | Should -Be $id
            $result.FilePath | Should -Be $null
        }

        It 'Should handle non-numeric IDs with filename extraction' {
            # Arrange
            $id = 'TC001'
            $expectedFilePath = 'C:\TestCases\TC001-login.yaml'
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                , @([PSCustomObject]@{ FullName = $expectedFilePath; Name = 'TC001-login.yaml' })
            }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $id -TestCasesRoot 'C:\TestCases'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Id | Should -Be $id
            $result.FilePath | Should -Be $expectedFilePath
        }

        It 'Should handle IDs with file content parsing for non-numeric IDs' {
            # Arrange
            $id = 'CUSTOM001'
            $filePath = 'C:\TestCases\custom-test.yaml'
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith {
                , @([PSCustomObject]@{ FullName = $filePath; Name = 'custom-test.yaml' })
            }
            Mock -ModuleName $ModuleName -CommandName Get-TcmTestCaseFromFile -MockWith {
                @{ testCase = @{ id = 'CUSTOM001' } }
            }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $id -TestCasesRoot 'C:\TestCases'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Id | Should -Be $id
            $result.FilePath | Should -Be $filePath
        }
    }

    Context 'Pipeline input' {

        It 'Should handle multiple inputs from pipeline' {
            # Arrange
            $inputs = @('TC001', 'TC002')
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $false }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith { @() }

            # Act
            $result = $inputs | ConvertTo-TcmTestCaseInput -TestCasesRoot 'C:\TestCases'

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].Id | Should -Be 'TC001'
            $result[1].Id | Should -Be 'TC002'
        }
    }

    Context 'Null input handling' {

        It 'Should handle null input by scanning directory' {
            # Arrange
            $testCasesRoot = 'C:\TestCases'
            $mockFiles = @([PSCustomObject]@{ FullName = 'C:\TestCases\TC001.yaml' })
            Mock -ModuleName $ModuleName -CommandName Get-Item -MockWith { $testCasesRoot }
            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true } -ParameterFilter { $PathType -eq 'Container' }
            Mock -ModuleName $ModuleName -CommandName Get-ChildItem -MockWith { $mockFiles }

            # Act
            $result = ConvertTo-TcmTestCaseInput -TestCasesRoot $testCasesRoot

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
        }
    }

    Context 'Output filtering' {

        It 'Should only return objects with FilePath or Id' {
            # Arrange
            $invalidObject = [PSCustomObject]@{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseInput'
                FilePath   = $null
                Id         = $null
            }

            # Act
            $result = ConvertTo-TcmTestCaseInput -InputObject $invalidObject

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }
}
