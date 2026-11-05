<#
.SYNOPSIS  Install SK-Browser config into Firefox on Windows.
.DESCRIPTION
  - Copies user.js and chrome\userChrome.css into the given Firefox profile folder.
  - Copies policies.json into the Firefox install folder (needs an Administrator PowerShell).
.EXAMPLE
  .\scripts\install.ps1 -ProfileDir "$env:APPDATA\Mozilla\Firefox\Profiles\abcd1234.sk"
#>
param(
    [Parameter(Mandatory = $true)][string]$ProfileDir,
    [string]$InstallDir = "$env:ProgramFiles\Mozilla Firefox"
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (Get-Process firefox -ErrorAction SilentlyContinue) { throw "Close Firefox first." }
if (-not (Test-Path $ProfileDir)) { throw "Profile folder not found: $ProfileDir (see about:profiles)" }
if (-not (Test-Path "$InstallDir\firefox.exe")) { throw "Firefox not found in: $InstallDir" }

# Validate JSON before touching anything.
Get-Content "$root\profile\distribution\policies.json" -Raw | ConvertFrom-Json | Out-Null

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw "Run PowerShell as Administrator (needed to write to $InstallDir)." }

Copy-Item "$root\profile\user.js" "$ProfileDir\user.js" -Force
New-Item -ItemType Directory -Force "$ProfileDir\chrome" | Out-Null
Copy-Item "$root\profile\chrome\userChrome.css" "$ProfileDir\chrome\userChrome.css" -Force
New-Item -ItemType Directory -Force "$InstallDir\distribution" | Out-Null
Copy-Item "$root\profile\distribution\policies.json" "$InstallDir\distribution\policies.json" -Force
Write-Host "Done. Start Firefox and check about:policies."
Write-Host "Note: a Firefox update can remove the distribution folder; re-run this script if about:policies is empty."
