BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-DefaultWorkItemRelationDescriptorsList' {

    It 'Should return a list of WorkItemRelationDescriptor objects' {
        $result = Get-DefaultWorkItemRelationDescriptorsList
        $result | Should -Not -BeNullOrEmpty
        $result | ForEach-Object { $_ | Should -BeOfType [PSCustomObject] }
        $result | ForEach-Object {
            $_.PSObject.TypeNames | Should -Contain 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
        }
    }

}
