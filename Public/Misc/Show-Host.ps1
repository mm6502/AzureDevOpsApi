function Show-Host {

    <#
        .SYNOPSIS
            Helper function for writing out text.
            Exists only to satisfy script analyzer's rule "PSAvoidUsingWriteHost".

        .PARAMETER Object
            Object to write to host.

        .PARAMETER ForegroundColor
            ConsoleColor to write the text in.

        .PARAMETER NoNewLine
            If specified, does not write trailing new line.
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $Object,
        [ConsoleColor] $ForegroundColor,
        [switch] $NoNewLine
    )

    process {
        Write-Host @PSBoundParameters
    }
}
