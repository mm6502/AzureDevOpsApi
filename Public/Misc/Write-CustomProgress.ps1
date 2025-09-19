function Write-CustomProgress {

    <#
        .SYNOPSIS
            Reports progress with item count and percent complete.

        .PARAMETER Activity
            Activity description.

        .PARAMETER Status
            Activity status.

        .PARAMETER Id
            Current Activity ID.

        .PARAMETER ParentId
            Parent Activity ID.

        .PARAMETER AllItems
            Collection items to process.

        .PARAMETER CurrentItem
            Current item being processed.

        .PARAMETER Count
            Total number of items to process.

        .PARAMETER Index
            Current item index.

        .PARAMETER NoPercent
            If $true, suppress showing percent complete.

        .PARAMETER NoCount
            If $true, suppress showing item count.

        .EXAMPLE
            $list1 = @(1, 2, 3)
            $list2 = @('a', 'b', 'c')

            foreach ($i in $list1) {

                Write-CustomProgress `
                    -Activity "A$($i)" `
                    -Status "S$($i)" `
                    -AllItems $list1 `
                    -Current $i

                foreach ($j in $list2) {

                    Write-CustomProgress `
                        -Activity "B$($j)" `
                        -Status "T$($j)" `
                        -AllItems $list2 `
                        -ParentId 1 `
                        -Current $j `

                    Start-Sleep -Milliseconds 200
                }
            }
    #>

    [CmdletBinding()]
    param(
        $Activity,

        $Status,

        [int] $ParentId = -1,

        [int] $Id = 0,

        [Parameter(ParameterSetName = 'Collection')]
        [Alias('Items')]
        $AllItems,

        [Parameter(ParameterSetName = 'Collection')]
        [Alias('Current')]
        $CurrentItem,

        [Parameter(ParameterSetName = 'Count')]
        [int] $Count = 0,

        [Parameter(ParameterSetName = 'Count')]
        [int] $Index = 0,

        [switch] $NoPercent,

        [switch] $NoCount,

        [switch] $NoProgress
    )

    begin {
        if ($NoProgress.IsPresent -and ($true -eq $NoProgress)) {
            return
        }
    }

    process {

        $params = @{
            Activity = $Activity
            Status   = $null
            ParentId = $ParentId
            Id       = $ParentId + 1
        }

        if (!$AllItems -and !$Count) {
            $NoPercent = $true
            $NoCount = $true
        }

        if ($PSCmdlet.ParameterSetName -eq 'Collection') {
            # Get the index and count
            $index = 0
            $count = 0
            if ($AllItems -is [System.Collections.ICollection]) {
                # AllItems is collection
                $index = $AllItems.IndexOf($CurrentItem)
                $count = $AllItems.Count
            }
        }

        if (!$NoCount.IsPresent -or ($true -ne $NoCount)) {
            $countString = '{0:n0}/{1:n0}' -f ($index + 1), $count
        }

        if ($count -eq 0) {
            $percent = 100.00
        } else {
            $percent = ($index * 100.0) / ($count + 0.0)
        }

        if (!$NoPercent.IsPresent -or ($true -ne $NoPercent)) {
            $params['PercentComplete'] = $percent
            $percentString = '{0,6:0.00}%' -f $percent
        }

        $statusString = ''

        if ($countString) {
            $statusString += $countString
        }

        if ($percentString) {
            if ($statusString) {
                $statusString += ' - '
            }
            $statusString += $percentString
        }

        if ($Status) {
            if ($statusString) {
                $statusString += ' - '
            }
            $statusString += $Status
        }

        $params['Status'] = $statusString

        Write-Progress @params
    }
}
