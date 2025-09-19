function New-ReleaseNotesDataItem {

    <#
        .SYNOPSIS
            Creates a new entry in both the download list and the release note data list.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = ''
    )]
    [OutputType('PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem')]
    [CmdletBinding(DefaultParameterSetName = 'WorkItem')]
    param(
        [Parameter(ParameterSetName = 'Pipeline', Mandatory, ValueFromPipeline)]
        $InputObject,

        [Parameter(ParameterSetName = 'WorkItem')]
        [Alias('WorkItemUrl')]
        $WorkItem
    )

    process {

        # Treat the pipeline input object as work item
        if ($PSCmdlet.ParameterSetName -ne 'Pipeline') {
            $InputObject = @(,$WorkItem)
        }

        # Process all work items
        foreach ($WorkItem in $InputObject) {

            # Get the work item URL
            if ($WorkItem | Test-WebAddress) {
                $WorkItemUrl = $WorkItem
                $WorkItem = $null
            } else {
                $WorkItemUrl = $WorkItem.WorkItem.url
                if (!$WorkItemUrl) {
                    $WorkItemUrl = $WorkItem.url
                }
                if (!$WorkItemUrl) {
                    $WorkItemUrl = $WorkItem
                }
            }

            # Creates a new entry in both the download list and the release note data list
            $item = [PSCustomObject] @{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.ReleaseNotesDataItem'
            }

            # The order of properties when output to the console corresponds to the order in which they were defined
            $item | Add-Member -MemberType ScriptProperty -Name 'WorkItemId' -Value {
                $this.WorkItem.id
            }
            $item | Add-Member -MemberType ScriptProperty -Name 'WorkItemType' -Value {
                $this.WorkItem.fields."System.WorkItemType"
            }

            # Reasons for adding to the release notes list
            $item | Add-Member -MemberType ScriptProperty -Name 'Reasons' -Value { $this.ReasonsList -join ", " }

            # Due to the output to the console - the names of links to other work items and their numbers
            $item | Add-Member -MemberType ScriptProperty -Name 'RelationsCounts' -Value {
                (($this.RelationsList `
                        | Select-Object @{ Name = 'dummy'; Expression = { "$($_.Name) ($($_.Relations.Count))" } } `
                        | Select-Object -ExpandProperty 'dummy') `
                        -join ", "
                )
            }

            # Because of the output to the console - links to other work items
            $item | Add-Member -MemberType ScriptProperty -Name 'Relations' -Value {
                (($this.RelationsList `
                        | Select-Object @{ Name = 'dummy'; Expression = {
                                if ($_.Relations.Count -gt 5) {
                                    $value = 'many'
                                } else {
                                    $value = ($_.Relations | ForEach-Object { $_.ToString() }) -join ', '
                                }
                                "$($_.Name) ($($value))"
                            }
                        } `
                        | Select-Object -ExpandProperty 'dummy') `
                        -join ", "
                )
            }

            # Work item title
            $item | Add-Member -MemberType ScriptProperty -Name 'Title' -Value {
                $this.WorkItem.fields."System.Title"
            }

            # Link to open the work item on the portal
            $item | Add-Member -MemberType ScriptProperty -Name 'PortalUrl' -Value {
                Get-WorkItemPortalUrl -WorkItem $this.WorkItem
            }

            # Link to the work item in the API
            $item | Add-Member -MemberType NoteProperty -Name 'ApiUrl' -Value $WorkItemUrl

            # List of reasons for adding to the release notes list
            $item | Add-Member -MemberType NoteProperty -Name 'ReasonsList' -Value @()

            # Lists of links to other work items, categorized by link name
            $item | Add-Member -MemberType NoteProperty -Name 'RelationsList' -Value @()

            # The work item object itself, as returned by the Azure DevOps Server API
            $item | Add-Member -MemberType NoteProperty -Name 'WorkItem' -Value $WorkItem

            # Flag, whether the work item should be excluded from the release notes
            # (due to custom filter for example)
            $item | Add-Member -MemberType NoteProperty -Name 'Exclude' -Value $false

            $item
        }
    }
}
