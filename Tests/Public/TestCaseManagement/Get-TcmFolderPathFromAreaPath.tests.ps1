BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TcmFolderPathFromAreaPath' {

    BeforeAll {
        $script:dirSep = [System.IO.Path]::DirectorySeparatorChar
    }

    Context 'Basic area path conversion' {

        It 'Should convert simple area path to folder path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area"

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)"
        }

        It 'Should convert multi-level area path to folder path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component"

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)Component$($script:dirSep)"
        }

        It 'Should handle single component area path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project"

            # Assert
            $result | Should -Be "Project$($script:dirSep)"
        }
    }

    Context 'Empty and null inputs' {

        It 'Should return empty string for null area path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath $null

            # Assert
            $result | Should -Be ""
        }

        It 'Should return empty string for empty area path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath ""

            # Assert
            $result | Should -Be ""
        }

        It 'Should return empty string for whitespace-only area path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "   "

            # Assert
            $result | Should -Be ""
        }

        It 'Should handle area path with empty components' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\\Area"

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)"
        }
    }

    Context 'Character sanitization' {

        It 'Should sanitize invalid filename characters' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'Project\Area<Component>'

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area_Component_$($script:dirSep)"
        }

        It 'Should sanitize multiple invalid characters' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'Project\Area:Component\Sub*Component?'

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area_Component$($script:dirSep)Sub_Component_$($script:dirSep)"
        }

        It 'Should replace spaces with underscores' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area Component"

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area_Component$($script:dirSep)"
        }

        It 'Should handle mixed valid and invalid characters' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'My Project\Feature: Login\Auth*Module'

            # Assert
            $result | Should -Be "My_Project$($script:dirSep)Feature__Login$($script:dirSep)Auth_Module$($script:dirSep)"
        }
    }

    Context 'Depth limiting' {

        It 'Should not limit depth when MaxDepth is 0' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component\SubComponent\DeepLevel" -MaxDepth 0

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)Component$($script:dirSep)SubComponent$($script:dirSep)DeepLevel$($script:dirSep)"
        }

        It 'Should limit depth to specified MaxDepth' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component\SubComponent\DeepLevel" -MaxDepth 3

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)Component$($script:dirSep)"
        }

        It 'Should handle MaxDepth equal to component count' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component" -MaxDepth 3

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)Component$($script:dirSep)"
        }

        It 'Should handle MaxDepth greater than component count' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area" -MaxDepth 5

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)"
        }

        It 'Should handle MaxDepth of 1' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component\SubComponent" -MaxDepth 1

            # Assert
            $result | Should -Be "Project$($script:dirSep)"
        }
    }

    Context 'IncludeProject parameter' {

        It 'Should work with IncludeProject switch (currently no effect in implementation)' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component" -IncludeProject

            # Assert
            $result | Should -Be "Project$($script:dirSep)Area$($script:dirSep)Component$($script:dirSep)"
        }
    }

    Context 'Complex real-world scenarios' {

        It 'Should handle typical Azure DevOps area path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Contoso\WebApp\Authentication\Login"

            # Assert
            $result | Should -Be "Contoso$($script:dirSep)WebApp$($script:dirSep)Authentication$($script:dirSep)Login$($script:dirSep)"
        }

        It 'Should handle area path with numbers and special project names' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'Project_v2.1\Feature_123\API_Endpoints'

            # Assert
            $result | Should -Be "Project_v2.1$($script:dirSep)Feature_123$($script:dirSep)API_Endpoints$($script:dirSep)"
        }

        It 'Should handle very long area paths with depth limiting' {
            # Arrange
            $longPath = "Root\Level1\Level2\Level3\Level4\Level5\Level6"

            # Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath $longPath -MaxDepth 4

            # Assert
            $result | Should -Be "Root$($script:dirSep)Level1$($script:dirSep)Level2$($script:dirSep)Level3$($script:dirSep)"
        }
    }
}
