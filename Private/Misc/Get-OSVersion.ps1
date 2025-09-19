function Get-OSVersion {

    <#
        .SYNOPSIS
            Returns the Operating System version of current Powershell runtime.
            Wraps expression [System.Environment]::OSVersion as a function for unit test mocks.
    #>

    [System.Environment]::OSVersion
}
