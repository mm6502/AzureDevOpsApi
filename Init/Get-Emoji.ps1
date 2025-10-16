#requires -version 5

<#
    .SYNOPSIS
        Helper functions for console output with emoji support across PowerShell versions.

    .DESCRIPTION
        Provides emoji output that works consistently across PowerShell 5.1, 7.0+, and different
        console hosts (Windows PowerShell console, PowerShell Core, VS Code terminal, etc.).
#>

# Global emoji character mapping
$script:EmojiMap = @{
    'checkmark'       = if ($PSVersionTable.PSVersion.Major -ge 7) { '✅' } else { '[√]' }
    'cross'           = if ($PSVersionTable.PSVersion.Major -ge 7) { '❌' } else { '[x]' }
    'warning'         = if ($PSVersionTable.PSVersion.Major -ge 7) { '⚠️' } else { '[!]' }
    'info'            = if ($PSVersionTable.PSVersion.Major -ge 7) { 'ℹ️' } else { '[i]' }
    'star'            = if ($PSVersionTable.PSVersion.Major -ge 7) { '⭐' } else { '[*]' }
    'party'           = if ($PSVersionTable.PSVersion.Major -ge 7) { '🎉' } else { '[^]' }
    'hourglass'       = if ($PSVersionTable.PSVersion.Major -ge 7) { '⏳' } else { '[~]' }
    'unknown'         = if ($PSVersionTable.PSVersion.Major -ge 7) { '❓' } else { '[?]' }
    'right'           = if ($PSVersionTable.PSVersion.Major -ge 7) { '➡️' } else { '->>' }
    'left'            = if ($PSVersionTable.PSVersion.Major -ge 7) { '⬅️' } else { '<<-' }
}

function Get-Emoji {
    <#
        .SYNOPSIS
            Gets an emoji character or fallback for the current PowerShell version.

        .DESCRIPTION
            Returns an emoji character on PowerShell 7+ or a text fallback on PowerShell 5.1.
            This ensures consistent output across different PowerShell versions and console hosts.

        .PARAMETER Name
            The name of the emoji to retrieve. Valid values:
            - checkmark (✅ or [√])
            - cross (❌ or [x])
            - warning (⚠️ or [!])
            - info (ℹ️ or [i])
            - star (⭐ or [*])
            - party (🎉 or [^])
            - hourglass (⏳ or [~])
            - unknown (❓ or [?])
            - right (➡️ or ->>)
            - left (⬅️ or <<-)

        .EXAMPLE
            Write-Host "$(Get-Emoji checkmark) Success"
            # PowerShell 7+: ✅ Success
            # PowerShell 5.1: [√] Success

        .EXAMPLE
            Write-Warning "$(Get-Emoji warning) Configuration file not found"
            # PowerShell 7+: ⚠️ Configuration file not found
            # PowerShell 5.1: [!] Configuration file not found
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('checkmark', 'cross', 'warning', 'info', 'star', 'party', 'hourglass', 'unknown', 'right', 'left')]
        [string] $Name
    )

    if ($script:EmojiMap.ContainsKey($Name)) {
        return $script:EmojiMap[$Name]
    }
    else {
        Write-Warning "Unknown emoji name: $Name"
        return '[?]'
    }
}
