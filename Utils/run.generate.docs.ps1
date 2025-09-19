#requires -version 5
#requires -modules 'PlatyPS'
# https://learn.microsoft.com/en-us/powershell/utility-modules/platyps/create-help-using-platyps?view=ps-modules

$ModuleName = 'AzureDevOpsApi'
$rootPath = Join-Path -Path $PSScriptRoot -ChildPath '..'
$modelePath = Join-Path -Path $rootPath -ChildPath "$ModuleName.psd1"

Import-Module -Force -Name $modelePath

$OutputFolder = Join-Path -Path $rootPath -ChildPath 'Docs\functions'
$helpFilesPath = Join-Path -Path $OutputFolder -ChildPath '*.md'

if (-not (Test-Path -Path $helpFilesPath -PathType Leaf)) {

    $parameters = @{
        Module                = $ModuleName
        OutputFolder          = $OutputFolder
        AlphabeticParamsOrder = $true
        WithModulePage        = $true
        ExcludeDontShow       = $true
        Encoding              = [System.Text.Encoding]::UTF8
    }

    New-MarkdownHelp @parameters
    # New-ExternalHelp -Path $OutputFolder -OutputPath $rootPath\..\Help\en-US\
    New-MarkdownAboutHelp -OutputFolder $OutputFolder -AboutName "topic_name"

} else {

    $parameters = @{
        Path                  = $OutputFolder
        RefreshModulePage     = $true
        AlphabeticParamsOrder = $true
        UpdateInputOutput     = $true
        ExcludeDontShow       = $true
        LogPath               = 'docs.log'
        Encoding              = [System.Text.Encoding]::UTF8
    }

    Update-MarkdownHelpModule @parameters

}
