[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Inner scriptblocks use this variable'
)]
[CmdletBinding()]
param()

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '.\BeforeAll.ps1')
}

BeforeDiscovery {
    $skipForNot5 = $PSVersionTable.PSVersion.Major -gt 5
    $skipFor6AndEarlier = $PSVersionTable.PSVersion.Major -lt 6
}

Describe 'Assert-HttpResponse' {
    It 'Should handle SocketException' {
        # Arrange
        $exception = [System.Net.Sockets.SocketException]::new(11001)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception, 'SocketException', 'InvalidOperation', $null
        )

        # Act & Assert
        # Linux: "Name or service not known."
        # Windows: "No such host is known."
        { Assert-HttpResponse -ErrorRecord $errorRecord } | Should -Throw
    }

    It 'Should handle other exceptions' {
        # Arrange
        $expectedMessage = 'Some other exception'

        $exception = [System.Exception]::new($expectedMessage)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception, 'OtherException', 'InvalidOperation', $null
        )

        # Act & Assert
        { Assert-HttpResponse -ErrorRecord $errorRecord } | Should -Throw $expectedMessage
    }

    It 'Should handle WebException (PowerShell 5)' -Skip:$skipForNot5 {
        # Arrange
        $expectedMessage = 'HttpResponseException occurred'
        $expectedDetails = 'Error details'

        $exception = [System.Net.WebException]::new($expectedMessage)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception, 'WebException', 'InvalidOperation', $null
        )
        $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($expectedDetails)

        # Act & Assert
        { Assert-HttpResponse -ErrorRecord $errorRecord } | Should -Throw ($expectedMessage)
        $errorRecord.ErrorDetails.Message | Should -Be $expectedDetails
    }

    It 'Should handle HttpResponseException (PowerShell 7)' -Skip:$skipFor6AndEarlier {
        # Arrange
        $expectedMessage = 'HttpResponseException occurred'
        $expectedDetails = 'Error details'
        $httpResponse = [System.Net.Http.HttpResponseMessage]::new(404)
        $exception = [Microsoft.PowerShell.Commands.HttpResponseException]::new(
            $expectedMessage, $httpResponse
        )
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception, $null, 'InvalidOperation', $httpResponse
        )
        $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($expectedDetails)

        # Act & Assert
        { Assert-HttpResponse -ErrorRecord $errorRecord } | Should -Throw $expectedMessage
        $errorRecord.ErrorDetails.Message | Should -Be $expectedDetails
    }

    It 'Should handle JSON error response' {
        # Arrange
        $jsonMessage = 'JSON message'
        $json = "{""message"":""$($jsonMessage)""}"

        $exception = [System.Net.WebException]::new($jsonMessage)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception, 'WebException', 'InvalidOperation', $null
        )
        $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($json)

        # Act & Assert
        { Assert-HttpResponse -ErrorRecord $errorRecord } | Should -Throw $jsonMessage
        $errorRecord.ErrorDetails.Message | Should -Be $json
    }

    It 'Should handle non-JSON error response' {
        # Arrange
        $expectedMessage = 'WebException occurred'
        $expectedDetails = 'Non-JSON error message'

        $exception = [System.Net.WebException]::new($expectedMessage)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception, 'WebException', 'InvalidOperation', $null
        )
        $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($expectedDetails)

        # Act & Assert
        { Assert-HttpResponse -ErrorRecord $errorRecord } | Should -Throw $expectedMessage
        $errorRecord.ErrorDetails.Message | Should -Be $expectedDetails
    }
}
