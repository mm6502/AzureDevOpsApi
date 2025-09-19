BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemRefsListByArtifactUri' {

    BeforeEach {

        $expected = [PSCustomObject] @{
            ApiProjectConnection = New-TestApiProjectConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            $expected.ApiProjectConnection
        }
    }

    It 'Should call Invoke-ApiRequest with correct parameters' {

        # Arrange
        $pullRequestId = '8357'
        $artifactUri = "vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f$($pullRequestId)"

        $expected = [PSCustomObject]@{
            ApiProjectConnection = $expected.ApiProjectConnection
            QueryUri             = "_apis/wit/artifacturiquery/$($pullRequestId)"
            ArtifactUri          = $artifactUri
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            @{
                artifactUrisQueryResult = @{
                    $artifactUri = @{
                        id  = 1
                        url = "$($expected.ApiProjectConnection.$CollectionUri)/_apis/wit/workitems/1"
                    }
                }
            }
        }

        # Act
        $result = Get-WorkItemRefsListByArtifactUri `
            -ArtifactUri $expected.ArtifactUri `
            -CollectionUri $expected.ApiProjectConnection.CollectionUri `

        # Assert
        $result | Should -BeOfType [PSCustomObject]
        Should -Invoke Invoke-Api -ModuleName $ModuleName -ParameterFilter {
            $Body -like "*$($artifactUri)*"
        }
    }
}
