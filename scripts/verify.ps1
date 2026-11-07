<#
.SYNOPSIS  Checks that SK-Browser config is applied. Run after launching each profile once, with Firefox closed.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
#>
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\common.ps1"

$failures = 0
function Report([string]$Status, [string]$Message) {
    if ($Status -eq 'FAIL') { $script:failures++ }
    Write-Host ("[{0}] {1}" -f $Status, $Message)
}

$firefox = Get-FirefoxDir
$version = [version](Get-Item "$firefox\firefox.exe").VersionInfo.ProductVersion
if ($version.Major -ge 136) { Report 'PASS' "Firefox $version (vertical tabs need 136+)" }
else { Report 'WARN' "Firefox $version is older than 136; vertical tabs may not work" }

# Policies installed and identical to the repo copy
$target = "$firefox\distribution\policies.json"
if (-not (Test-Path $target)) { Report 'FAIL' "policies.json missing in $firefox\distribution" }
elseif ((Get-FileHash $target).Hash -ne (Get-FileHash "$root\profile\distribution\policies.json").Hash) {
    Report 'FAIL' 'policies.json differs from the repo copy (re-run setup.ps1)'
} else { Report 'PASS' 'policies.json installed and matches repo' }

# Start page
if (Test-Path "$PayloadDir\start.html") { Report 'PASS' 'start page installed' } else { Report 'FAIL' 'start page missing' }

# Scheduled task
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) { Report 'PASS' 're-apply task registered' }
else { Report 'WARN' 're-apply task not registered' }

# Expected prefs from the repo user.js
$expected = Get-Content "$root\profile\user.js" |
    Where-Object { $_ -match '^user_pref\(' } | ForEach-Object { $_.Trim() }

foreach ($name in $ProfileNames) {
    $dir = Get-ProfileDir $name
    if (-not $dir) { Report 'FAIL' "profile '$name' not found"; continue }
    if (-not (Test-Path "$dir\user.js")) { Report 'FAIL' "[$name] user.js missing" }
    if (-not (Test-Path "$dir\chrome\userChrome.css")) { Report 'FAIL' "[$name] userChrome.css missing" }

    if (-not (Test-Path "$dir\prefs.js")) { Report 'WARN' "[$name] prefs.js not found: launch this profile once, then re-run"; continue }
    $prefs = Get-Content "$dir\prefs.js"
    # Firefox does not save a pref to prefs.js when its value equals Firefox's own default,
    # so a missing pref is only a WARN. If NONE are present, user.js is not being loaded: FAIL.
    $missing = @($expected | Where-Object { $prefs -notcontains $_ })
    if ($missing.Count -eq 0) { Report 'PASS' "[$name] all $($expected.Count) prefs applied" }
    elseif ($missing.Count -eq $expected.Count) { Report 'FAIL' "[$name] none of the prefs were applied (user.js not loaded?)" }
    else {
        Report 'PASS' "[$name] $($expected.Count - $missing.Count) of $($expected.Count) prefs applied"
        $missing | ForEach-Object { Report 'WARN' "[$name] not saved in prefs.js (probably equals Firefox's default; check about:config): $_" }
    }

    $extFile = "$dir\extensions.json"
    if (-not (Test-Path $extFile)) { Report 'WARN' "[$name] extensions.json not found: launch profile once"; continue }
    $ext = Get-Content $extFile -Raw
    foreach ($id in $Extensions) {
        if ($ext.Contains($id)) { Report 'PASS' "[$name] extension $id installed" }
        else { Report 'FAIL' "[$name] extension $id NOT installed (check ID in policies.json)" }
    }
}

Write-Host ""
if ($failures -eq 0) { Write-Host "All checks passed." } else { Write-Host "$failures check(s) failed." }
exit ([int]($failures -gt 0))
