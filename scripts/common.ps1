# Shared helpers for SK-Browser scripts. Dot-source: . "$PSScriptRoot\common.ps1"

$script:PayloadDir = Join-Path $env:ProgramFiles 'SK-Browser'   # admin-only write by default
$script:ProfileNames = @('SK-1', 'SK-Bank')
$script:Extensions = @('uBlock0@raymondhill.net', 'passwordboss-v6@passwordboss.com')
$script:TaskName = 'SK-Browser-Reapply'
$script:ShortcutLabels = @{ 'SK-1' = 'SK Browser'; 'SK-Bank' = 'SK Browser (Banking)' }

function Get-ShortcutFolders {
    @([Environment]::GetFolderPath('Desktop'), (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'))
}

function Get-FirefoxDir {
    foreach ($d in @("$env:ProgramFiles\Mozilla Firefox", "${env:ProgramFiles(x86)}\Mozilla Firefox")) {
        if ($d -and (Test-Path "$d\firefox.exe")) { return $d }
    }
    throw "Firefox not found. Install it from mozilla.org first."
}

function Assert-Admin {
    $p = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Run PowerShell as Administrator."
    }
}

# Returns the folder of the Firefox profile with this NAME (read from profiles.ini), or $null.
function Get-ProfileDir([string]$Name) {
    $base = Join-Path $env:APPDATA 'Mozilla\Firefox'
    $ini = Join-Path $base 'profiles.ini'
    if (-not (Test-Path $ini)) { return $null }
    $current = @{}
    foreach ($line in @(Get-Content $ini) + '[End]') {   # sentinel flushes the last section
        if ($line -match '^\[.+\]$') {
            if ($current['Name'] -ieq $Name -and $current['Path']) { break }
            $current = @{}
        } elseif ($line -match '^([^=]+)=(.*)$') {
            $current[$Matches[1]] = $Matches[2]
        }
    }
    if ($current['Name'] -ine $Name -or -not $current['Path']) { return $null }
    $path = $current['Path'] -replace '/', '\'
    if ($current['IsRelative'] -eq '1') { $path = Join-Path $base $path }
    if (Test-Path $path) { return $path }
    return $null
}

function Install-ProfileConfig([string]$ProfileDir, [string]$RepoRoot) {
    Copy-Item "$RepoRoot\profile\user.js" "$ProfileDir\user.js" -Force
    New-Item -ItemType Directory -Force "$ProfileDir\chrome" | Out-Null
    Copy-Item "$RepoRoot\profile\chrome\userChrome.css" "$ProfileDir\chrome\userChrome.css" -Force
}

function Install-Policies([string]$FirefoxDir, [string]$PolicySource) {
    Get-Content $PolicySource -Raw | ConvertFrom-Json | Out-Null   # validate JSON first
    New-Item -ItemType Directory -Force "$FirefoxDir\distribution" | Out-Null
    Copy-Item $PolicySource "$FirefoxDir\distribution\policies.json" -Force
}
