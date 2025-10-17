BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Resolve-RelativePath' {
    BeforeAll {
        # Use platform-appropriate root paths
        $script:dirSep = [System.IO.Path]::DirectorySeparatorChar
        $script:testRoot = Join-Path -Path $TestDrive -ChildPath 'Projects'
    }

    Context 'Basic relative path calculation' {
        It 'Should return relative path for file in subdirectory' {
            $from = $script:testRoot
            $to = Join-Path -Path $script:testRoot -ChildPath 'Module' | Join-Path -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "Module$($script:dirSep)file.ps1"
        }

        It 'Should return relative path for file in parent directory' {
            $from = Join-Path -Path $script:testRoot -ChildPath 'Module'
            $to = Join-Path -Path $script:testRoot -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "..$($script:dirSep)file.ps1"
        }

        It 'Should return relative path for file in sibling directory' {
            $from = Join-Path -Path $script:testRoot -ChildPath 'Module'
            $to = Join-Path -Path $script:testRoot -ChildPath 'Tests' | Join-Path -ChildPath 'test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "..$($script:dirSep)Tests$($script:dirSep)test.ps1"
        }

        It 'Should return relative path for deeply nested file' {
            $from = $script:testRoot
            $to = Join-Path -Path $script:testRoot -ChildPath 'src' | Join-Path -ChildPath 'Module' | Join-Path -ChildPath 'Private' | Join-Path -ChildPath 'Helpers' | Join-Path -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "src$($script:dirSep)Module$($script:dirSep)Private$($script:dirSep)Helpers$($script:dirSep)file.ps1"
        }

        It 'Should return relative path going up multiple levels' {
            $from = Join-Path -Path $script:testRoot -ChildPath 'src' | Join-Path -ChildPath 'Module' | Join-Path -ChildPath 'Private'
            $to = Join-Path -Path $script:testRoot -ChildPath 'Tests' | Join-Path -ChildPath 'test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "..$($script:dirSep)..$($script:dirSep)..$($script:dirSep)Tests$($script:dirSep)test.ps1"
        }
    }

    Context 'Edge cases' {
        It 'Should handle same path' {
            $path = Join-Path -Path $script:testRoot -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From (Split-Path $path) -To $path

            $result | Should -Be 'file.ps1'
        }

        It 'Should work with non-existing paths' {
            $from = Join-Path -Path $script:testRoot -ChildPath 'NonExistent' | Join-Path -ChildPath 'Path'
            $to = Join-Path -Path $from -ChildPath 'SubFolder' | Join-Path -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "SubFolder$($script:dirSep)file.ps1"
        }

        It 'Should handle paths with trailing separator' {
            $from = "$($script:testRoot)$($script:dirSep)"
            $to = Join-Path -Path $script:testRoot -ChildPath 'Module' | Join-Path -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "Module$($script:dirSep)file.ps1"
        }

        It 'Should handle paths with spaces' {
            $from = Join-Path -Path $TestDrive -ChildPath 'My Projects' | Join-Path -ChildPath 'Azure Module'
            $to = Join-Path -Path $from -ChildPath 'Tests' | Join-Path -ChildPath 'test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "Tests$($script:dirSep)test.ps1"
        }

        It 'Should handle paths with special characters' {
            $from = Join-Path -Path $script:testRoot -ChildPath '[Module]'
            $to = Join-Path -Path $from -ChildPath '(Files)' | Join-Path -ChildPath 'test.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "(Files)$($script:dirSep)test.ps1"
        }
    }

    Context 'Cross-platform compatibility' {
        It 'Should use backslashes on Windows' {
            if ([System.IO.Path]::DirectorySeparatorChar -eq '\') {
                $from = $script:testRoot
                $to = Join-Path -Path $script:testRoot -ChildPath 'Module' | Join-Path -ChildPath 'file.ps1'

                $result = Resolve-RelativePath -From $from -To $to

                $result | Should -Match '\\'
                $result | Should -Not -Match '/'
            } else {
                Set-ItResult -Skipped -Because 'Test is Windows-specific'
            }
        }

        It 'Should use forward slashes on Unix' {
            if ([System.IO.Path]::DirectorySeparatorChar -eq '/') {
                $from = $script:testRoot
                $to = Join-Path -Path $script:testRoot -ChildPath 'module' | Join-Path -ChildPath 'file.ps1'

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
            $from = $script:testRoot
            $to = Join-Path -Path $script:testRoot -ChildPath 'file.ps1'
            $result = $from | Resolve-RelativePath -Path $to
            $result | Should -Be 'file.ps1'
        }

        It 'Should support From alias for RelativeBasePath' {
            $from = $script:testRoot
            $to = Join-Path -Path $script:testRoot -ChildPath 'file.ps1'
            $result = Resolve-RelativePath -From $from -To $to
            $result | Should -Be 'file.ps1'
        }

        It 'Should support To alias for Path' {
            $from = $script:testRoot
            $to = Join-Path -Path $script:testRoot -ChildPath 'file.ps1'
            $result = Resolve-RelativePath -RelativeBasePath $from -To $to
            $result | Should -Be 'file.ps1'
        }

        It 'Should reject empty RelativeBasePath parameter' {
            $to = Join-Path -Path $script:testRoot -ChildPath 'file.ps1'
            { Resolve-RelativePath -RelativeBasePath '' -Path $to -ErrorAction Stop } | Should -Throw
        }

        It 'Should reject empty Path parameter' {
            { Resolve-RelativePath -RelativeBasePath $script:testRoot -Path '' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Real-world scenarios' {
        BeforeAll {
            # Create a temporary directory structure for testing
            # Use [System.IO.Path]::GetTempPath() for cross-platform compatibility
            $tempPath = [System.IO.Path]::GetTempPath()
            $script:tempRoot = Join-Path $tempPath "RelativePathCompat_$(New-Guid)"
            $script:sourceDir = Join-Path $script:tempRoot 'Source'
            $script:targetFile = Join-Path $script:tempRoot 'Target' | Join-Path -ChildPath 'SubFolder' | Join-Path -ChildPath 'file.txt'

            New-Item -Path $script:sourceDir -ItemType Directory -Force | Out-Null
            New-Item -Path (Split-Path $script:targetFile) -ItemType Directory -Force | Out-Null
            New-Item -Path $script:targetFile -ItemType File -Force | Out-Null
        }

        AfterAll {
            if ($script:tempRoot -and (Test-Path $script:tempRoot)) {
                Remove-Item -Path $script:tempRoot -Recurse -Force
            }
        }

        It 'Should work with actual file system paths' {
            $dirSep = [System.IO.Path]::DirectorySeparatorChar
            $result = Resolve-RelativePath -From $script:sourceDir -To $script:targetFile

            $result | Should -Be "..$($dirSep)Target$($dirSep)SubFolder$($dirSep)file.txt"
        }

        It 'Should work when combined with Join-Path' {
            $result = Resolve-RelativePath -From $script:sourceDir -To $script:targetFile
            $reconstructed = Join-Path $script:sourceDir $result

            [System.IO.Path]::GetFullPath($reconstructed) | Should -Be $script:targetFile
        }

        It 'Should handle current directory as From parameter' {
            $dirSep = [System.IO.Path]::DirectorySeparatorChar
            Push-Location $script:sourceDir
            try {
                $result = Resolve-RelativePath -From (Get-Location).Path -To $script:targetFile

                $result | Should -Be "..$($dirSep)Target$($dirSep)SubFolder$($dirSep)file.txt"
            } finally {
                Pop-Location
            }
        }
    }

    Context 'PowerShell version compatibility' {
        It 'Should work in PowerShell 5' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
            # This test validates the Uri-based fallback
            $dirSep = [System.IO.Path]::DirectorySeparatorChar
            $from = $script:testRoot
            $to = Join-Path -Path $script:testRoot -ChildPath 'Module' | Join-Path -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "Module$($dirSep)file.ps1"
        }

        It 'Should work in PowerShell 7+' -Skip:($PSVersionTable.PSVersion.Major -lt 7) {
            # This test validates that the native method is used when available
            $dirSep = [System.IO.Path]::DirectorySeparatorChar
            $from = $script:testRoot
            $to = Join-Path -Path $script:testRoot -ChildPath 'Module' | Join-Path -ChildPath 'file.ps1'

            $result = Resolve-RelativePath -From $from -To $to

            $result | Should -Be "Module$($dirSep)file.ps1"
        }
    }
}
