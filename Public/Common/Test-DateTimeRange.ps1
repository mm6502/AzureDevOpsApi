function Test-DateTimeRange {

    <#
        .SYNOPSIS
            Decides whether given $Value is in range <$From, $To>.

        .PARAMETER Value
            Date & Time value we want to test.
            If it is $null, the function returns $false.

        .PARAMETER From
            Interval start.
            Default value is $global:AzureDevOpsApi_DefaultFromDate or '2000-01-01T00:00:00Z'.

        .PARAMETER To
            Interval end.
            Default value is UTCNow.
    #>

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [Nullable[DateTime]] $Value,
        [Nullable[DateTime]] $From,
        [Nullable[DateTime]] $To
    )

    process {

        # If the tested value is $null, it does not satisfy
        if ($null -eq $Value) {
            return $false
        }

        # If the interval start is not specified, use the default value:
        if ($null -eq $From) {
            $From = $global:AzureDevOpsApi_DefaultFromDate
            if (($null -eq $From) -or (-not ($From -is [DateTime]))) {
                $From = [DateTime]::new(2000, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
            }
        }

        # If the interval end is not specified, use the current time:
        if ($null -eq $To) {
            $To = [DateTime]::UtcNow
        }

        # Make sure all times are in UTC:
        # https://learn.microsoft.com/en-us/dotnet/api/system.datetime.compare?view=net-8.0#remarks
        if ($Value.Kind -ne [DateTimeKind]::Utc) {
            $Value = $Value.ToUniversalTime()
        }
        if ($From.Kind -ne [DateTimeKind]::Utc) {
            $From = $From.ToUniversalTime()
        }
        if ($To.Kind -ne [DateTimeKind]::Utc) {
            $To = $To.ToUniversalTime()
        }

        # Test if the value is in range:
        return ($From -le $Value) -and ($Value -le $To)
    }
}
