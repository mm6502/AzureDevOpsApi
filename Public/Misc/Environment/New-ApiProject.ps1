function New-ApiProject {

    <#
        .SYNOPSIS
            Creates a new project object for caching in $global:ApiProjectsCache.

            The project object is a PSCustomObject with the following properties:
            - CollectionUri      = The URI of the project collection.
            - ProjectUri         = The URI of the project.
            - ProjectId          = The ID of the project.
            - ProjectName        = The name of the project.
            - ProjectIdBaseUri   = The base URI of the project scoped apis.
            - ProjectNameBaseUri = The base URI of the project scoped apis.

        .PARAMETER CollectionUri
            The URI of the project collection.
            https://dev-tfs/tfs/internal_projects

        .PARAMETER ProjectUri
            The URI of the project.

        .PARAMETER ProjectId
            The ID of the project.

        .PARAMETER ProjectName
            The name of the project.
    #>

    [CmdletBinding()]
    [OutputType('PSTypeNames.AzureDevOpsApi.ApiProject')]
    param(
        [Parameter()]
        [AllowNull()]
        [string] $CollectionUri,
        [Parameter()]
        [AllowNull()]
        [string] $ProjectUri,
        [Parameter()]
        [AllowNull()]
        [string] $ProjectId,
        [Parameter()]
        [AllowNull()]
        [string] $ProjectName,
        [Parameter()]
        [bool] $Verified
    )

    process {

        if (!$ProjectId -and !$ProjectName) {
            $ProjectName = Use-Project
        }

        if ($ProjectUri) {
            $ProjectUri = Format-Uri -Uri $ProjectUri -NoTrailingSlash
        }

        $result = [PSCustomObject] @{
            PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiProject
            Verified      = $Verified
            CollectionUri = $CollectionUri
            ProjectId     = $ProjectId
            ProjectName   = $ProjectName
        }

        $result | Add-Member -MemberType ScriptProperty -Name ProjectUri -Value {
            if ($ProjectUri) {
                $ProjectUri
            } elseif ($this.ProjectId -and $this.CollectionUri) {
                Join-Uri `
                    -Base $this.CollectionUri `
                    -Relative '_apis/projects',$this.ProjectId `
                    -NoTrailingSlash
            }
        }

        $result | Add-Member -MemberType ScriptProperty -Name ProjectBaseUri -Value {
            if ($this.ProjectId) {
                Join-Uri `
                    -Base $this.CollectionUri `
                    -Relative $this.ProjectId
            }
        }

        $result | Add-Member -MemberType ScriptProperty -Name ProjectIdBaseUri -Value {
            if ($this.ProjectId) {
                Join-Uri `
                    -Base $this.CollectionUri `
                    -Relative $this.ProjectId
            }
        }

        $result | Add-Member -MemberType ScriptProperty -Name ProjectNameBaseUri -Value {
            if ($this.ProjectName) {
                Join-Uri `
                    -Base $this.CollectionUri `
                    -Relative $this.ProjectName
            }
        }

        # Return the result
        return $result
    }
}
