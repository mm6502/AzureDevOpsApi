function Export-DetermineOutputFileName {

    <#
        .SYNOPSIS
            Returns filename for the exported release notes.

        .PARAMETER ExportData
            Export data prepared by ConvertTo-ExportData.

        .PARAMETER Path
            Filename for the exported data to be saved to.

        .PARAMETER UseConstantFileName
            Flag, whether to always use the same filename.
            If Path is a folder, uses constant string for the new file.

        .PARAMETER FileExtension
            File extension for the exported data to be saved to.
    #>

    [CmdletBinding()]
    param(
        [PSTypeName('PSTypeNames.AzureDevOpsApi.ExportData')]
        [Parameter(Mandatory, Position = 1)]
        [Alias('Data')]
        $ExportData,
        $Path,
        $FileExtension,
        [switch] $UseConstantFileName,
        $TimeZone = 'UTC'
    )

    process {

        # Determine the output file name

        # If no path is given, use current directory
        if (!$Path) {
            $Path = ".\"
        }

        # if path is a filename, just return it
        if ($Path -imatch "[.]$($FileExtension)$") {
            return $Path
        }

        if ($TimeZone -is [string]) {
            $TimeZone = Get-CustomTimeZone -Id $TimeZone
        }

        # otherwise it is a folder, so add filename to it
        if ($UseConstantFileName.IsPresent -and ($UseConstantFileName -eq $true)) {
            $filename = "ReleaseNotes.$($FileExtension)"
        } else {
            # get the created date, translate to target time zone
            $datetime = ConvertTo-TimeZoneDateTime `
                -DateTime $ExportData.Release.CreatedDate `
                -TimeZone $TimeZone
            $datetime = '{0:yyyy-MM-dd_HH-mm}' -f ([DateTime] $datetime)
            $filename = "ReleaseNotes_$($ExportData.Release.Project)_$($datetime).$($FileExtension)"
        }

        # return the full path
        Join-Path -Path $Path -ChildPath $filename
    }
}
