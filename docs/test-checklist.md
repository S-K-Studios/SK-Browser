# Evening test checklist

Nothing in this repo has been run on Windows or in Firefox. Work through this in order and note failures.

## 1. Setup
- [ ] Firefox installed (version 136+ ideally): `about:support` shows the version
- [ ] Administrator PowerShell: `powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1` finishes without errors
- [ ] Desktop and Start Menu show "SK Browser" and "SK Browser (Banking)"
- [ ] `Ctrl+Alt+D` opens `SK-1`; `Ctrl+Alt+B` opens `SK-Bank`; both can run at once

## 2. First launch of each profile
- [ ] `about:policies` shows Active policies, no errors
- [ ] `about:addons`: uBlock Origin and Password Boss installed in both profiles
- [ ] Homepage opens the local start page (if blank, Firefox may block `file://` homepages: report it)
- [ ] Vertical tabs sidebar appears; dark theme applied
- [ ] Account (Sync) button is hidden

## 3. Verify script
- [ ] Close Firefox, run `scripts\verify.ps1`; note every FAIL/WARN
- [ ] Check `about:config` for any pref that verify flagged (a wrong name is silently ignored)

## 4. Real-world behaviour
- [ ] Gmail sign-in works in `SK-1`
- [ ] Your bank sign-in works in `SK-Bank`
- [ ] Password Boss autofills in both profiles
- [ ] A plain `http://` site shows the HTTPS-only warning
- [ ] <https://coveryourtracks.eff.org> result noted (tracker blocking, fingerprint)

## 5. Re-apply task
- [ ] Task Scheduler has `SK-Browser-Reapply`
- [ ] Rename `distribution\policies.json` in the Firefox folder, run the task, confirm it returns

## 6. Uninstall (only when you are done testing, or want a clean re-run)
- [ ] `uninstall.ps1 -WhatIf` lists only SK-Browser items and changes nothing
- [ ] `uninstall.ps1` removes the task, shortcuts, `C:\Program Files\SK-Browser` and `policies.json`
- [ ] Profiles `SK-1` / `SK-Bank` still exist and open; vertical tabs/dark theme settings are gone
- [ ] `prefs.js.sk-backup` exists in each profile
- [ ] Re-running `setup.ps1` afterwards works

## Report back
Send me: failed items, `verify.ps1` output, and any error text. I'll fix the scripts.
