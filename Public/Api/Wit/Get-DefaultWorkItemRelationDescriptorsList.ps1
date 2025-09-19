function Get-DefaultWorkItemRelationDescriptorsList {

    <#
        .SYNOPSIS
            Returns a list of work item relationship descriptors.
            Defacto configuration of how relationships are crawled
            when adding data to release notes.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor')]
    [CmdletBinding()]
    param()

    process {

        New-WorkItemRelationDescriptor `
            -Relation     'System.LinkTypes.Hierarchy-Reverse' `
            -FollowFrom   @('Task', 'Bug', 'Requirement', 'Test Case', 'Test Suite', 'Test Plan', 'Feature', 'Change Request') `
            -NameOnSource 'Parent' `
            -NameOnTarget 'Child' `

        New-WorkItemRelationDescriptor `
            -Relation     'System.LinkTypes.Hierarchy-Forward' `
            -NameOnSource 'Child' `
            -NameOnTarget 'Parent' `

        New-WorkItemRelationDescriptor `
            -Relation     'Microsoft.VSTS.Common.Affects-Forward' `
            -FollowFrom   @('Bug', 'Requirement', 'Feature', 'Change Request') `
            -NameOnSource 'Affects' `
            -NameOnTarget 'Affected By' `

        New-WorkItemRelationDescriptor `
            -Relation     'Microsoft.VSTS.Common.Affects-Reverse' `
            -FollowFrom   @() `
            -NameOnSource 'Affected By' `
            -NameOnTarget 'Affects' `

        New-WorkItemRelationDescriptor `
            -Relation     'Microsoft.VSTS.Common.TestedBy-Forward' `
            -FollowFrom   @('Bug', 'Requirement') `
            -NameOnSource 'Tested By' `
            -NameOnTarget 'Tests' `

        New-WorkItemRelationDescriptor `
            -Relation     'Microsoft.VSTS.Common.TestedBy-Reverse' `
            -FollowFrom   @('Bug', 'Requirement') `
            -NameOnSource 'Tests' `
            -NameOnTarget 'Tested By' `

        New-WorkItemRelationDescriptor `
            -Relation     'System.LinkTypes.Dependency-Forward' `
            -FollowFrom   @('Bug', 'Requirement') `
            -NameOnSource 'Predecessor' `
            -NameOnTarget 'Successor' `

        New-WorkItemRelationDescriptor `
            -Relation     'System.LinkTypes.Dependency-Reverse' `
            -FollowFrom   @() `
            -NameOnSource 'Successor' `
            -NameOnTarget 'Predecessor' `

    }
}
