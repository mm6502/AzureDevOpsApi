function Format-Uri {

    <#
        .SYNOPSIS
            Normalizes the given Uri of an Azure DevOps Rest Api.
            Ends all uris with a '/' character.
            Adds or sets query parameters.

        .DESCRIPTION
            This function takes a Uri and a hashtable of parameters.
            It normalizes the given Uri and adds or sets the specified query parameters in the
            query string of the Uri.
            End all Uri paths with a '/' character.

        .PARAMETER Uri
            The Uri to to normalize and add or set the query parameters in.

        .PARAMETER NoTrailingSlash
            If specified, the trailing slash is removed from the Uri.

        .PARAMETER Parameters
            An optional hashtable or PSCustomObject of key-value pairs representing the query parameters to add or set.

        .EXAMPLE
            $uri = "https://example.com?a=1&b=2"
            $params = @{ c = 3; d = 4 }
            $newUri = Add-QueryParameter -Uri $uri -Parameters $params

            $newUri will be "https://example.com?a=1&b=2&c=3&d=4"
    #>

    [CmdletBinding(DefaultParameterSetName = 'Parameters')]
    param(
        [Parameter(ParameterSetName = 'Pipeline', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'Parameters', Mandatory, Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        $Uri,

        [Parameter(ParameterSetName = 'Parameters', Position = 1)]
        [AllowNull()]
        $Parameters,

        [Parameter(ParameterSetName = 'Pipeline')]
        [Parameter(ParameterSetName = 'Parameters')]
        [Alias('RemoveTrailingSlash','LastSegment')]
        [switch] $NoTrailingSlash
    )

    process {

        # if $null or empty, return empty string
        if ([string]::IsNullOrWhiteSpace($Uri)) {
            return [string]::Empty
        }

        # If it's a string
        if ($Uri -is [string]) {

            $Uri = $Uri.Trim()

            # replace all instances of '\' by '/' up to first '?' or '#' character
            $index = $Uri.IndexOfAny('?#')
            if ($index -ne -1) {
                $Uri = $Uri.Substring(0, $index).Replace('\', '/') + $Uri.Substring($index)
            } else {
                $Uri = $Uri.Replace('\', '/')
            }

            $original = $Uri

            # If it's a relative URI, convert it to an absolute URI using random root
            if ([Uri]::IsWellFormedUriString($Uri, [UriKind]::Relative)) {
                $root = [System.Uri]::new("https://www." + [guid]::NewGuid().ToString("D") + ".tmp")
                $Uri = [System.Uri]::new($root, $Uri, $true)
            } else {
                $Uri = [System.Uri]::new($Uri, $true)
            }
        } else {
            $original = $Uri.OriginalString
        }

        # otherwise
        # - replace all instances of '\' by '/'
        # - trim whitespace
        # - trim trailing '/','\','?' characters
        # - add back single trailing '/'
        # $Uri = $Uri.Replace('\', '/')
        $builder = [UriBuilder]::new($Uri)
        $builder.Path = $builder.Path.Trim()
        $builder.Path = $builder.Path.Replace('\', '/')
        $builder.Path = $builder.Path.Replace('//', '/')
        $builder.Path = $builder.Path.Trim('/')

        # If requested no trailing slash, do not add it back
        if (!$NoTrailingSlash.IsPresent -or ($NoTrailingSlash -eq $false)) {
            if (!$builder.Path.EndsWith('/')) {
                $builder.Path += '/'
            }
        }

        # Remove the port, if it's the default port
        if ($Uri.IsDefaultPort) {
            $builder.Port = -1
        }

        # Parse the query string
        $query = [System.Web.HttpUtility]::ParseQueryString($Uri.Query)

        # Set the parameters
        if ($Parameters) {
            if ($Parameters -is [hashtable]) {
                foreach ($key in $Parameters.Keys) {
                    $query.Set($key, $Parameters[$key])
                }
            } elseif ($Parameters -is [PSCustomObject]) {
                foreach ($key in $Parameters.PSObject.Properties.Name) {
                    $query.Set($key, $Parameters.$key)
                }
            }
        }

        # Set the Query property
        $builder.Query = $query.ToString()
        $builder.Query = $builder.Query.Trim()
        $builder.Query = $builder.Query.Trim('?')

        # If it's an absolute Uri, just return it
        if (!$root) {
            # The original path was absolute, so just return the absolute URI
            return $builder.Uri.AbsoluteUri
        }

        # The original path was relative, so we need to make it relative again
        $result = [string]::Empty

        # If the original path starts with a slash, we should add it back...
        # Actually no. In example:
        # $baseUri = 'http://www.dev-tfs.org/tfs/internal_projects/'
        # $relative '/_apis/projects'
        # We want the result be:
        # 'http://www.dev-tfs.org/tfs/internal_projects/_apis/projects'
        # We don't want the result to be:
        # 'http://www.dev-tfs.org/_apis/projects/'
        # Which it would be when aplying the normal rules - relative path starting with a slash
        # means 'from the root of the base Uri'.
        if ($original.StartsWith('/')) {
            # DO NOT add the slash
            # $result = '/'
        }

        # Add the relative path
        $result += $root.MakeRelativeUri($builder.Uri).OriginalString

        $result
    }
}
