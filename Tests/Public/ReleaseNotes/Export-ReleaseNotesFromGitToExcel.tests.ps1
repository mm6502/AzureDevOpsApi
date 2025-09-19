[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Export-ReleaseNotesFromGitToExcel' {
    BeforeAll {

        $expected = [PSCustomObject] @{
            CollectionUri = 'https://dev.azure.com/myorg'
            Project = 'MyProject'
            ApiCredential = [PSCustomObject]@{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.ApiCredential'
                Username   = 'user@example.com'
                Token      = 'mockToken'
            }
            DateFrom = [DateTime]::Parse('2021-02-03T01:02:03Z').ToUniversalTime()
            DateTo   = [DateTime]::Parse('2022-03-04T02:03:04Z').ToUniversalTime()
            AsOf     = [DateTime]::Parse('2023-04-05T03:04:05Z').ToUniversalTime()
            ByUser = 'user@example.com'
            TargetRepository = 'MyRepo'
            TargetBranch = 'main'
            Path = '.\ReleaseNotes.xlsx'
        }

        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByPullRequest -MockWith { @() }
        Mock -ModuleName $ModuleName -CommandName Add-WorkItemToReleaseNotesData -MockWith { @() }
        Mock -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByTimePeriod -MockWith { @() }
        Mock -ModuleName $ModuleName -CommandName ConvertTo-ExportData -MockWith {
            [PSCustomObject] @{
                PSTypeName = 'PSTypeNames.AzureDevOpsApi.ExportData'
            }
        }
        Mock -ModuleName $ModuleName -CommandName Export-Excel -MockWith { $expected.Path }
        Mock -ModuleName $ModuleName -CommandName Show-Host -MockWith { }
        Mock -ModuleName $ModuleName -CommandName Out-Host -MockWith { }
    }

    It 'Should call callect data using correct parameters' {
        # Act
        $result = Export-ReleaseNotesFromGitToExcel `
            -CollectionUri $expected.CollectionUri `
            -Project $expected.Project `
            -DateFrom $expected.DateFrom `
            -DateTo $expected.DateTo `
            -AsOf $expected.AsOf `
            -ByUser $expected.ByUser `
            -TargetRepository $expected.TargetRepository `
            -TargetBranch $expected.TargetBranch `
            -Path $expected.Path `
            -PassThru

        # Assert
        $result | Should -Be $expected.Path

        Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByPullRequest -Times 1 -ParameterFilter {
            $a = $CollectionUri -eq $expected.CollectionUri
            $b = $Project -eq $expected.Project
            $c = $TargetRepository -eq $expected.TargetRepository
            $d = $TargetBranch -eq $expected.TargetBranch
            $e = $DateFrom -eq $expected.DateFrom
            $f = $DateTo -eq $expected.DateTo
            $g = $CreatedBy -eq $expected.ByUser
            $z = $a -and $b -and $c -and $d -and $e -and $f -and $g
            $z
        }

        Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByTimePeriod -Times 1 -ParameterFilter {
            $a = $CollectionUri -eq $expected.CollectionUri
            $b = $Project -eq $expected.Project
            $c = $DateFrom -eq $expected.DateFrom
            $d = $DateTo -eq $expected.DateTo
            $e = $AsOf -eq $expected.AsOf
            $z = $a -and $b -and $c -and $d -and $e
            $z
        }

        Should -Invoke -ModuleName $ModuleName -CommandName Add-WorkItemToReleaseNotesData
        Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByTimePeriod
        Should -Invoke -ModuleName $ModuleName -CommandName ConvertTo-ExportData
        Should -Invoke -ModuleName $ModuleName -CommandName Export-Excel
    }

    It 'Should use default values when optional parameters are not provided' {
        # Act
        $null = Export-ReleaseNotesFromGitToExcel

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByPullRequest -Times 1 -ParameterFilter {
            $a = $TargetBranch -eq $expected.TargetBranch
            $b = $FromCommits -eq $false
            $z = $a -and $b
            $z
        }

        Should -Invoke -ModuleName $ModuleName -CommandName Export-Excel -Times 1 -ParameterFilter {
            $Path -eq '.\'
        }
    }

    It 'Should handle FromCommits switch correctly' {
        # Act
        $null = Export-ReleaseNotesFromGitToExcel -FromCommits

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Get-WorkItemRefsListByPullRequest -Times 1 -ParameterFilter {
            $FromCommits -eq $true
        }
    }

    It 'Should pass Show and PassThru parameters to Export-Excel' {
        # Act
        $null = Export-ReleaseNotesFromGitToExcel -Show -PassThru

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Export-Excel -Times 1 -ParameterFilter {
            $a = $Show -eq $true
            $b = $PassThru -eq $true
            $z = $a -and $b
            $z
        }
    }

    It 'Should use UseConstantFileName when specified' {
        # Act
        $null = Export-ReleaseNotesFromGitToExcel -UseConstantFileName

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Export-Excel -Times 1 -ParameterFilter {
            $UseConstantFileName -eq $true
        }
    }

    It 'Should handle custom TimeZone' {
        # Arrange
        $customTimeZone = 'Europe/London'

        # Act
        $null = Export-ReleaseNotesFromGitToExcel -TimeZone $customTimeZone

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Export-Excel -Times 1 -ParameterFilter {
            $TimeZone -eq $customTimeZone
        }
    }
}
