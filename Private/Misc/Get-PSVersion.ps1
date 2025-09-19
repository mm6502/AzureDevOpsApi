function Get-PSVersion {

    <#
        .SYNOPSIS
            Returns the Major version of current Powershell runtime.
            Wraps expression $PSVersionTable.PSVersion.Major as a function for unit test mocks.
    #>

    $PSVersionTable.PSVersion.Major
}
