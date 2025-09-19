function Show-Parameters {

    <#
        .SYNOPSIS
            Shows given parameters in a readable format.

        .EXAMPLE
            Show-Parameters -Parameters $MyInvocation.BoundParameters
    #>

    [CmdletBinding()]
    param(
        $Parameters
    )

    process {
        $understoodParameters = [PSCustomObject] @{ }

        foreach ($key in $Parameters.Keys) {
            $understoodParameters | Add-Member -MemberType NoteProperty -Name $key -Value $Parameters[$key]
        }

        $understoodParameters | Format-List | Out-Host
    }
}
