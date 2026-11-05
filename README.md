# SK-Browser

A personal, privacy- and security-focused browser: **stock Firefox + a small versioned config** ([ADR-0001](docs/adr/0001-use-hardened-firefox.md)). Minimal, fast, and Gmail/banking sign-in keeps working.

## Layout

| Path | Purpose |
|---|---|
| `profile/user.js` | Profile preferences not covered by policies or defaults |
| `profile/distribution/policies.json` | Telemetry/sponsored content off, tracking protection, uBlock Origin forced |
| `scripts/check_config.py` | Developer check: syntax, duplicates, forbidden prefs |
| `scripts/install.ps1` | Windows installer |
| `docs/` | Requirements and ADRs |

## Install (Windows)

1. Install Firefox from mozilla.org so it keeps auto-updating.
2. Open `about:profiles`, create a profile (e.g. `sk`) and note its **Root Directory**.
3. Close Firefox. In an **Administrator** PowerShell:
   ```powershell
   .\scripts\install.ps1 -ProfileDir "C:\Users\<you>\AppData\Roaming\Mozilla\Firefox\Profiles\<profile>"
   ```
4. Start Firefox. Check `about:policies` and that uBlock Origin is installed.
5. Manual: set your default search engine in Settings > Search.

A Firefox update may remove the `distribution` folder; re-run the script if `about:policies` is empty.

## Test

```powershell
python scripts/check_config.py   # developer check; needs Python
```

Then check protection in the browser at <https://coveryourtracks.eff.org>.

## Status

Phase 1 is written but **not yet tested in a real Firefox, and `install.ps1` has not been run on Windows**. Pref and policy names must be verified at `about:config` / `about:policies`, since Mozilla renames them over time. Assumptions and open questions: `docs/requirements.md`.
