BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-WorkItemRefsListByArtifactUri' {

    BeforeAll {

        # 'vstfs:///Git/PullRequestId/9d7a1154-1315-433e-96e5-11f160256a1d%2f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed%2f8357',
        # 'vstfs:///Git/PullRequestId/5e62fde7-1b9d-40d1-b69c-787f9b7aaadb%2ffccd7d08-bf7c-4995-a1e5-60524f9aab20%2f8636'
        $expected = [PSCustomObject] @{
            Project1 = [PSCustomObject] @{
                ApiProject     = $null
                Id             = '9d7a1154-1315-433e-96e5-11f160256a1d'
                CollectionUri  = 'https://dev-tfs/tfs/internal_projects'
                RepositoryId   = 'f96e0832a-94a2-4c0c-887e-48b8f3d2e7ed'
                ProjectBaseUri = $null
                ArtifactUri    = $null
                WorkItemUri    = $null
            }
            Project2 = [PSCustomObject]@{
                ApiProject     = $null
                Id             = '5e62fde7-1b9d-40d1-b69c-787f9b7aaadb'
                CollectionUri  = 'https://dev-tfs/tfs/other_projects'
                RepositoryId   = 'fccd7d08-bf7c-4995-a1e5-60524f9aab20'
                ProjectBaseUri = $null
                ArtifactUri    = $null
                WorkItemUri    = $null
            }
        }

        $expected.Project1.ApiProject = New-ApiProject `
            -CollectionUri $expected.Project1.CollectionUri `
            -ProjectId $expected.Project1.Id

        $expected.Project2.ApiProject = New-ApiProject `
            -CollectionUri $expected.Project2.CollectionUri `
            -ProjectId $expected.Project2.Id

        # id     url
        # --     ---
        # 405200 https://dev-tfs/tfs/internal_projects/_apis/wit/workitems/405200
        # 422660 https://dev-tfs/tfs/other_projects/_apis/wit/workitems/422660
        $expected.Project1.WorkItemUri = $expected.Project1.ApiProject.ProjectBaseUri + '/_apis/wit/workitems/405200'
        $expected.Project2.WorkItemUri = $expected.Project2.ApiProject.ProjectBaseUri + '/_apis/wit/workitems/422660'

        $expected.Project1.ArtifactUri = @(
            'vstfs:///Git/PullRequestId/', $expected.Project1.Id, '%2f',
            $expected.Project1.RepositoryId, '%2f', '8357'
        ) -join ''

        $expected.Project2.ArtifactUri = @(
            'vstfs:///Git/PullRequestId/', $expected.Project2.Id, '%2f',
            '96e0832a-94a2-4c0c-887e-48b8f3d2e7ed', '%2f', '8636'
        ) -join ''

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -ParameterFilter {
            $Project -eq $expected.Project1.Id
        } -MockWith {
            $collectionConnection = New-ApiCollectionConnection `
                -CollectionUri $expected.Project1.CollectionUri `
                -ApiCredential (New-ApiCredential)
            return New-ApiProjectConnection `
                -ApiCollectionConnection $collectionConnection `
                -ProjectId $expected.Project1.Id
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -ParameterFilter {
            $Project -eq $expected.Project2.Id
        } -MockWith {
            $collectionConnection = New-ApiCollectionConnection `
                -CollectionUri $expected.Project2.CollectionUri `
                -ApiCredential (New-ApiCredential)
            return New-ApiProjectConnection
                -ApiCollectionConnection $collectionConnection `
                -ProjectId $expected.Project2.Id
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "$($expected.Project1.CollectionUri)*"
        } -MockWith {
            return @{
                count = 1
                value = @(
                    @{ id = 1; url = $expected.Project1.WorkItemUri }
                )
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -ParameterFilter {
            $Uri -like "$($expected.Project2.CollectionUri)*"
        } -MockWith {
            return @{
                count = 1
                value = @(
                    @{ id = 2; url = $expected.Project2.WorkItemUri }
                )
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {
            throw [System.NotImplementedException]
        }
    }

    It 'Should return the correct number of work item references' {

        $result = @($expected.Project1.ArtifactUri, $expected.Project2.ArtifactUri) `
        | Get-WorkItemRefsListByArtifactUri

        $result.Count | Should -Be 2
        $result[0].url | Should -Be $expected.Project1.WorkItemUri
        $result[1].url | Should -Be $expected.Project2.WorkItemUri
    }
}
