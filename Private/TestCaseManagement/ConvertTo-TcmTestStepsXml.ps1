function ConvertTo-TestStepsXml {
    <#
        .SYNOPSIS
            Converts test steps to Azure DevOps XML format.

        .PARAMETER Steps
            Array of test steps, each with stepNumber, action, expectedResult, and attachments.

        .OUTPUTS
            XML string representing the test steps in Azure DevOps format.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array] $Steps
    )

    try {
        # Create XML document
        $xmlDoc = New-Object System.Xml.XmlDocument
        $stepsElement = $xmlDoc.CreateElement("steps")
        $stepsElement.SetAttribute("id", "0")
        $stepsElement.SetAttribute("last", $Steps.Count.ToString())

        # Add each step
        foreach ($step in $Steps) {
            $stepElement = $xmlDoc.CreateElement("step")
            $stepElement.SetAttribute("id", $step.stepNumber.ToString())
            $stepElement.SetAttribute("type", "ValidateStep")

            # Add action (parameterizedString 0)
            $actionElement = $xmlDoc.CreateElement("parameterizedString")
            $actionElement.SetAttribute("isformatted", "true")
            [void]$actionElement.AppendChild($xmlDoc.CreateCDataSection($step.action))
            [void]$stepElement.AppendChild($actionElement)

            # Add expected result (parameterizedString 1)
            $expectedElement = $xmlDoc.CreateElement("parameterizedString")
            $expectedElement.SetAttribute("isformatted", "true")
            [void]$expectedElement.AppendChild($xmlDoc.CreateCDataSection($step.expectedResult))
            [void]$stepElement.AppendChild($expectedElement)

            # Add description (empty parameterizedString 2)
            $descElement = $xmlDoc.CreateElement("description")
            [void]$stepElement.AppendChild($descElement)

            [void]$stepsElement.AppendChild($stepElement)
        }

        [void]$xmlDoc.AppendChild($stepsElement)

        # Return XML as string
        return $xmlDoc.OuterXml
    }
    catch {
        throw "Failed to convert test steps to XML: $($_.Exception.Message)"
    }
}
