[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Invoke-WorkItemsQuery' {

    BeforeAll {
        $CollectionUri = 'https://dev.azure.com/myorg/'
        $ProjectName = 'myproject'
        $ProjectID = 'abc123'
        $ProjectUri = "$($CollectionUri)_apis/projects/$($ProjectID)"
        $ApiVersion = '5.1-preview.1'
        $ApiCredential = New-ApiCredential
        $Query = @"
    SELECT [System.Id], [System.Title], [System.State]
    FROM WorkItems
    WHERE [System.WorkItemType] = 'Task' AND [State] <> 'Closed' AND [State] <> 'Removed'
    ORDER BY [Microsoft.VSTS.Common.Priority] ASC, [System.CreatedDate] DESC
"@

        Mock -ModuleName $ModuleName -CommandName Write-Verbose -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Write-Warning -MockWith { }
    }

    It 'Should invoke the API with the correct URI and body' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            $collectionConnection = [pscustomobject]@{
                PSTypeName = $global:PSTypeNames.AzureDevOpsApi.ApiCollectionConnection
                CollectionUri = $CollectionUri
                ApiVersion = $ApiVersion
                ApiCredential = $ApiCredential
                ProjectBaseUri = $ProjectUri
            }

            New-ApiProjectConnection `
                -ApiCollectionConnection $collectionConnection `
                -ProjectName $ProjectName `
                -ProjectID $ProjectID `
                -ProjectUri $ProjectUri `
                -ProjectBaseUri $ProjectUri
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith { }

        # Act
        Invoke-WorkItemsQuery `
            -CollectionUri $CollectionUri `
            -Project $ProjectName `
            -Query $Query

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-Api -Times 1 -ParameterFilter {
            ($Uri -eq "$ProjectUri/_apis/wit/wiql?timePrecision=true") `
            -and `
            ($Body -eq (ConvertTo-Json @{ query = $Query })) `
        }
    }

    It 'Should handle null or empty project' {
        # Arrange
        $global:AzureDevOpsApi_Project = "some_project"

        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            @{ ProjectBaseUri = 'https://dev.azure.com/myorg/some_project' }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {}

        # Act & Assert
        {
            Invoke-WorkItemsQuery `
                -CollectionUri $CollectionUri `
                -Project $null `
                -Query $Query
        } | Should -Not -Throw
        {
            Invoke-WorkItemsQuery `
                -CollectionUri $CollectionUri `
                -Project '' `
                -Query $Query
        } | Should -Not -Throw
    }

    It 'Should handle null or empty CollectionUri' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Get-ApiProjectConnection -MockWith {
            @{ ProjectBaseUri = 'https://dev.azure.com/myorg/some_project' }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-Api -MockWith {}

        # Act & Assert
        {
            Invoke-WorkItemsQuery `
                -Project $ProjectName `
                -Query $Query `
        } | Should -Not -Throw
        {
            Invoke-WorkItemsQuery `
                -CollectionUri '' `
                -Project $ProjectName `
                -Query $Query
        } | Should -Not -Throw
    }

    It 'Should throw an error if Query is null or empty' {
        # Act & Assert
        {
            Invoke-WorkItemsQuery `
                -CollectionUri $CollectionUri `
                -Project $ProjectName `
                -Query $null `
        } | Should -Throw
        {
            Invoke-WorkItemsQuery `
                -CollectionUri $CollectionUri `
                -Project $ProjectName `
                -Query '' `
        } | Should -Throw
    }
}
