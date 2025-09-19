param(
    [switch] $ForTests
)

# Get public and private function definition files.
$exclude = @()

$Private = @(
    Get-ChildItem `
        -Path "$($PSScriptRoot)\Private" `
        -Include '*.ps1' `
        -Exclude $exclude `
        -Recurse `
        -ErrorAction SilentlyContinue `
    | Sort-Object Name
)

$Public = @(
    Get-ChildItem `
        -Path "$($PSScriptRoot)\Public" `
        -Include '*.ps1' `
        -Exclude $exclude `
        -Recurse `
        -ErrorAction SilentlyContinue `
    | Sort-Object Name
)

# Dot source the Init files
. (Join-Path -Path $PSScriptRoot -ChildPath '.\Init\Init.ps1')

# Dot source the Private and Public files
foreach ($import in @($Private + $Public)) {
    try {
        . $import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName)
# Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.BaseName -Alias *

# For testing purposes export also Private functions
if ($ForTests) {
    Export-ModuleMember -Function $Private.BaseName -Alias *
}
