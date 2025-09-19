function Use-PagingParameters {
    <#
        .SYNOPSIS
            Returns paging parameters for iterating through a list of records.

        .DESCRIPTION
            Returns paging parameters for iterating through a list of records.

        .PARAMETER Top
            Count of records to return.

        .PARAMETER Skip
            Count of records to skip before returning the $Top count of records.

        .PARAMETER PageSize
            Count of records per page.

        .EXAMPLE
            $paging = Use-PagingParameters -Top 100 -Skip 0
            $paging.PageSize
            $paging.Top
            $paging.Skip
            $paging.ShouldPage

        .EXAMPLE
            $paging = Use-PagingParameters -PageSize 500
            $paging.PageSize
            $paging.Top
            $paging.Skip
            $paging.ShouldPage
    #>
    param (
        $Top,
        $Skip,
        $PageSize = 100
    )

    process {

        # If Paging is not driven by caller, iterate through the records
        $hasSkip = $PSBoundParameters.ContainsKey('Skip') -and ($null -ne $Skip)
        $hasTop = $PSBoundParameters.ContainsKey('Top') -and ($null -ne $Top) -and ($Top -gt 0)
        $ShouldPage = $hasTop

        # Set default value for $PageSize
        if (!$PageSize) {
            $PageSize = 100
        }

        # Set default values for $Skip and $Top
        if (!$hasSkip) {
            $Skip = 0
        }

        # If we have to iterate, set default value for $Top (page size)
        if (!$hasTop) {
            $Top = $PageSize
        }

        # Return the paging parameters
        return [PSCustomObject] @{
            PageSize = $PageSize
            Top = $Top
            Skip = $Skip
            ShouldPage = $ShouldPage
        }
    }
}
