# SK-Browser

A personal, privacy- and security-focused browser: **stock Firefox + versioned hardening config** ([ADR-0001](docs/adr/0001-use-hardened-firefox.md)).

## Layout

| Path | Purpose |
|---|---|
| `profile/user.js` | Profile preferences (privacy, telemetry, HTTPS-only) |
| `profile/distribution/policies.json` | Enforced policies and forced uBlock Origin install |
| `scripts/check_config.py` | Validates the config (syntax, duplicates, forbidden prefs) |
| `scripts/install.sh` | Copies config into a profile / Firefox install |
| `docs/` | Requirements and ADRs |

## Install

1. Install Firefox from Mozilla or your distro, so it keeps receiving security updates.
2. Create a new profile at `about:profiles` and note its root directory.
3. Close Firefox, then run:
   ```bash
   scripts/install.sh ~/.mozilla/firefox/<profile> /usr/lib/firefox   # sudo may be needed for the 2nd path
   ```
4. Start Firefox, check `about:policies`, and confirm uBlock Origin is installed.
5. Manual step: set your default search engine in Settings > Search (a private engine of your choice).

## Test

```bash
python3 scripts/check_config.py
```

Then check protection in a real browser with <https://coveryourtracks.eff.org>.

## Status

Phase 1 (hardened baseline) is implemented but **not yet tested in a real Firefox**. Pref names must be verified against your installed Firefox version at `about:config`, since Mozilla renames prefs over time. See `docs/requirements.md` for assumptions and roadmap.
