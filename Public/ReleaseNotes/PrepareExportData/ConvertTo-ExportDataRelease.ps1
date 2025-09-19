function ConvertTo-ExportDataRelease {

    <#
        .SYNOPSIS
            Converts set of ReleaseNotesDataItems to ExportData - Release subset.
            Result represents the metadata of the exported data.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_Collection (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Name or identifier of a project in the $Collection.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateFrom
            Starting date & time of the time period.
            If not specified, $global:AzureDevOpsApi_DefaultFromDate (set by Set-AzureDevopsVariables) is used.

        .PARAMETER DateTo
            Ending date & time of the time period.
            If not specified, [DateTime]::UTCNow is used.

        .PARAMETER AsOf
            Reference date and time in UTC.
            Objects are listed in the state they were in at this date and time.

        .PARAMETER ByUser
            Only pull requests created by given users will be returned.

        .PARAMETER TargetBranch
            Target branch in the target repository.

        .PARAMETER TrunkBranch
            The trunk branch of TFVC repositories.

        .PARAMETER ReleaseBranch
            The release branch of TFVC repositories.
    #>

    [OutputType('PSTypeNames.AzureDevOpsApi.ExportDataRelease')]
    [CmdletBinding()]
    param(
        $CollectionUri,
        $Project,
        $DateFrom,
        $DateTo,
        $AsOf,
        [Alias('CreatedBy')]
        $ByUser,
        $TargetBranch,
        $TrunkBranch,
        $ReleaseBranch
    )

    process {

        # Correct inputs
        $CollectionUri = Use-CollectionUri -CollectionUri $CollectionUri
        $Project = Use-Project -Project $Project
        $DateFrom = Use-FromDateTime -Value $DateFrom
        $DateTo = Use-ToDateTime -Value $DateTo
        $AsOf = Use-AsOfDateTime -Value $AsOf -DateTo $DateTo

        # Determine current user
        # on linux
        $user = $env:USER
        if (!$user) {
            # on windows
            $user = $env:USERNAME
        }

        # Create result object
        $result = [PSCustomObject] @{
            PSTypeName       = 'PSTypeNames.AzureDevOpsApi.ExportDataRelease'
            Collection       = $CollectionUri
            Project          = $Project
            ProjectPortalUrl = "$($CollectionUri)/$($Project)"
            DateFrom         = $DateFrom
            DateTo           = $DateTo
            AsOf             = $AsOf
            ByUser           = $ByUser
            CreatedDate      = Get-Date
            CreatedBy        = $user
        }

        if ($TargetBranch) {
            $result | Add-Member -MemberType NoteProperty -Name TargetBranch -Value $TargetBranch
        }

        if ($TrunkBranch) {
            $result | Add-Member -MemberType NoteProperty -Name TrunkBranch -Value $TrunkBranch
        }

        if ($ReleaseBranch) {
            $result | Add-Member -MemberType NoteProperty -Name ReleaseBranch -Value $ReleaseBranch
        }

        # Return result
        $result
    }
}
