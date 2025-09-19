function Get-Identity {

    <#
        .SYNOPSIS
            Returns detail of requested identity.

        .PARAMETER CollectionUri
            Url for project collection on Azure DevOps server instance.
            If not specified, $global:AzureDevOpsApi_CollectionUri (set by Set-AzureDevopsVariables) is used.

        .PARAMETER User
            User name od identifier to get the identity for.
    #>

    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Uri')]
        $CollectionUri,

        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $User
    )

    process {

        # Get connection object from Collection URI
        $connection = Get-ApiCollectionConnection `
            -Uri $CollectionUri

        # Process all requested identitties
        foreach ($item in $User) {

            $identityId = $null

            # if actually given identity ID, parse it
            if ($item -is [guid]) {
                $identityId = $item.ToString('D')
            } else {
                $tmp = [guid]::Empty;
                if ([guid]::TryParse($item, [ref] $tmp)) {
                    $identityId = $tmp.ToString('D')
                }
            }

            # try to find the identity
            if ($identityId) {
                # GET https://dev-tfs/tfs/{collection}/_apis/identities
                # ?identityIds=81fa638908726fdda4517ba7880f566a,7c86b535818b423fb0fd19a2e9f32710
                # &queryMembership=None&api-version=6.0
                $uri = Join-Uri `
                    -Base $connection.CollectionUri `
                    -Relative "_apis/identities?queryMembership=None&identityIds=$($identityId)" `
                    -NoTrailingSlash
            } else {
                # GET https://dev-tfs/tfs/{collection}/_apis/identities
                # ?searchFilter=General&queryMembership=None&filterValue={user}&api-version=5.0
                $uri = Join-Uri `
                    -Base $connection.CollectionUri `
                    -Relative "_apis/identities?queryMembership=None&searchFilter=General&filterValue=$($item)" `
                    -NoTrailingSlash
            }

            # Make the call
            Invoke-ApiListPaged `
                -ApiCredential $connection.ApiCredential `
                -ApiVersion $connection.ApiVersion `
                -Uri $uri
        }
    }
}
