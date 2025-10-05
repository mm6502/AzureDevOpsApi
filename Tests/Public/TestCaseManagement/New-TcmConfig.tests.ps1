BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-TcmConfig' {

    BeforeEach {
        # Suppress Write-Host output in tests
        Mock -ModuleName $ModuleName -CommandName Write-Host -MockWith { }

        $testConnection = New-TestApiProjectConnection
        Mock -ModuleName $ModuleName -CommandName Use-CollectionUri -MockWith {
            param($Value)
            $testConnection.CollectionUri = if (!$Value) { $testConnection.CollectionUri } else { $Value }
            return $testConnection.CollectionUri
        }
        Mock -ModuleName $ModuleName -CommandName Use-Project -MockWith {
            param($Value)
            $testConnection.ProjectName = if (!$Value) { $testConnection.ProjectName } else { $Value }
            return $testConnection.ProjectName
        }
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            $testConnection.CollectionUri
        }
    }

    Context 'Config file creation' {

        It 'Should create config file with required parameters' {
            # Arrange
            $testPath = Join-Path -Path $TestDrive -ChildPath 'TestConfig'
            New-Item -Path $testPath -ItemType Directory -Force | Out-Null

            # Act
            New-TcmConfig -CollectionUri "test-org" -Project "test-project" -OutputPath $testPath

            # Assert
            $configFile = Join-Path -Path $testPath -ChildPath '.tcm-config.yaml'
            $configFile | Should -Exist

            $content = Get-Content -Path $configFile -Raw
            $content | Should -Match 'organization: "test-org"'
            $content | Should -Match 'project: "test-project"'
            $content | Should -Match 'pat: "\$\{AZURE_DEVOPS_PAT\}"'
            $content | Should -Match 'direction: "bidirectional"'
        }

        It 'Should create config file with custom PAT' {
            # Arrange
            $testPath = Join-Path -Path $TestDrive -ChildPath 'TestConfig2'
            New-Item -Path $testPath -ItemType Directory -Force | Out-Null
            $configFile = Join-Path -Path $testPath -ChildPath 'config.yaml'

            # Act
            New-TcmConfig `
                -CollectionUri "test-org" `
                -Project "test-project" `
                -Token "custom-pat" `
                -OutputPath $configFile

            # Assert
            $configFile | Should -Exist

            $content = Get-Content -Path $configFile -Raw
            $content | Should -Match 'pat: "custom-pat"'
        }

        It 'Should throw error when config file already exists and Force is not used' {
            # Arrange
            $testPath = Join-Path -Path $TestDrive -ChildPath 'TestConfig3'
            New-Item -Path $testPath -ItemType Directory -Force | Out-Null
            $configFile = Join-Path -Path $testPath -ChildPath 'config.yaml'
            "existing content" | Out-File -FilePath $configFile

            # Act & Assert
            { New-TcmConfig `
                -CollectionUri "test-org" `
                -Project "test-project" `
                -OutputPath configFile
            } | Should -Throw
        }

        It 'Should overwrite existing config file when Force is used' {
            # Arrange
            $testPath = Join-Path -Path $TestDrive -ChildPath 'TestConfig4'
            New-Item -Path $testPath -ItemType Directory -Force | Out-Null
            $configFile = Join-Path -Path $testPath -ChildPath 'config.yaml'
            "existing content" | Out-File -FilePath $configFile

            # Act
            New-TcmConfig -CollectionUri "test-org" -Project "test-project" -OutputPath $configFile -Force

            # Assert
            $content = Get-Content -Path $configFile -Raw
            $content | Should -Match 'organization: "test-org"'
            $content | Should -Not -Match 'existing content'
        }
    }
}