BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-SubscriptionsList' {

    BeforeEach {
        # Reset retry configuration to ensure consistent test environment
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount = 3
            RetryDelay = 1.0
            DisableRetry = $false
            MaxRetryDelay = 30.0
            UseExponentialBackoff = $true
            UseJitter = $true
        }
    }

    BeforeAll {
        $collectionConnection = New-TestApiCollectionConnection
        $projectConnection = New-TestApiProjectConnection

        # Mock dependencies
        Mock -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -MockWith {
            @(
                [PSCustomObject] @{
                    PublisherInputs = @{ projectId = $projectConnection.ProjectId }
                    id              = "sub1"
                }
                [PSCustomObject] @{
                    PublisherInputs = @{ projectId = "project2" }
                    id              = "sub2"
                }
                [PSCustomObject] @{
                    PublisherInputs = @{ projectId = "project3" }
                    id              = "sub3"
                }
            )
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiCollectionConnection -MockWith {
            $collectionConnection
        }

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            $projectConnection
        }
    }

    Context 'When no project is specified' {
        It 'Returns all subscriptions from collection' {
            $result = @(Get-SubscriptionsList)
            $result.Count | Should -Be 3
            Should -Invoke -ModuleName $ModuleName -CommandName Invoke-ApiListPaged -Times 1
        }
    }

    Context 'When empty project collection is provided' {
        It 'Should return all subscriptions in collection' {
            $result = @(Get-SubscriptionsList -Project @())
            $result.Count | Should -Be 3
        }
    }

    Context 'When single project is specified' {
        It 'Returns filtered subscriptions for project' {
            $result = @(Get-SubscriptionsList -Project $projectConnection.ProjectName)
            # Use PowerShell 5 compatible count check
            $result.Count | Should -Be 1
            $result[0].PublisherInputs.projectId | Should -Be $projectConnection.ProjectId
        }
    }

    Context 'When paging parameters are specified' {
        It 'Returns paged results' {
            $result = @(Get-SubscriptionsList -Top 1 -Skip 1)
            # Use PowerShell 5 compatible count check
            $result.Count | Should -Be 1
            $result[0].id | Should -Be "sub2"
        }
    }

    Context 'When collection URI is specified' {
        It 'Uses specified collection URI' {
            $result = @(Get-SubscriptionsList -CollectionUri $collectionConnection.CollectionUri)
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiCollectionConnection -ParameterFilter {
                $Uri -eq $collectionConnection.CollectionUri
            }
        }
    }

    Context 'When multiple projects are specified' {
        It 'Returns subscriptions from all projects' {
            $projects = @("Project1", "Project2")
            $null = @(Get-SubscriptionsList -Project $projects)
            Should -Invoke -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -Times 2
        }
    }
}
