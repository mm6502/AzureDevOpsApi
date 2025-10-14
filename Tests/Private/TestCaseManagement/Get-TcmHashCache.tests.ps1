BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Get-TcmHashCache' {
    It 'returns empty hashtable when cache file does not exist' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cache = Get-TcmHashCache -TestCasesRoot $testRoot

        $cache | Should -BeOfType [hashtable]
        $cache.Count | Should -Be 0
    }

    It 'loads cache from existing file' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cacheFile = Join-Path $testRoot '.tcm-hashes.json'
        $testCache = @{
            '12345' = @{
                local = 'abc123'
                remote = 'abc123'
                lastSync = '2025-10-13T10:00:00Z'
            }
        }
        $testCache | ConvertTo-Json -Depth 10 | Set-Content -Path $cacheFile

        $cache = Get-TcmHashCache -TestCasesRoot $testRoot

        $cache | Should -Not -BeNullOrEmpty
        $cache.Count | Should -Be 1
        $cache['12345'] | Should -Not -BeNullOrEmpty
        $cache['12345'].local | Should -Be 'abc123'
        $cache['12345'].remote | Should -Be 'abc123'
    }

    It 'returns empty hashtable when cache file is corrupt' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cacheFile = Join-Path $testRoot '.tcm-hashes.json'
        'invalid json content' | Set-Content -Path $cacheFile

        $cache = Get-TcmHashCache -TestCasesRoot $testRoot -WarningAction SilentlyContinue

        $cache | Should -BeOfType [hashtable]
        $cache.Count | Should -Be 0
    }
}

Describe 'Set-TcmHashCache' {
    It 'creates cache file with correct structure' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cache = @{
            '12345' = @{
                local = 'abc123'
                remote = 'def456'
                lastSync = '2025-10-13T10:00:00Z'
            }
        }

        Set-TcmHashCache -TestCasesRoot $testRoot -Cache $cache

        $cacheFile = Join-Path $testRoot '.tcm-hashes.json'
        $cacheFile | Should -Exist

        $savedCache = Get-TcmHashCache -TestCasesRoot $testRoot
        $savedCache['12345'].local | Should -Be 'abc123'
        $savedCache['12345'].remote | Should -Be 'def456'
    }

    It 'overwrites existing cache file' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cache1 = @{
            '12345' = @{
                local = 'old'
                remote = 'old'
                lastSync = '2025-10-13T09:00:00Z'
            }
        }
        Set-TcmHashCache -TestCasesRoot $testRoot -Cache $cache1

        $cache2 = @{
            '12345' = @{
                local = 'new'
                remote = 'new'
                lastSync = '2025-10-13T10:00:00Z'
            }
        }
        Set-TcmHashCache -TestCasesRoot $testRoot -Cache $cache2

        $savedCache = Get-TcmHashCache -TestCasesRoot $testRoot
        $savedCache['12345'].local | Should -Be 'new'
        $savedCache['12345'].remote | Should -Be 'new'
    }
}

Describe 'Update-TcmHashCacheEntry' {
    It 'creates new entry when test case not in cache' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        Update-TcmHashCacheEntry -TestCasesRoot $testRoot -TestCaseId '12345' -LocalHash 'abc123' -RemoteHash 'abc123'

        $cache = Get-TcmHashCache -TestCasesRoot $testRoot
        $cache['12345'] | Should -Not -BeNullOrEmpty
        $cache['12345'].local | Should -Be 'abc123'
        $cache['12345'].remote | Should -Be 'abc123'
        $cache['12345'].lastSync | Should -Not -BeNullOrEmpty
    }

    It 'updates existing entry' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cache = @{
            '12345' = @{
                local = 'old'
                remote = 'old'
                lastSync = '2025-10-13T09:00:00Z'
            }
        }
        Set-TcmHashCache -TestCasesRoot $testRoot -Cache $cache

        Update-TcmHashCacheEntry -TestCasesRoot $testRoot -TestCaseId '12345' -LocalHash 'new' -RemoteHash 'new'

        $updatedCache = Get-TcmHashCache -TestCasesRoot $testRoot
        $updatedCache['12345'].local | Should -Be 'new'
        $updatedCache['12345'].remote | Should -Be 'new'
    }

    It 'updates only local hash when remote not specified' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cache = @{
            '12345' = @{
                local = 'old'
                remote = 'old'
                lastSync = '2025-10-13T09:00:00Z'
            }
        }
        Set-TcmHashCache -TestCasesRoot $testRoot -Cache $cache

        Update-TcmHashCacheEntry -TestCasesRoot $testRoot -TestCaseId '12345' -LocalHash 'new-local'

        $updatedCache = Get-TcmHashCache -TestCasesRoot $testRoot
        $updatedCache['12345'].local | Should -Be 'new-local'
        $updatedCache['12345'].remote | Should -Be 'old'
    }

    It 'updates only remote hash when local not specified' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $cache = @{
            '12345' = @{
                local = 'old'
                remote = 'old'
                lastSync = '2025-10-13T09:00:00Z'
            }
        }
        Set-TcmHashCache -TestCasesRoot $testRoot -Cache $cache

        Update-TcmHashCacheEntry -TestCasesRoot $testRoot -TestCaseId '12345' -RemoteHash 'new-remote'

        $updatedCache = Get-TcmHashCache -TestCasesRoot $testRoot
        $updatedCache['12345'].local | Should -Be 'old'
        $updatedCache['12345'].remote | Should -Be 'new-remote'
    }

    It 'updates lastSync timestamp' {
        $testRoot = Join-Path $TestDrive 'TestCases'
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        $oldTimestamp = '2025-10-13T09:00:00Z'
        $cache = @{
            '12345' = @{
                local = 'old'
                remote = 'old'
                lastSync = $oldTimestamp
            }
        }
        Set-TcmHashCache -TestCasesRoot $testRoot -Cache $cache

        Update-TcmHashCacheEntry -TestCasesRoot $testRoot -TestCaseId '12345' -LocalHash 'new'

        $updatedCache = Get-TcmHashCache -TestCasesRoot $testRoot
        $updatedCache['12345'].lastSync | Should -Not -Be $oldTimestamp
    }
}
