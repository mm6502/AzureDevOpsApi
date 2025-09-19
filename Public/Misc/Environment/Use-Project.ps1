function Use-Project {

    <#
        .SYNOPSIS
            Coalesce the Project parameter with the global variable.
            If not specified, $global:AzureDevOpsApi_Project (set by Set-AzureDevopsVariables) is used.

        .PARAMETER Project
            Name, identifier of a project in the $Collection.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Value')]
        $Project
    )

    process {
        if (!$Project) {
            $Project = $global:AzureDevOpsApi_Project
        }

        return $Project
    }
}
