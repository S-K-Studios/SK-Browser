# Shared helpers for SK-Browser scripts. Dot-source: . "$PSScriptRoot\common.ps1"

$script:PayloadDir = Join-Path $env:ProgramFiles 'SK-Browser'   # admin-only write by default
$script:ProfileNames = @('sk', 'sk-bank')
$script:Extensions = @('uBlock0@raymondhill.net', 'passwordboss-v6@passwordboss.com')
$script:TaskName = 'SK-Browser-Reapply'
$script:ShortcutLabels = @{ 'sk' = 'SK Browser'; 'sk-bank' = 'SK Browser (Banking)' }

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

# Returns the profile folder whose name ends with ".<name>", or $null.
function Get-ProfileDir([string]$Name) {
    $root = Join-Path $env:APPDATA 'Mozilla\Firefox\Profiles'
    if (-not (Test-Path $root)) { return $null }
    Get-ChildItem $root -Directory | Where-Object { $_.Name -like "*.$Name" } |
        Select-Object -First 1 -ExpandProperty FullName
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
