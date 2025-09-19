function Update-PatchDocumentTags {

    <#
        .SYNOPSIS
            Updates tags in a JSON Patch document.

        .DESCRIPTION
            Updates tags in a JSON Patch document.

        .PARAMETER Document
            JSON Patch document.

        .PARAMETER Tags
            Tags to set on the the work item. If specified,
            overrides any existing tags on the work item.
            Accepts array of strings. Any of given string may be tags joined with semicolons
            (as stored on Azure DevOps Server).

        .PARAMETER Add
            Tags to add to the work item.

        .PARAMETER Remove
            Tags to remove from the work item.

        .PARAMETER UseRegexPatterns
            Flag, whether to use regex patterns to match tags.
            If specified, $Remove are treated as regex patterns.
            Otherwise $Remove are treated as like patterns.
            Default is false.
    #>

    [CmdletBinding()]
    param(
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ApiWitPatchDocument')]
        [Alias('Document')]
        $PatchDocument,
        [string[]] $Tags = @(),
        [Alias('AddTags','ToAdd')]
        [string[]] $Add = @(),
        [Alias('RemoveTags', 'ToRemove')]
        [string[]] $Remove = @(),
        [switch] $UseRegexPatterns
    )

    begin {
        # Determine the patch item operation for the new tags
        # based on whether the document is for creating or updating a work item
        if ($PatchDocument.WorkItemUrl) {
            $newTagsPatchItemOperation = 'replace'
        } else {
            $newTagsPatchItemOperation = 'add'
        }
    }

    process {
        # Find tags patch item
        $tagsPatchItem = $PatchDocument.Operations `
        | Where-Object { $_.path -eq '/fields/System.Tags' } `
        | Select-Object -First 1

        # If tags patch item does not exist, create it
        if (-not $tagsPatchItem) {
            $tagsPatchItem = [PSCustomObject] @{
                # add / replace depending on Create / Update
                op    = $newTagsPatchItemOperation
                path  = '/fields/System.Tags'
                from  = $null
                value = $SourceWorkItem.fields.'System.Tags'
            }
            $PatchDocument.Operations += $tagsPatchItem
        }

        # Set starting value
        if (!$Tags) {
            $Tags = $tagsPatchItem.value
        }
        $values = @(
            $Tags `
            | Where-Object { $_ } `
            | ForEach-Object { $_ -split ';' } `
            | ForEach-Object { $_.Trim() } `
            | Where-Object { $_ }
        )

        # Add tags
        foreach ($tag in $Add) {
            if ($values -notcontains $tag) {
                $values += $tag
            }
        }

        # Remove tags
        if ($UseRegexPatterns) {
            foreach ($tag in $Remove) {
                if ($values -match $tag) {
                    $values = $values | Where-Object { $_ -ne $tag }
                }
            }
        } else {
            foreach ($tag in $Remove) {
                if ($values -like $tag) {
                    $values = $values | Where-Object { $_ -ne $tag }
                }
            }
        }

        # Update tags patch item
        $tagsPatchItem.value = $values -join '; '
    }
}
