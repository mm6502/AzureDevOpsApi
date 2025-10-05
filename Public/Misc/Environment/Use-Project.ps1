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
        [Alias('Project')]
        $Value
    )

    process {
        if (!$Value) {
            $Value = $global:AzureDevOpsApi_Project
        }

        return $Value
    }
}
