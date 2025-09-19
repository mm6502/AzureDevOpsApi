# Function adds or sets a query parameter in given URI
function Add-QueryParameter {

    <#
        .SYNOPSIS
            Adds or sets a query parameter in the given URI.

        .DESCRIPTION
            This function takes a URI and a hashtable of parameters, and adds or sets the specified
            parameters in the query string of the URI.

        .PARAMETER Uri
            The URI to add or set the query parameters in.

        .PARAMETER Parameters
            A hashtable or PSCustomObject of key-value pairs representing the query parameters to add or set.

        .EXAMPLE
            $uri = "https://example.com/xyz/?a=1&b=2"
            $params = @{ c = 3; d = 4 }
            $newUri = Add-QueryParameter -Uri $uri -Parameters $params
            # $newUri will be "https://example.com/xyz?a=1&b=2&c=3&d=4"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $Uri,

        [Parameter(Mandatory = $true, Position = 1)]
        $Parameters
    )

    process {

        return Format-Uri -Uri $Uri -Parameters $Parameters -NoTrailingSlash:$true

    }
}

Set-Alias -Name Add-QueryParametersToUri -Value Add-QueryParameter
