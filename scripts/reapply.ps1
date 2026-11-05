# Restores policies.json into the Firefox install folder if missing or changed.
# Runs as SYSTEM from C:\Program Files\SK-Browser (admin-only write). Do not move it to a user-writable folder.
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\common.ps1"

$source = Join-Path $PSScriptRoot 'policies.json'
$firefox = Get-FirefoxDir
$target = Join-Path $firefox 'distribution\policies.json'

$same = (Test-Path $target) -and
        ((Get-FileHash $target -Algorithm SHA256).Hash -eq (Get-FileHash $source -Algorithm SHA256).Hash)
if (-not $same) {
    Install-Policies $firefox $source
    Write-Output "Restored policies.json"
}
