# Emoji Helper System

## Overview

The AzureDevOpsApi module includes an emoji helper system (`Get-Emoji`) to ensure consistent output across PowerShell versions. This addresses PowerShell 5.1's limited Unicode emoji support while providing rich visual feedback in PowerShell 7+.

## Problem

PowerShell 5.1 (Windows PowerShell) has inconsistent Unicode emoji rendering:
- Some console hosts don't support emojis
- Character encoding issues can cause mojibake (garbled text)
- May break output parsing in automation scripts

PowerShell 7+ has excellent emoji support across platforms.

## Solution

The `Get-Emoji` function provides version-aware emoji output:
- **PowerShell 7+**: Full Unicode emoji characters (✅, ❌, ⚠️, etc.)
- **PowerShell 5.1**: ASCII fallbacks ([OK], [X], [!], etc.)

## Usage

### In Module Code

```powershell
# Instead of hardcoding emojis:
Write-Host "✅ Success"  # ❌ Don't do this

# Use the helper:
Write-Host "$(Get-Emoji checkmark) Success"  # ✅ Do this
```

### Available Emojis

| Name | PS 7+ | PS 5.1 | Use Case |
|------|-------|--------|----------|
| `checkmark` | ✅ | [√] | Success messages |
| `cross` | ❌ | [x] | Error messages |
| `warning` | ⚠️ | [!] | Warning messages |
| `info` | ℹ️ | [i] | Informational messages |
| `star` | ⭐ | [*] | Important/featured items |
| `party` | 🎉 | [^] | Celebration messages |
| `hourglass` | ⏳ | [~] | Progress/waiting messages |
| `unknown` | ❓ | [?] | Unknown/question status |
| `right` | ➡️ | ->> | Forward direction/next |
| `left` | ⬅️ | <<- | Backward direction/previous |

### Examples

```powershell
# Success message
Write-Host "$(Get-Emoji checkmark) Credentials are valid" -ForegroundColor Green

# Error message
Write-Warning "$(Get-Emoji cross) Connection failed: $errorMessage"

# Info message
Write-Verbose "$(Get-Emoji info) Processing 42 items..."

# Progress message
Write-Host "$(Get-Emoji hourglass) Syncing test cases..."
```

## Implementation Details

### Location

- **File**: `Init/EmojiHelper.ps1`
- **Loaded**: Automatically during module initialization via `Init/Init.ps1`
- **Scope**: Module-wide (available to all functions, not exported)

### How It Works

```powershell
$script:EmojiMap = @{
    'checkmark' = if ($PSVersionTable.PSVersion.Major -ge 7) { '✅' } else { '[√]' }
    'cross'     = if ($PSVersionTable.PSVersion.Major -ge 7) { '❌' } else { '[x]' }
    'star'      = if ($PSVersionTable.PSVersion.Major -ge 7) { '⭐' } else { '[*]' }
    'unknown'   = if ($PSVersionTable.PSVersion.Major -ge 7) { '❓' } else { '[?]' }
    'right'     = if ($PSVersionTable.PSVersion.Major -ge 7) { '➡️' } else { '->>' }
    'left'      = if ($PSVersionTable.PSVersion.Major -ge 7) { '⬅️' } else { '<<-' }
    # ... more mappings
}

function Get-Emoji {
    param([string] $Name)
    return $script:EmojiMap[$Name]
}
```

The version check happens once at module load time, ensuring zero performance impact.

## Testing

### Test in PowerShell 7

```powershell
Import-Module AzureDevOpsApi
Test-ApiCredential -CollectionUri "https://dev.azure.com/myorg" -Verbose
# Output: VERBOSE: ✅ Credentials are valid
```

### Test in PowerShell 5.1

```powershell
Import-Module AzureDevOpsApi
Test-ApiCredential -CollectionUri "https://dev.azure.com/myorg" -Verbose
# Output: VERBOSE: [OK] Credentials are valid
```

## Functions Using Emoji Helper

Currently implemented in:
- `Test-ApiCredential` - All success/error messages use Get-Emoji

Can be extended to other functions as needed.

## Documentation Guidelines

### In Function Help

Documentation examples can show actual emojis for visual clarity:

```powershell
.EXAMPLE
if (Test-ApiCredential -Quiet) {
    Write-Host "✅ Credentials are valid"
} else {
    Write-Host "❌ Credentials are invalid"
}
```

Users will see appropriate output based on their PowerShell version.

### In Markdown Docs

Use actual emojis in documentation - they render correctly in:
- GitHub/GitLab markdown
- VS Code markdown preview
- Most modern documentation systems

### In Code

Always use `Get-Emoji` helper to ensure compatibility:

```powershell
# ✅ Good - Version-aware
Write-Host "$(Get-Emoji checkmark) Done"

# ❌ Bad - Hardcoded emoji
Write-Host "✅ Done"
```

## Extending the System

To add new emojis:

1. Add to `$script:EmojiMap` in `Init/EmojiHelper.ps1`:
   ```powershell
   $script:EmojiMap = @{
       # Existing entries...
       'target' = if ($PSVersionTable.PSVersion.Major -ge 7) { '🎯' } else { '[>]' }
   }
   ```

2. Add to `ValidateSet` in `Get-Emoji`:
   ```powershell
   [ValidateSet('checkmark', 'cross', 'star', 'unknown', 'right', 'left', 'target')]
   ```

3. Update documentation table above

4. Use in code:
   ```powershell
   Write-Host "$(Get-Emoji target) Target acquired"
   ```

## Benefits

✅ **Compatibility**: Works across PowerShell 5.1 and 7+
✅ **Consistency**: Single source of truth for visual markers
✅ **Maintainability**: Easy to update all emojis in one place
✅ **Performance**: Version check happens once at module load
✅ **Flexibility**: Easy to extend with new emojis
✅ **Graceful Degradation**: Always readable, even without emoji support

## Migration Guide

When updating existing code:

1. Search for hardcoded emojis: `grep -r "[✅❌⚠️⭐🎉⏳❓➡️⬅️]" Public/`
2. Replace with Get-Emoji calls
3. Test in both PS 5.1 and 7+
4. Update tests if they validate output strings

Remember: Documentation examples can keep actual emojis for visual clarity, but production code should use the helper.
