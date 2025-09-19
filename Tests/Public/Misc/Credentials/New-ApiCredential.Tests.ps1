[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'For testing purposes.'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'New-ApiCredential' {

    Context 'When Token is given' {

        It 'Should return ApiCredential object with <expecteddata> Token' -ForEach @(
            @{ Name = 'PAT'   ; ExpectedData = 'PAT'    }
            @{ Name = 'Bearer'; ExpectedData = 'Bearer' }
            @{ Name = 'OAuth' ; ExpectedData = 'OAuth'  }
        ) {
            # arrange
            $token = ConvertTo-SecureString 'myToken' -AsPlainText -Force
            $expected = @{
                PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCredential
                Authorization = $ExpectedData
                Token = $token
            }

            # act
            $result = New-ApiCredential `
                -Authorization $expected.Authorization `
                -Token $token

            # assert
            $result.PSObject.TypeNames[0] | Should -Be $expected.PSTypeName
            $result.Authorization | Should -Be $expected.Authorization
            $result.Token | Should -Be $expected.Token
        }

        Context 'When called with an empty Token for token based authorization' {
            It 'Should throw an exception for <Authorization>' -ForEach @(
                @{ Authorization = 'PAT' }
                @{ Authorization = 'Bearer' }
                @{ Authorization = 'OAuth' }
            ) {
                { New-ApiCredential `
                        -Authorization $Authorization `
                } | Should -Throw
            }
        }

        It 'Should require Authorization' {
            # arrange
            $token = ConvertTo-SecureString 'myToken' -AsPlainText -Force

            # act & assert
            { New-ApiCredential -Token $token -Authorization $null } | Should -Throw
        }
    }

    Context 'When Credential is given' {

        It 'Should result in <expecteddata> Authorization when <name> is requested' -ForEach @(
            @{ Name = 'none' ; GivenData = ''     ; ExpectedData = 'Basic' }
            @{ Name = 'Basic'; GivenData = 'Basic'; ExpectedData = 'Basic' }
        ) {
            # arrange
            $password = ConvertTo-SecureString 'myToken' -AsPlainText -Force
            $pscredential = [pscredential]::new('myUser', $password)
            ConvertTo-SecureString 'myToken' -AsPlainText -Force
            $expected = @{
                PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCredential
                Authorization = $ExpectedData
                Credential    = $pscredential
            }

            # act
            $result = New-ApiCredential `
                -Credential $expected.Credential `
                -Authorization $GivenData

            # assert
            $result.PSObject.TypeNames[0] | Should -Be $expected.PSTypeName
            $result.Authorization | Should -Be $expected.Authorization
            $result.Token | Should -Be $expected.Token
        }

        It 'Should not require Authorization' {
            # arrange
            $password = ConvertTo-SecureString 'myToken' -AsPlainText -Force
            $pscredential = [pscredential]::new('myUser', $password)
            $expected = @{
                PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCredential
                Authorization = 'Basic'
                Credential    = $pscredential
            }

            # act
            # no Authorization is given
            $result = New-ApiCredential `
                -Credential $pscredential

            # assert
            $result.PSObject.TypeNames[0] | Should -Be $expected.PSTypeName
            $result.Authorization | Should -Be $expected.Authorization
            $result.Credential | Should -Be $expected.Credential
        }
    }

    Context 'Default' {
        It 'Should use Default Authorization without token or credential' {
            # arrange
            $expected = @{
                PSTypeName    = $global:PSTypeNames.AzureDevOpsApi.ApiCredential
                Authorization = [AuthorizationType]::Default
                Credential    = $null
                Token         = $null
            }

            # act
            $result = New-ApiCredential

            # assert
            $result.PSObject.TypeNames[0] | Should -Be $expected.PSTypeName
            $result.Authorization | Should -Be $expected.Authorization
            $result.Credential | Should -Be $expected.Credential
            $result.Token | Should -Be $expected.Token
        }

        It 'Should throw without token or credential when requested <givendata> Authorization' -ForEach @(
            @{ GivenData = 'Basic'  }
            @{ GivenData = 'Bearer' }
            @{ GivenData = 'PAT'    }
            @{ GivenData = 'OAuth'  }
        ) {
            # act
            { New-ApiCredential -Authorization $GivenData } | Should -Throw
        }
    }
}
