# Define common type names used across the module
# This helps avoid hardcoding type names in multiple places and reduces typos.
$global:PSTypeNames = [PSCustomObject] @{
    AzureDevOpsApi = [PSCustomObject] @{
        ApiCollection           = 'PSTypeNames.AzureDevOpsApi.ApiCollection'
        ApiCollectionConnection = 'PSTypeNames.AzureDevOpsApi.ApiCollectionConnection'
        ApiCredential           = 'PSTypeNames.AzureDevOpsApi.ApiCredential'
        ApiProject              = 'PSTypeNames.AzureDevOpsApi.ApiProject'
        ApiProjectConnection    = 'PSTypeNames.AzureDevOpsApi.ApiProjectConnection'
        ReleaseNotesDataItem         = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
        ReleaseNotesDataItemRelation = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItemRelation'
        WorkItemRelationDescriptor   = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'
        ExportDataConsoleItem        = 'PSTypeNames.AzureDevOpsApi.ExportDataConsoleItem'
        ExportDataRelationItem       = 'PSTypeNames.AzureDevOpsApi.ExportDataRelationItem'
        ExportData                   = 'PSTypeNames.AzureDevOpsApi.ExportData'
        ApiWitPatchDocument          = 'PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument'

        # Test Case Management
        TcmTestCaseFileInput  = 'PSTypeNames.AzureDevOpsApi.TcmTestCaseFileInput'
        TcmTestCase           = 'PSTypeNames.AzureDevOpsApi.TcmTestCase'
    }
}
