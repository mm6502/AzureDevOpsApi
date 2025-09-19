function ConvertFrom-JsonCustom {

    <#
        .SYNOPSIS
            Converts the given JSON string to object or hashtable.
            This is a wrapper around ConvertFrom-Json that adds the -AsHashTable parameter because:
            - PowerShell 5 does not support the -AsHashTable parameter

        .PARAMETER Value
            Object to JSON object or hashtable.

        .PARAMETER AsHashTable
            If set, the JSON string will be deserialized as a hashtable.
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [AllowEmptyString()]
        $Value,

        [switch] $AsHashTable
    )

    begin {

        # Only use System.Web.Extensions on Windows PowerShell 5.x
        # On non-Windows platforms, this assembly is not available
        if ((Get-PSVersion) -lt 6 -and (Get-OSVersion).Platform -like 'Win*') {

            # Assembly name for System.Web.Extensions
            $assemblyName = 'System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35'

            # Type name for JavaScriptSerializer
            $typeName = 'System.Web.Script.Serialization.JavaScriptSerializer'

            try {
                # Use this class to perform the deserialization:
                # https://msdn.microsoft.com/en-us/library/system.web.script.serialization.javascriptserializer(v=vs.110).aspx
                Add-Type `
                    -AssemblyName $assemblyName `
                    -ErrorAction Stop
                
                # Create a new instance of the JavaScriptSerializer class
                $jsSerializer = New-Object -TypeName $typeName

                # ...Why the simple way does not work?
                # $jsSerializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new()

                # Alternative way:
                # $type = [Type]::GetType("$typeName, $assemblyName")
                # $jsSerializer = [Activator]::CreateInstance($type)
            } catch {
                # If we can't load the assembly, fall back to basic ConvertFrom-Json
                Write-Warning "Unable to locate the System.Web.Extensions namespace from System.Web.Extensions.dll. Falling back to basic ConvertFrom-Json."
                $jsSerializer = $null
            }
        } else {
            $jsSerializer = $null
        }
    }

    process {

        $Value | ForEach-Object {

            # Cast to string first
            $current = [string] $_

            # Skip if null or empty
            if (!$current) {
                return
            }

            # Remove UTF-8 BOM, if present
            if ($current.Length -gt 0) {
                # UTF-8 BOM = 0xEF 0xBB 0xBF = 65279
                if ($current[0] -eq ([char] 65279)) {
                    $current = $current.Substring(1)
                }
            }

            # Return if null or empty
            if ([string]::IsNullOrEmpty($current)) {
                return
            }

            # Powershell 6 supports -AsHashTable
            if ((Get-PSVersion) -ge 6) {
                $result = $current | ConvertFrom-Json -AsHashtable:$AsHashTable
                return $result
            }

            # PowerShell 5 does not support -AsHashTable
            # when $AsHashTable not specified or $false, use default
            if (-not ($AsHashTable.IsPresent -and ($true -eq $AsHashTable))) {
                $result = $current | ConvertFrom-Json
                return $result
            }

            # If JavaScriptSerializer is available, use it for hashtable conversion
            if ($null -ne $jsSerializer) {
                $result = $jsSerializer.Deserialize($current, 'Hashtable')
                return $result
            }

            # Fallback: use regular ConvertFrom-Json (won't be a hashtable but will work)
            Write-Warning "AsHashTable requested but System.Web.Extensions not available. Returning PSCustomObject instead of Hashtable."
            $result = $current | ConvertFrom-Json
            return $result
        }
    }

    end {
        $jsSerializer = $null
    }
}
