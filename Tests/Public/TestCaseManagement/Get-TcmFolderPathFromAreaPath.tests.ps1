BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TcmFolderPathFromAreaPath' {

    Context 'Basic area path conversion' {

        It 'Should convert simple area path to folder path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area"

            # Assert
            $result | Should -Be "Project/Area/"
        }

        It 'Should convert multi-level area path to folder path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component"

            # Assert
            $result | Should -Be "Project/Area/Component/"
        }

        It 'Should handle single component area path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project"

            # Assert
            $result | Should -Be "Project/"
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
            $result | Should -Be "Project/Area/"
        }
    }

    Context 'Character sanitization' {

        It 'Should sanitize invalid filename characters' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'Project\Area<Component>'

            # Assert
            $result | Should -Be "Project/Area_Component_/"
        }

        It 'Should sanitize multiple invalid characters' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'Project\Area:Component\Sub*Component?'

            # Assert
            $result | Should -Be "Project/Area_Component/Sub_Component_/"
        }

        It 'Should replace spaces with underscores' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area Component"

            # Assert
            $result | Should -Be "Project/Area_Component/"
        }

        It 'Should handle mixed valid and invalid characters' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'My Project\Feature: Login\Auth*Module'

            # Assert
            $result | Should -Be "My_Project/Feature__Login/Auth_Module/"
        }
    }

    Context 'Depth limiting' {

        It 'Should not limit depth when MaxDepth is 0' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component\SubComponent\DeepLevel" -MaxDepth 0

            # Assert
            $result | Should -Be "Project/Area/Component/SubComponent/DeepLevel/"
        }

        It 'Should limit depth to specified MaxDepth' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component\SubComponent\DeepLevel" -MaxDepth 3

            # Assert
            $result | Should -Be "Project/Area/Component/"
        }

        It 'Should handle MaxDepth equal to component count' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component" -MaxDepth 3

            # Assert
            $result | Should -Be "Project/Area/Component/"
        }

        It 'Should handle MaxDepth greater than component count' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area" -MaxDepth 5

            # Assert
            $result | Should -Be "Project/Area/"
        }

        It 'Should handle MaxDepth of 1' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component\SubComponent" -MaxDepth 1

            # Assert
            $result | Should -Be "Project/"
        }
    }

    Context 'IncludeProject parameter' {

        It 'Should work with IncludeProject switch (currently no effect in implementation)' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Project\Area\Component" -IncludeProject

            # Assert
            $result | Should -Be "Project/Area/Component/"
        }
    }

    Context 'Complex real-world scenarios' {

        It 'Should handle typical Azure DevOps area path' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath "Contoso\WebApp\Authentication\Login"

            # Assert
            $result | Should -Be "Contoso/WebApp/Authentication/Login/"
        }

        It 'Should handle area path with numbers and special project names' {
            # Arrange & Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath 'Project_v2.1\Feature_123\API_Endpoints'

            # Assert
            $result | Should -Be "Project_v2.1/Feature_123/API_Endpoints/"
        }

        It 'Should handle very long area paths with depth limiting' {
            # Arrange
            $longPath = "Root\Level1\Level2\Level3\Level4\Level5\Level6"

            # Act
            $result = Get-TcmFolderPathFromAreaPath -AreaPath $longPath -MaxDepth 4

            # Assert
            $result | Should -Be "Root/Level1/Level2/Level3/"
        }
    }
}