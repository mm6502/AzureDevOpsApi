BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Resolve-RelativePath' {
    Context 'Basic relative path calculation' {
        It 'Should return relative path for file in subdirectory' {
            $from = 'C:\Projects'
            $to = 'C:\Projects\Module\file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be 'Module\file.ps1'
        }

        It 'Should return relative path for file in parent directory' {
            $from = 'C:\Projects\Module'
            $to = 'C:\Projects\file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be '..\file.ps1'
        }

        It 'Should return relative path for file in sibling directory' {
            $from = 'C:\Projects\Module'
            $to = 'C:\Projects\Tests\test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be '..\Tests\test.ps1'
        }

        It 'Should return relative path for deeply nested file' {
            $from = 'C:\Projects'
            $to = 'C:\Projects\src\Module\Private\Helpers\file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be 'src\Module\Private\Helpers\file.ps1'
        }

        It 'Should return relative path going up multiple levels' {
            $from = 'C:\Projects\src\Module\Private'
            $to = 'C:\Projects\Tests\test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be '..\..\..\Tests\test.ps1'
        }
    }

    Context 'Edge cases' {
        It 'Should handle same path' {
            $path = 'C:\Projects\file.ps1'

            $result = Resolve-RelativePath -From (Split-Path $path) -To $path

            $result | Should -Be 'file.ps1'
        }

        It 'Should work with non-existing paths' {
            $from = 'C:\NonExistent\Path'
            $to = 'C:\NonExistent\Path\SubFolder\file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be 'SubFolder\file.ps1'
        }

        It 'Should handle paths with trailing backslash' {
            $from = 'C:\Projects\'
            $to = 'C:\Projects\Module\file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be 'Module\file.ps1'
        }

        It 'Should handle paths with spaces' {
            $from = 'C:\My Projects\Azure Module'
            $to = 'C:\My Projects\Azure Module\Tests\test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be 'Tests\test.ps1'
        }

        It 'Should handle paths with special characters' {
            $from = 'C:\Projects\[Module]'
            $to = 'C:\Projects\[Module]\(Files)\test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be '(Files)\test.ps1'
        }
    }

    Context 'Cross-platform compatibility' {
        It 'Should use backslashes on Windows' {
            if ([System.IO.Path]::DirectorySeparatorChar -eq '\') {
                $from = 'C:\Projects'
                $to = 'C:\Projects\Module\file.ps1'

                $result = Resolve-RelativePath -From $from -To $to

                $result | Should -Match '\\'
                $result | Should -Not -Match '/'
            } else {
                Set-ItResult -Skipped -Because 'Test is Windows-specific'
            }
        }

        It 'Should use forward slashes on Unix' {
            if ([System.IO.Path]::DirectorySeparatorChar -eq '/') {
                $from = '/home/user/projects'
                $to = '/home/user/projects/module/file.ps1'

                $result = Resolve-RelativePath -From $from -To $to

                $result | Should -Match '/'
                $result | Should -Not -Match '\\'
            } else {
                Set-ItResult -Skipped -Because 'Test is Unix-specific'
            }
        }
    }

    Context 'Parameter validation' {
        It 'Should require RelativeBasePath parameter' {
            # Verify parameter is properly defined without invoking (to avoid prompts)
            $cmd = Get-Command Resolve-RelativePath
            $param = $cmd.Parameters['RelativeBasePath']
            $param.Attributes.Mandatory | Should -Contain $true
        }

        It 'Should require Path parameter' {
            # Verify parameter is properly defined without invoking (to avoid prompts)
            $cmd = Get-Command Resolve-RelativePath
            $param = $cmd.Parameters['Path']
            $param.Attributes.Mandatory | Should -Contain $true
        }

        It 'Should accept pipeline input for RelativeBasePath parameter' {
            $result = 'C:\Projects' | Resolve-RelativePath -Path 'C:\Projects\file.ps1'
            $result | Should -Be 'file.ps1'
        }

        It 'Should support From alias for RelativeBasePath' {
            $result = Resolve-RelativePath -From 'C:\Projects' -To 'C:\Projects\file.ps1'
            $result | Should -Be 'file.ps1'
        }

        It 'Should support To alias for Path' {
            $result = Resolve-RelativePath -RelativeBasePath 'C:\Projects' -To 'C:\Projects\file.ps1'
            $result | Should -Be 'file.ps1'
        }

        It 'Should reject empty RelativeBasePath parameter' {
            { Resolve-RelativePath -RelativeBasePath '' -Path 'C:\Path\file.ps1' -ErrorAction Stop } | Should -Throw
        }

        It 'Should reject empty Path parameter' {
            { Resolve-RelativePath -RelativeBasePath 'C:\Path' -Path '' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Real-world scenarios' {
        BeforeAll {
            # Create a temporary directory structure for testing
            $script:tempRoot = Join-Path $env:TEMP "RelativePathCompat_$(New-Guid)"
            $script:sourceDir = Join-Path $tempRoot 'Source'
            $script:targetFile = Join-Path $tempRoot 'Target\SubFolder\file.txt'

            New-Item -Path $sourceDir -ItemType Directory -Force | Out-Null
            New-Item -Path (Split-Path $targetFile) -ItemType Directory -Force | Out-Null
            New-Item -Path $targetFile -ItemType File -Force | Out-Null
        }

        AfterAll {
            if (Test-Path $script:tempRoot) {
                Remove-Item -Path $script:tempRoot -Recurse -Force
            }
        }

        It 'Should work with actual file system paths' {
            $result = Resolve-RelativePath -From $script:sourceDir -To $script:targetFile

            $result | Should -Be '..\Target\SubFolder\file.txt'
        }

        It 'Should work when combined with Join-Path' {
            $result = Resolve-RelativePath -From $script:sourceDir -To $script:targetFile
            $reconstructed = Join-Path $script:sourceDir $result

            [System.IO.Path]::GetFullPath($reconstructed) | Should -Be $script:targetFile
        }

        It 'Should handle current directory as From parameter' {
            Push-Location $script:sourceDir
            try {
                $result = Resolve-RelativePath -From (Get-Location).Path -To $script:targetFile

                $result | Should -Be '..\Target\SubFolder\file.txt'
            } finally {
                Pop-Location
            }
        }
    }

    Context 'PowerShell version compatibility' {
        It 'Should work in PowerShell 5' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
            # This test validates the Uri-based fallback
            $from = 'C:\Projects'
            $to = 'C:\Projects\Module\file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be 'Module\file.ps1'
        }

        It 'Should work in PowerShell 7+' -Skip:($PSVersionTable.PSVersion.Major -lt 7) {
            # This test validates that the native method is used when available
            $from = 'C:\Projects'
            $to = 'C:\Projects\Module\file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be 'Module\file.ps1'
        }
    }
}
