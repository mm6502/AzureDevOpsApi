[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', '',
    Justification = 'Test code uses parameter names that trigger the rule but are not actual credentials'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Invoke-ApiListPagedWithContinuationToken' {

    BeforeEach {
        # Reset retry configuration to ensure consistent test environment
        $global:AzureDevOpsApi_RetryConfig = @{
            RetryCount             = 3
            RetryDelay             = 1.0
            DisableRetry           = $false
            MaxRetryDelay          = 30.0
            UseExponentialBackoff  = $true
            UseJitter              = $true
        }
    }

    BeforeAll {
        $testUri = 'https://dev.azure.com/myorg/myproject/_apis/test/resource'
    }

    It 'Should make API call and return data' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            return [PSCustomObject]@{
                Content = '{"value": [{"id": 1, "name": "Item1"}]}'
                Headers = @{}
            }
        }

        # Act
        $result = Invoke-ApiListPagedWithContinuationToken -Uri $testUri

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.id | Should -Be 1
        $result.name | Should -Be 'Item1'
    }

    It 'Should iterate through pages using continuation token' {
        # Arrange
        $callCount = 0
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            $script:callCount++
            if ($script:callCount -eq 1) {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 1, "name": "Item1"}]}'
                    Headers = @{
                        'x-ms-continuationtoken' = 'token123'
                    }
                }
            } else {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 2, "name": "Item2"}]}'
                    Headers = @{}
                }
            }
        }

        # Act
        $result = @(Invoke-ApiListPagedWithContinuationToken -Uri $testUri)

        # Assert
        $result | Should -HaveCount 2
        $result[0].id | Should -Be 1
        $result[1].id | Should -Be 2
        $script:callCount | Should -Be 2
    }

    It 'Should add continuation token to URL on subsequent calls' {
        # Arrange
        $script:uris = @()
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            param($Uri)
            $script:uris += $Uri

            if ($script:uris.Count -eq 1) {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 1}]}'
                    Headers = @{
                        'x-ms-continuationtoken' = 'token456'
                    }
                }
            } else {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 2}]}'
                    Headers = @{}
                }
            }
        }

        # Act
        $result = @(Invoke-ApiListPagedWithContinuationToken -Uri $testUri)

        # Assert
        $result | Should -HaveCount 2
        $script:uris[0] | Should -Not -Match 'continuationToken'
        $script:uris[1] | Should -Match 'continuationToken=token456'
    }

    It 'Should use custom continuation token parameter name' {
        # Arrange
        $script:uris = @()
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            param($Uri)
            $script:uris += $Uri

            if ($script:uris.Count -eq 1) {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 1}]}'
                    Headers = @{
                        'x-ms-continuationtoken' = 'token789'
                    }
                }
            } else {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 2}]}'
                    Headers = @{}
                }
            }
        }

        # Act
        $result = @(Invoke-ApiListPagedWithContinuationToken `
                -Uri $testUri `
                -ContinuationTokenParameterName 'customToken')

        # Assert
        $result | Should -HaveCount 2
        $script:uris[1] | Should -Match 'customToken=token789'
    }

    It 'Should handle continuation token as array' {
        # Arrange
        $script:callCount = 0
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            $script:callCount++
            if ($script:callCount -eq 1) {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 1}]}'
                    Headers = @{
                        'x-ms-continuationtoken' = @('token1', 'token2')
                    }
                }
            } else {
                return [PSCustomObject]@{
                    Content = '{"value": [{"id": 2}]}'
                    Headers = @{}
                }
            }
        }

        # Act
        $result = @(Invoke-ApiListPagedWithContinuationToken -Uri $testUri)

        # Assert - should use first token and make 2 calls
        $result | Should -HaveCount 2
        $script:callCount | Should -Be 2
    }

    It 'Should stop when no continuation token is returned' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            return [PSCustomObject]@{
                Content = '{"value": [{"id": 1}]}'
                Headers = @{}
            }
        }

        # Act
        $result = @(Invoke-ApiListPagedWithContinuationToken -Uri $testUri)

        # Assert
        $result | Should -HaveCount 1
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -Times 1
    }

    It 'Should add API version to URI' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            param($Uri)
            $Uri | Should -Match 'api-version='
            return [PSCustomObject]@{
                Content = '{"value": []}'
                Headers = @{}
            }
        }

        # Act
        Invoke-ApiListPagedWithContinuationToken -Uri $testUri

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -Times 1
    }

    It 'Should require Uri parameter' {
        # Arrange
        $command = Get-Command -Name Invoke-ApiListPagedWithContinuationToken -Module $ModuleName

        # Act
        $mandatoryParams = $command.Parameters['Uri'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }

        # Assert
        $mandatoryParams | Should -Not -BeNullOrEmpty
    }

    It 'Should throw on relative URI' {
        # Arrange
        $relativeUri = '_apis/test/resource'

        # Act & Assert
        { Invoke-ApiListPagedWithContinuationToken -Uri $relativeUri } | Should -Throw -ExpectedMessage '*must be absolute*'
    }

    It 'Should support AsHashTable parameter' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            return [PSCustomObject]@{
                Content = '{"value": [{"id": 1}]}'
                Headers = @{}
            }
        }

        Mock -ModuleName $ModuleName -CommandName ConvertFrom-JsonCustom -MockWith {
            param($InputObject, $AsHashtable)
            $AsHashtable | Should -Be $true
            return @{
                value = @(
                    @{ id = 1 }
                )
            }
        }

        # Act
        $result = Invoke-ApiListPagedWithContinuationToken -Uri $testUri -AsHashTable

        # Assert
        $result.id | Should -Be 1
    }

    It 'Should pass Body parameter to web request' {
        # Arrange
        $testBody = @{ key = 'value' }
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            param($Body)
            $Body | Should -Be $testBody
            return [PSCustomObject]@{
                Content = '{"value": []}'
                Headers = @{}
            }
        }

        # Act
        Invoke-ApiListPagedWithContinuationToken -Uri $testUri -Body $testBody

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -Times 1
    }

    It 'Should pass Method parameter to web request' {
        # Arrange
        $testMethod = 'POST'
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            param($Method)
            $Method | Should -Be $testMethod
            return [PSCustomObject]@{
                Content = '{"value": []}'
                Headers = @{}
            }
        }

        # Act
        Invoke-ApiListPagedWithContinuationToken -Uri $testUri -Method $testMethod

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -Times 1
    }

    It 'Should pass retry parameters to web request' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            param($RetryCount, $RetryDelay, $DisableRetry)
            $RetryCount | Should -Be 5
            $RetryDelay | Should -Be 2.0
            $DisableRetry | Should -Be $true
            return [PSCustomObject]@{
                Content = '{"value": []}'
                Headers = @{}
            }
        }

        # Act
        Invoke-ApiListPagedWithContinuationToken `
            -Uri $testUri `
            -RetryCount 5 `
            -RetryDelay 2.0 `
            -DisableRetry

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -Times 1
    }

    It 'Should handle empty value array' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            return [PSCustomObject]@{
                Content = '{"value": []}'
                Headers = @{}
            }
        }

        # Act
        $result = @(Invoke-ApiListPagedWithContinuationToken -Uri $testUri)

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'Should handle missing value property in response' {
        # Arrange
        Mock -ModuleName $ModuleName -CommandName Invoke-CustomWebRequest -MockWith {
            return [PSCustomObject]@{
                Content = '{"items": [{"id": 1}]}'
                Headers = @{}
            }
        }

        # Act
        $result = @(Invoke-ApiListPagedWithContinuationToken -Uri $testUri)

        # Assert
        $result | Should -BeNullOrEmpty
    }
}
