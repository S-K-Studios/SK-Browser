# SK-Browser

A personal, privacy- and security-focused browser: **stock Firefox + a small versioned config** ([ADR-0001](docs/adr/0001-use-hardened-firefox.md)). Minimal, fast, and Gmail/banking sign-in keeps working. Engine security updates come from Mozilla.

## What you get

- Two isolated profiles: `sk` (daily, Gmail) and `sk-bank` (banking only), with hotkeys `Ctrl+Alt+D` / `Ctrl+Alt+B`
- Tracker/ad blocking (uBlock Origin), HTTPS-only, cookie isolation, URL tracking-parameter stripping, fingerprinting protection, no telemetry/sponsored content
- Password Boss extension; Firefox's built-in password manager is off
- Vertical tabs, dark theme, minimal toolbar, local no-network start page
- Auto-restore of policies if a Firefox update removes them

## Layout

| Path | Purpose |
|---|---|
| `profile/user.js` | Profile preferences not covered by policies or defaults |
| `profile/distribution/policies.json` | Enforced policies, forced extensions, homepage |
| `profile/chrome/userChrome.css` | Minimal toolbar (kept tiny on purpose) |
| `profile/start/start.html` | Local start page, no scripts or external resources |
| `scripts/setup.ps1` | One-command Windows setup (admin) |
| `scripts/verify.ps1` | Checks everything is applied |
| `scripts/uninstall.ps1` | Removes the setup (keeps your profiles unless told otherwise) |
| `scripts/reapply.ps1`, `scripts/common.ps1` | Used by the scheduled task and the other scripts |
| `scripts/check_config.py` | Developer check: syntax, duplicates, forbidden prefs, start page rules |
| `docs/` | Requirements, ADRs, test checklist |

## Setup (Windows)

1. Install Firefox from mozilla.org (it then auto-updates).
2. Open **PowerShell as Administrator** in this repo and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
   ```
3. Launch each profile once from its shortcut (so extensions install), then close Firefox.
4. Run `powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1`.
5. Manual: set your default search engine in Settings > Search (the start page uses DuckDuckGo).

Re-running `setup.ps1` is safe. Use `-SkipTask` to skip the scheduled task.

Rule: never browse anything but banking in `sk-bank`; Gmail stays in `sk`.

## Passwords

Password Boss (`passwordboss-v6@passwordboss.com`) is force-installed in both profiles. The ID was supplied by the owner and not independently verified; `verify.ps1` reports if it did not install. To switch to another manager, replace the entry in `policies.json` and remove the old extension by hand. Keep only one manager installed.

## Uninstall

Close Firefox, then in an **Administrator** PowerShell. Preview first, then run it:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1 -WhatIf
powershell -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1
```

It removes the scheduled task, `policies.json` (only if it is SK-Browser's copy; `-Force` overrides), the shortcuts, `user.js`/`userChrome.css`, the prefs SK-Browser set in each profile's `prefs.js` (backup saved as `prefs.js.sk-backup`) and `C:\Program Files\SK-Browser`. Your profiles and their data are **kept**; add `-RemoveProfiles` to delete them (you must type `DELETE`). Firefox itself and the extensions stay; remove those in `about:addons`.

## Limits

- Custom new-tab pages can't be set by policy without an extension, so new tabs use Firefox's plain search-only Home. The local start page is the homepage.
- No setup prevents all tracking; your IP stays visible to sites.
- Everything here is **untested on a real Windows/Firefox until you run `docs/test-checklist.md`**.

## Developer check

```powershell
python scripts/check_config.py
```

Then check protection at <https://coveryourtracks.eff.org>.
