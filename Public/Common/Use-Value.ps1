function Use-Value {

    <#
        .SYNOPSIS
            Returns the first non-empty value.

        .DESCRIPTION
            Returns the first non-empty value. If both values are empty, returns null.

        .PARAMETER ValueA
            First value to check.

        .PARAMETER ValueB
            Second value to check.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Parameters')]
    param(
        [Parameter(ParameterSetName = 'PipeLine', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'Parameters', Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Alias('A','InputObject')]
        $ValueA,

        [Parameter(ParameterSetName = 'PipeLine', Mandatory, Position = 0)]
        [Parameter(ParameterSetName = 'Parameters', Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Alias('B')]
        $ValueB
    )

    process {
        if ($ValueA) {
            return $ValueA
        }

        return $ValueB
    }
}
