<#
.SYNOPSIS  Removes the SK-Browser setup from Windows (run in an Administrator PowerShell, Firefox closed).
.DESCRIPTION
  Removes, in this order:
    1. the 'SK-Browser-Reapply' scheduled task (first, so it cannot restore policies)
    2. policies.json from the Firefox install (only if it is SK-Browser's copy, unless -Force)
    3. Desktop and Start Menu shortcuts
    4. SK-Browser config in each profile: user.js, userChrome.css, and the prefs it set in prefs.js
       (a backup is saved as prefs.js.sk-backup)
    5. C:\Program Files\SK-Browser
  Profiles and their data (cookies, history, bookmarks) are KEPT unless you pass -RemoveProfiles.
  Firefox itself is not uninstalled. Extensions installed by policy stay installed but become
  normal extensions you can remove in about:addons.
.PARAMETER RemoveProfiles  Also delete the 'SK-1' and 'SK-Bank' profile folders (asks you to type DELETE).
.PARAMETER Force           Remove policies.json even if it differs from SK-Browser's copy.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1 -WhatIf     # preview only
  powershell -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$RemoveProfiles,
    [switch]$Force
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\common.ps1"

Assert-Admin
$did = if ($WhatIfPreference) { 'Would remove' } else { 'Removed' }   # honest messages under -WhatIf
if (Get-Process firefox -ErrorAction SilentlyContinue) { throw "Close Firefox first." }

# 1. Scheduled task
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "$did scheduled task '$TaskName'"
} else { Write-Host "Scheduled task not found (skipped)" }

# 2. policies.json (only if it is ours, so other policies you may have are not destroyed)
$firefox = try { Get-FirefoxDir } catch { $null }
if ($firefox) {
    $policies = Join-Path $firefox 'distribution\policies.json'
    if (Test-Path $policies) {
        $hash = (Get-FileHash $policies -Algorithm SHA256).Hash
        $ours = @("$root\profile\distribution\policies.json", "$PayloadDir\policies.json") |
            Where-Object { Test-Path $_ } |
            ForEach-Object { (Get-FileHash $_ -Algorithm SHA256).Hash }
        if ($Force -or ($ours -contains $hash)) {
            Remove-Item $policies -Force
            Write-Host "$did $policies"
            $dist = Split-Path $policies
            if (-not (Get-ChildItem $dist -Force -ErrorAction SilentlyContinue)) { Remove-Item $dist -Force }
        } else {
            Write-Warning "$policies differs from SK-Browser's copy; left in place. Use -Force to remove it."
        }
    } else { Write-Host "policies.json not found (skipped)" }
} else { Write-Host "Firefox install not found; skipping policies" }

# 3. Shortcuts
foreach ($folder in Get-ShortcutFolders) {
    foreach ($label in $ShortcutLabels.Values) {
        $lnk = Join-Path $folder "$label.lnk"
        if (Test-Path $lnk) { Remove-Item $lnk -Force; Write-Host "$did $lnk" }
    }
}

# 4. Profiles
$prefNames = Get-Content "$root\profile\user.js" |
    ForEach-Object { if ($_ -match '^user_pref\("([^"]+)"') { $Matches[1] } }
$utf8 = New-Object System.Text.UTF8Encoding($false)   # no BOM: Firefox expects plain UTF-8

foreach ($name in $ProfileNames) {
    $dir = Get-ProfileDir $name
    if (-not $dir) { Write-Host "Profile '$name' not found (skipped)"; continue }

    if ($RemoveProfiles) {
        # profiles.ini can point anywhere; only ever delete inside Firefox's own Profiles folder.
        $allowed = Join-Path $env:APPDATA 'Mozilla\Firefox\Profiles\'
        if (-not ($dir + '\').StartsWith($allowed, [StringComparison]::OrdinalIgnoreCase)) {
            Write-Warning "Profile '$name' is outside $allowed; not deleting. Remove it in about:profiles."
            continue
        }
        if ($WhatIfPreference) { Write-Host "What if: would delete profile folder $dir"; continue }
        $answer = Read-Host "Permanently delete profile '$name' ($dir) including its cookies, history and bookmarks? Type DELETE to confirm"
        if ($answer -ceq 'DELETE') {
            Remove-Item $dir -Recurse -Force
            Write-Host "Deleted profile folder for '$name'. Remove the stale entry in about:profiles."
        } else { Write-Host "Skipped deleting '$name'" }
        continue
    }

    foreach ($f in @("$dir\user.js", "$dir\chrome\userChrome.css")) {
        if (Test-Path $f) { Remove-Item $f -Force; Write-Host "[$name] $did $f" }
    }
    $chrome = "$dir\chrome"
    if ((Test-Path $chrome) -and -not (Get-ChildItem $chrome -Force)) { Remove-Item $chrome -Force }

    # user.js prefs were copied into prefs.js by Firefox and stay there after user.js is gone.
    $prefsFile = "$dir\prefs.js"
    if (Test-Path $prefsFile) {
        $pattern = '^user_pref\("(' + (($prefNames | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')",'
        $lines = [System.IO.File]::ReadAllLines($prefsFile, $utf8)
        $kept = @($lines | Where-Object { $_ -notmatch $pattern })
        $removed = $lines.Count - $kept.Count
        if ($removed -gt 0 -and $PSCmdlet.ShouldProcess($prefsFile, "Remove $removed SK-Browser pref(s)")) {
            Copy-Item $prefsFile "$prefsFile.sk-backup" -Force
            [System.IO.File]::WriteAllLines($prefsFile, $kept, $utf8)
            Write-Host "[$name] removed $removed pref(s) from prefs.js (backup: prefs.js.sk-backup)"
        }
    }
}

# 5. Payload folder (path is fixed; never delete anything else)
if (Test-Path $PayloadDir) {
    if ($PayloadDir -ne (Join-Path $env:ProgramFiles 'SK-Browser')) { throw "Unexpected payload path: $PayloadDir" }
    Remove-Item $PayloadDir -Recurse -Force
    Write-Host "$did $PayloadDir"
}

Write-Host "`nDone. Firefox itself is untouched. Remove Password Boss / uBlock Origin in about:addons if you no longer want them."
if (-not $RemoveProfiles) { Write-Host "Profiles 'SK-1' and 'SK-Bank' were kept. Re-run with -RemoveProfiles to delete them." }
