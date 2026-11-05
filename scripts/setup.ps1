<#
.SYNOPSIS  One-command SK-Browser setup on Windows (run in an Administrator PowerShell).
.DESCRIPTION
  1. Copies policies, start page and re-apply script to C:\Program Files\SK-Browser (admin-only write).
  2. Applies policies to the Firefox install.
  3. Creates profiles 'sk' and 'sk-bank' (if missing) and installs user.js + userChrome.css.
  4. Creates Desktop and Start Menu shortcuts with hotkeys (Ctrl+Alt+D = sk, Ctrl+Alt+B = sk-bank).
  5. Registers a scheduled task that restores policies.json if Firefox removes it.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
#>
param([switch]$SkipTask)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\common.ps1"

Assert-Admin
$firefox = Get-FirefoxDir
if (Get-Process firefox -ErrorAction SilentlyContinue) { throw "Close Firefox first." }

# 1. Payload (kept in an admin-only folder because the scheduled task runs it as SYSTEM)
New-Item -ItemType Directory -Force $PayloadDir | Out-Null
Copy-Item "$root\profile\distribution\policies.json" "$PayloadDir\policies.json" -Force
Copy-Item "$root\profile\start\start.html" "$PayloadDir\start.html" -Force
Copy-Item "$PSScriptRoot\common.ps1", "$PSScriptRoot\reapply.ps1" $PayloadDir -Force

# 2. Policies
Install-Policies $firefox "$PayloadDir\policies.json"
Write-Host "Policies applied to $firefox"

# 3. Profiles
foreach ($name in $ProfileNames) {
    if (-not (Get-ProfileDir $name)) {
        & "$firefox\firefox.exe" -CreateProfile $name | Out-Null
        Start-Sleep -Seconds 2
    }
    $dir = Get-ProfileDir $name
    if (-not $dir) { throw "Could not create or find profile '$name'. Create it at about:profiles and re-run." }
    Install-ProfileConfig $dir $root
    Write-Host "Profile '$name' configured: $dir"
}

# 4. Shortcuts (hotkeys only work for shortcuts on the Desktop or Start Menu)
$shell = New-Object -ComObject WScript.Shell
$hotkeys = @{ 'sk' = 'CTRL+ALT+D'; 'sk-bank' = 'CTRL+ALT+B' }
$labels = @{ 'sk' = 'SK Browser'; 'sk-bank' = 'SK Browser (Banking)' }
$folders = @([Environment]::GetFolderPath('Desktop'), (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'))
foreach ($name in $ProfileNames) {
    foreach ($folder in $folders) {
        $lnk = $shell.CreateShortcut((Join-Path $folder "$($labels[$name]).lnk"))
        $lnk.TargetPath = "$firefox\firefox.exe"
        $lnk.Arguments = "-P $name -no-remote"
        $lnk.Hotkey = $hotkeys[$name]
        $lnk.IconLocation = "$firefox\firefox.exe,0"
        $lnk.Save()
    }
}
Write-Host "Shortcuts created (Ctrl+Alt+D = sk, Ctrl+Alt+B = sk-bank)"

# 5. Re-apply task
if (-not $SkipTask) {
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PayloadDir\reapply.ps1`""
    $triggers = @((New-ScheduledTaskTrigger -AtStartup), (New-ScheduledTaskTrigger -Daily -At '12:00'))
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest
    Register-ScheduledTask -TaskName 'SK-Browser-Reapply' -Action $action -Trigger $triggers `
        -Principal $principal -Force | Out-Null
    Write-Host "Scheduled task 'SK-Browser-Reapply' registered"
}

Write-Host "`nDone. Launch each profile once (so extensions install), close it, then run scripts\verify.ps1"
