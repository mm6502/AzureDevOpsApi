---
Module Name: AzureDevOpsApi
Module Guid: {{ Update Module Guid }}
Download Help Link: {{ Update Download Link }}
Help Version: {{ Update Help Version }}
Locale: {{ Update Locale }}
---

# AzureDevOpsApi Module
## Description
{{ Fill in the Description }}

## AzureDevOpsApi Cmdlets
### [Add-ApiCollection](Add-ApiCollection.md)
Creates an object that describes Azure DevOps project collection.

### [Add-ApiCredential](Add-ApiCredential.md)
Creates an object that contains credentials for the Azure DevOps API calls
and stores it in the global cache associated with the collection URI and project.

### [Add-ApiProject](Add-ApiProject.md)
Adds a project to the global cache.

### [Add-QueryParameter](Add-QueryParameter.md)
Adds or sets a query parameter in the given URI.

### [Add-ReleaseNotesDataItemRelation](Add-ReleaseNotesDataItemRelation.md)
Add a link between two given Work Items.

### [Add-WorkItemToReleaseNotesData](Add-WorkItemToReleaseNotesData.md)
Adds the given work items to the release notes data.

### [Add-WorkItemToReleaseNotesDataAddToQueue](Add-WorkItemToReleaseNotesDataAddToQueue.md)
Adds a new item to the download list as well as data for the Release Notes.

### [Assert-HttpResponse](Assert-HttpResponse.md)
{{ Fill in the Synopsis }}

### [ConvertFrom-JsonCustom](ConvertFrom-JsonCustom.md)
Converts the given JSON string to object or hashtable.
This is a wrapper around ConvertFrom-Json that adds the -AsHashTable parameter because:
- PowerShell 5 does not support the -AsHashTable parameter

### [ConvertTo-ApiProject](ConvertTo-ApiProject.md)
Gets Project and CollectionUri and creates from an ApiProject object.
Fills as many properties as possible.

### [ConvertTo-CommitArtifactUriObject](ConvertTo-CommitArtifactUriObject.md)
Converts commit's uri to Artifact Uri usable for ArtifactUriQuery.
Returns CollectionUri and ArtifactUri tuples.

### [ConvertTo-ExportData](ConvertTo-ExportData.md)
Converts set of ReleaseNotesDataItems to ExportData.

### [ConvertTo-ExportDataConsole](ConvertTo-ExportDataConsole.md)
Converts set of ReleaseNotesDataItems to ExportData - Console subset.

### [ConvertTo-ExportDataRelations](ConvertTo-ExportDataRelations.md)
Converts set of ReleaseNotesDataItems to ExportData - Relations subset.

### [ConvertTo-ExportDataRelease](ConvertTo-ExportDataRelease.md)
Converts set of ReleaseNotesDataItems to ExportData - Release subset.
Result represents the metadata of the exported data.

### [ConvertTo-ExportDataWorkItems](ConvertTo-ExportDataWorkItems.md)
Converts set of ReleaseNotesDataItems to ExportData - WorkItems subset.

### [ConvertTo-ExportDataWorkItemsProcessTestsRelations](ConvertTo-ExportDataWorkItemsProcessTestsRelations.md)
Converts set of ReleaseNotesDataItems to ExportData - WorkItems subset.

Evaluates the relations of the given work item and returns distinct
work item states from all work items that are tested by the given work item.

### [ConvertTo-JsonCustom](ConvertTo-JsonCustom.md)
Converts the given object to a JSON string as an array.
This is a wrapper around ConvertTo-Json that adds the -AsArray parameter because:
- the default behavior of ConvertTo-Json is to output a single JSON object
- PowerShell 5 does not support the -AsArray parameter

### [ConvertTo-ParentUrl](ConvertTo-ParentUrl.md)
Converts work item url to parent's url using parent's id.

### [ConvertTo-RegexPattern](ConvertTo-RegexPattern.md)
Converts mask to regex pattern.

### [ConvertTo-TimeZoneDateTime](ConvertTo-TimeZoneDateTime.md)
Converts given date time to the given time zone.

### [Export-DetermineOutputFileName](Export-DetermineOutputFileName.md)
Returns filename for the exported release notes.

### [Export-Excel](Export-Excel.md)
Converts set of ReleaseNotesDataItems to ExportData.

### [Export-ExcelConsole](Export-ExcelConsole.md)
Exports the Console subset.

### [Export-ExcelGetCellAddress](Export-ExcelGetCellAddress.md)
Converts set of ReleaseNotesDataItems to ExportData.

### [Export-ExcelRelations](Export-ExcelRelations.md)
Exports the Relations subset.

### [Export-ExcelRelease](Export-ExcelRelease.md)
Exports the Release subset.

### [Export-ExcelSetHeader](Export-ExcelSetHeader.md)
Set the header for an Excel worksheet.

### [Export-ExcelWorkItems](Export-ExcelWorkItems.md)
Exports work items to an Excel worksheet.

### [Export-MarkDown](Export-MarkDown.md)
Converts set of ReleaseNotesDataItems to MarkDown.

### [Export-MarkDownSection](Export-MarkDownSection.md)
Creates a single MD section for release notes

### [Export-ReleaseNotesFromGitToExcel](Export-ReleaseNotesFromGitToExcel.md)
Runs compilation of release notes data from Git based project.

### [Export-ReleaseNotesFromTfvcToExcel](Export-ReleaseNotesFromTfvcToExcel.md)
Runs compilation of release notes data from TFVC based project.

### [Export-ReleaseNotesFromTimePeriodToMarkDown](Export-ReleaseNotesFromTimePeriodToMarkDown.md)
Runs compilation of release notes data from Git based project and formats it in MarkDown.

### [Find-ApiCollection](Find-ApiCollection.md)
Finds an ApiCollection in the cache by given Uri.

### [Find-ApiCredential](Find-ApiCredential.md)
Finds an API credential in the cache.

### [Format-Date](Format-Date.md)
Converts the given date time to UTC and formats it to the format used in the Azure DevOps API:
'yyyy-MM-ddTHH:mm:ss.fffZ'

### [Format-Uri](Format-Uri.md)
Normalizes the given Uri of an Azure DevOps Rest Api.
End all uris with a '/' character.
Adds or sets query parameters.

### [Get-ApiCollectionConnection](Get-ApiCollectionConnection.md)
Returns new connection object.

Used to determine the correct url for the collection and the correct api version to use
for given Url.

Properties of the returned object are:
- CollectionUri: Url for project collection on Azure DevOps server instance.
- ApiCredential: Default ApiCredential object to use for authentication on given CollectionUri.
- ApiVersion: Version of Azure DevOps API to use.

### [Get-ApiCredentialsList](Get-ApiCredentialsList.md)
Returns a list of known API credentials registered by Add-ApiCredential or Set-ApiVariables.

### [Get-ApiProjectConnection](Get-ApiProjectConnection.md)
Creates a connection object to a project in Azure DevOps.

### [Get-CommitDiffsCount](Get-CommitDiffsCount.md)
Find the closest common commit (the merge base) between base and target commits,
and get the diff count between either the base and target commits or common and target commits.

### [Get-CommitsList](Get-CommitsList.md)
Gets list of all commits meeting given criteria.

### [Get-ConnectionData](Get-ConnectionData.md)
Returns detail of current connection.

### [Get-CurrentUser](Get-CurrentUser.md)
Returns detail of current user connecting to the Azure DevOps server instance.

### [Get-CurrentUserProfile](Get-CurrentUserProfile.md)
Gets Profile of the current user (based on the provided authorization).

### [Get-CustomTimeZone](Get-CustomTimeZone.md)
Returns the time zone for date tiem conversions for export.

### [Get-DefaultWorkItemRelationDescriptorsList](Get-DefaultWorkItemRelationDescriptorsList.md)
Returns a list of work item relationship descriptors.
Defacto configuration of how relationships are crawled
when adding data to release notes.

### [Get-Changeset](Get-Changeset.md)
Returns a changeset.

### [Get-ChangesetsList](Get-ChangesetsList.md)
Gets list of all changesets meeting given criteria.

### [Get-Identity](Get-Identity.md)
Returns detail of requested identity.

### [Get-KnownWorkItemRelationDescriptorsList](Get-KnownWorkItemRelationDescriptorsList.md)
Returns a list of all known work item relationship descriptors.
Used to manipulate work items relationships.

### [Get-Project](Get-Project.md)
Returns detail of a given project.

### [Get-ProjectPropertiesList](Get-ProjectPropertiesList.md)
Gets properties of given project.

### [Get-ProjectsList](Get-ProjectsList.md)
Returns list of projects from given project collection.

### [Get-ProjectTemplateType](Get-ProjectTemplateType.md)
Gets template type of given project.

### [Get-PullRequest](Get-PullRequest.md)
Returns a pull request.

### [Get-PullRequestsList](Get-PullRequestsList.md)
Gets successfully merged pull requests matching given criteria.

### [Get-ReleaseNotesDataFromGit](Get-ReleaseNotesDataFromGit.md)
Gets release notes data from Git based project.

### [Get-ReleaseNotesDataFromTfvc](Get-ReleaseNotesDataFromTfvc.md)
Gets release notes data from TFVC based project.

### [Get-ReleaseNotesDataFromTimePeriod](Get-ReleaseNotesDataFromTimePeriod.md)
Gets release notes data from Git based project.

### [Get-RepositoriesList](Get-RepositoriesList.md)
Gets list of all commits meeting given criteria.

### [Get-Repository](Get-Repository.md)
Returns a repository.

### [Get-SubscriptionsList](Get-SubscriptionsList.md)
Returns list of service hook subscriptions from the specified project.

### [Get-TagsList](Get-TagsList.md)
Gets list of tags used on the work items in given project.

### [Get-WorkItem](Get-WorkItem.md)
Load details of given work items.

### [Get-WorkItemApiUrl](Get-WorkItemApiUrl.md)
Constructs the url for a work item in Azure DevOps API.

### [Get-WorkItemPortalUrl](Get-WorkItemPortalUrl.md)
Work items loaded as revision (e.g.
due to the AsOf parameter)
do not contain a link for editing on the portal.
For these we
need to assemble the link.

### [Get-WorkItemRefsListByArtifactUri](Get-WorkItemRefsListByArtifactUri.md)
Gets list of work item references associated with given artifacts.

### [Get-WorkItemRefsListByChangeset](Get-WorkItemRefsListByChangeset.md)
Return the list of work item ids referenced in given changesets.

### [Get-WorkItemRefsListByPullRequest](Get-WorkItemRefsListByPullRequest.md)
Return the list of work item ids referenced in given pull requests.

### [Get-WorkItemRefsListByTimePeriod](Get-WorkItemRefsListByTimePeriod.md)
Return the list of work items for the release notes / change list.

### [Get-WorkItemType](Get-WorkItemType.md)
Extracts work item type from the given work item.

### [Get-WorkItemTypesList](Get-WorkItemTypesList.md)
Gets list of work items types in given project.

### [Invoke-Api](Invoke-Api.md)
Helper function for calling a web service returning a single object.
For example, for a project detail.

### [Invoke-ApiListPaged](Invoke-ApiListPaged.md)
Calls web API returning paged list of records.
For example to list all PullRequests for a project.

### [Invoke-CurlWebRequest](Invoke-CurlWebRequest.md)
Using curl executable to invoke web request instead of Invoke-WebRequest.

### [Invoke-CustomWebRequest](Invoke-CustomWebRequest.md)
Helper function for calling a web service.

### [Invoke-WorkItemsQuery](Invoke-WorkItemsQuery.md)
Query work items.

### [Join-Uri](Join-Uri.md)
Joins the given base Uri with the given relative Uri.

### [Limit-String](Limit-String.md)
Filters an array of strings to only unique values that match include and exclude filters.
Case sensitivity of the filters can be controlled via the -CaseSensitive switch.

### [New-ApiCollection](New-ApiCollection.md)
Creates an object that describes Azure DevOps project collection.

### [New-ApiCollectionConnection](New-ApiCollectionConnection.md)
Gets an API collection connection object for interacting with the Azure DevOps API.

### [New-ApiCredential](New-ApiCredential.md)
Creates an object that contains credentials for the Azure DevOps API.

### [New-ApiProject](New-ApiProject.md)
Creates a new project object for caching in $global:ApiProjectsCache.

The project object is a PSCustomObject with the following properties:
- CollectionUri      = The URI of the project collection.
- ProjectUri         = The URI of the project.
- ProjectId          = The ID of the project.
- ProjectName        = The name of the project.
- ProjectIdBaseUri   = The base URI of the project scoped apis.
- ProjectNameBaseUri = The base URI of the project scoped apis.

### [New-ApiProjectConnection](New-ApiProjectConnection.md)
Creates a new API project connection object.

### [New-ExportData](New-ExportData.md)
Creates new export data.

### [New-PatchDocumentCreate](New-PatchDocumentCreate.md)
Create a JSON Patch document for creating work item.
The document can be used with New-WorkItem to create work item.

### [New-PatchDocumentRelation](New-PatchDocumentRelation.md)
Adds a relation to a patch document.

### [New-PatchDocumentUpdate](New-PatchDocumentUpdate.md)
Create a JSON Patch document for updating work item.
The document can be used with Update-WorkItem to update work item.

### [New-PullRequest](New-PullRequest.md)
Creates a new pull request for given repo branches, if they differ.
Returns a pull request object if successful,

### [New-ReleaseNotesDataItem](New-ReleaseNotesDataItem.md)
Creates a new entry in both the download list and the release note data list.

### [New-ReleaseNotesDataItemRelation](New-ReleaseNotesDataItemRelation.md)
Creates a new object for recording the session/relationship with other work items.

### [New-WebException](New-WebException.md)
Creates a new web exception object with a custom status code, reason phrase, and message.

### [New-WiqlQueryByTimePeriod](New-WiqlQueryByTimePeriod.md)
Creates a WIQL query that returns all work items of the types given by the WorkItemTypes parameter,
which were switched to the Resolved state in the specified time frame and are in this state
at the query launch or the time specified with AsOf parameter.

### [New-WorkItem](New-WorkItem.md)
Create a new work item.

### [New-WorkItemRelationDescriptor](New-WorkItemRelationDescriptor.md)
Creates a new link descriptor between work items -
object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.

### [Resolve-ApiProject](Resolve-ApiProject.md)
Finds a project in the global cache.

### [Select-ByObjectProperty](Select-ByObjectProperty.md)
Filters objects based on properties.
Uses Test-String for comparison.

### [Select-WorkItemRelationDescriptor](Select-WorkItemRelationDescriptor.md)
Return the link descriptor between work items -
object PSCustomObject with PSTypeName = 'PSTypeNames.AzureDevOpsApi.WorkItemRelationDescriptor'.
For information, see the New-WorkItemRelationDescriptor function.

### [Set-ApiVariables](Set-ApiVariables.md)
Set commonly used parameters for Azure DevOps API calls:
$global:AzureDevOpsApi_DefaultFromDate
$global:AzureDevOpsApi_ApiVersion
$global:AzureDevOpsApi_CollectionUri
$global:AzureDevOpsApi_Project
$global:AzureDevOpsApi_Token

### [Show-ApiCredentialsList](Show-ApiCredentialsList.md)
Displays a list of API credentials.

### [Show-Host](Show-Host.md)
Helper function for writing out text.
Exists only to satisfy script analyzer's rule "PSAvoidUsingWriteHost".

### [Show-Parameters](Show-Parameters.md)
Shows given parameters in a readable format.

### [Split-ApiUri](Split-ApiUri.md)
Splits the given URI of an Azure DevOps collection into the collection URI and the project name.

### [Submit-PullRequests](Submit-PullRequests.md)
Submits pull requests for the specified repositories and branches.

### [Test-DateTimeRange](Test-DateTimeRange.md)
Decides whether given $Value is in range \<$From, $To\>.

### [Test-ObjectProperty](Test-ObjectProperty.md)
Tests if properties of given object match one of given patterns.
Uses Test-String for comparison.

### [Test-String](Test-String.md)
Tests strings for match include and exclude masks.
Case sensitivity can be controlled via the -CaseSensitive switch.

### [Test-StringContains](Test-StringContains.md)
Check if $Haystack contains $Needle.

### [Test-TestWorkItem](Test-TestWorkItem.md)
Decides whether given $WorkItem is a Test Work Item;
i.e.
it has a 'System.WorkItemType' field with value 'Test Case',
or it has a 'System.WorkItemType' field with value 'Requirement'
and Tags field with value like 'Test*'.

### [Test-WebAddress](Test-WebAddress.md)
Tests if the given address looks like a valid web address.

### [Update-PatchDocumentTags](Update-PatchDocumentTags.md)
Updates tags in a JSON Patch document.

### [Update-WorkItem](Update-WorkItem.md)
Updates an axisting work item.

### [Use-ApiCredential](Use-ApiCredential.md)
Determines the API credential to use for given CollectionUri.
If none is provided, tries to find usable credentials
in cached credentials (added by Add-ApiCredential) or default
credential by Set-ApiVariables.

### [Use-ApiVersion](Use-ApiVersion.md)
Gets the ApiVersion to use for given Azure DevOps collection URI.
If the ApiVersion is not determined, it will default to '5.0'

### [Use-AsOfDateTime](Use-AsOfDateTime.md)
Gets the ToDateTime to use for given Azure DevOps collection URI.

### [Use-CollectionUri](Use-CollectionUri.md)
Gets the Azure DevOps collection URI.

### [Use-FromDateTime](Use-FromDateTime.md)
Gets the FromDateTime to use for given Azure DevOps collection URI.

### [Use-PagingParameters](Use-PagingParameters.md)
Returns paging parameters for iterating through a list of records.

### [Use-Project](Use-Project.md)
Coalesce the Project parameter with the global variable.
If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

### [Use-ToDateTime](Use-ToDateTime.md)
Gets the ToDateTime to use for given Azure DevOps collection URI.

### [Use-Value](Use-Value.md)
Returns the first non-empty value.

### [Write-CustomProgress](Write-CustomProgress.md)
Reports progress with item count and percent complete.

