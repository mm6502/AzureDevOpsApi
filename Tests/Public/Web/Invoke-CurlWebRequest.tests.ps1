[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

Describe 'Invoke-CurlWebRequest' {

    It 'Should call Invoke-WebRequest with correct parameters' {
        # Windows PowerShell has curl -> Invoke-WebRequest alias.
        while (Test-Path Alias:curl) { Remove-Item Alias:curl }

        # Arrange
        $params = @{
            uri = 'https://example.com'
            method = 'POST'
            headers = @{'Content-Type' = 'application/json'}
            body = '{"key": "value"}'
        }

        # -ModuleName $ModuleName
        Mock -ModuleName $ModuleName -CommandName 'curl' -MockWith {
            Write-Output @(
                'HTTP/1.1 200 OK'
                'Content-Type: application/json'
                'Content-Length: 25'
                ''
                '{ "result": "success" }'
            )
        }

        # Act
        $result = Invoke-CurlWebRequest $params

        # Assert
        Should -Invoke -ModuleName $ModuleName -CommandName 'curl' -Times 1 -ParameterFilter {
            $a = ($args -contains $params.uri)
            $b = ($args -contains $params.method)
            $c = ($args -contains $params.body)
            $result = $a -and $b -and $c
            return $result
        }
    }
}
