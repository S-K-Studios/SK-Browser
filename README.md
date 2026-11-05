# SK-Browser

A personal, privacy- and security-focused browser: **stock Firefox + a small versioned config** ([ADR-0001](docs/adr/0001-use-hardened-firefox.md)). Minimal, fast, and Gmail/banking sign-in keeps working.

## Layout

| Path | Purpose |
|---|---|
| `profile/user.js` | Profile preferences not covered by policies or defaults |
| `profile/chrome/userChrome.css` | Minimal toolbar tweaks (kept tiny on purpose) |
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

## Two profiles: daily and banking

Create two profiles at `about:profiles`: `sk` (daily) and `sk-bank` (banking and financial sites only). Run the install script once per profile with its own `-ProfileDir`. Policies and extensions apply to both.

Make a shortcut for each so they can run side by side and never mix cookies or sessions:

```
"C:\Program Files\Mozilla Firefox\firefox.exe" -P sk -no-remote
"C:\Program Files\Mozilla Firefox\firefox.exe" -P sk-bank -no-remote
```

Rule: never browse anything else in `sk-bank`. Gmail stays in `sk`.

## Shortcuts

Firefox already has `Ctrl+L` (focus address bar / search) and `Ctrl+K` (focus search). To jump between profiles, right-click each Firefox shortcut > Properties and set a **Shortcut key** (e.g. `Ctrl+Alt+D` for `sk`, `Ctrl+Alt+B` for `sk-bank`); Windows then launches that profile from anywhere. No extension needed, which keeps the setup minimal.

## Passwords

Firefox's built-in password manager is disabled by policy. Your external manager's extension is force-installed once its ID is added to `policies.json` (pending).

## Test

```powershell
python scripts/check_config.py   # developer check; needs Python
```

Then check protection in the browser at <https://coveryourtracks.eff.org>.

## Status

Phase 1 is written but **not yet tested in a real Firefox, and `install.ps1` has not been run on Windows**. Pref and policy names must be verified at `about:config` / `about:policies`, since Mozilla renames them over time. Assumptions and open questions: `docs/requirements.md`.
