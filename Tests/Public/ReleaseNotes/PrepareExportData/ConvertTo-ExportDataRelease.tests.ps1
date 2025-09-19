BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'ConvertTo-ExportDataRelease' {

    It 'Should return a PSCustomObject' {

        # Arrange
        $expected = [PSCustomObject] @{
            Collection    = "https://dev.azure.com/myorg/"
            Project       = "MyProject"
            DateFrom      = [datetime]::Parse("2022-05-01T11:10:10Z").ToUniversalTime()
            DateTo        = [datetime]::Parse("2023-06-02T12:20:20Z").ToUniversalTime()
            AsOf          = [datetime]::Parse("2024-07-03T13:30:30Z").ToUniversalTime()
            CreatedDate   = [datetime]::Parse("2025-08-04T14:40:40Z").ToUniversalTime()
            TargetBranch  = "refs/heads/main"
            TrunkBranch   = "refs/heads/main"
            ReleaseBranch = "refs/heads/main"
        }

        Mock -ModuleName $ModuleName -CommandName Get-Date -MockWith {
            $expected.CreatedDate
        }

        $mockRelease = @{
            Collection    = $expected.Collection
            Project       = $expected.Project
            DateFrom      = $expected.DateFrom
            DateTo        = $expected.DateTo
            AsOf          = $expected.AsOf
            ByUser        = $expected.ByUser
            TargetBranch  = $expected.TargetBranch
            TrunkBranch   = $expected.TrunkBranch
            ReleaseBranch = $expected.ReleaseBranch
        }

        # Act
        $result = ConvertTo-ExportDataRelease @mockRelease

        # Assert
        $result | Should -BeOfType [PSCustomObject]
        $result.Collection | Should -Be $expected.Collection
        $result.Project | Should -Be $expected.Project
        $result.DateFrom | Should -Be $expected.DateFrom
        $result.DateTo | Should -Be $expected.DateTo
        $result.AsOf | Should -Be $expected.AsOf
        $result.CreatedDate | Should -Be $expected.CreatedDate
        $result.CreatedBy | Should -Not -BeNullOrEmpty
    }
}
