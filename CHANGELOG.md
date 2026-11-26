# Changelog

Version format: `MAJOR.MINOR.PATCH.BUILD.ISSUE` (see `CLAUDE.md`).
Publisher: SK Studios (Personal Use Only)

## 0.1.0.0.0 — 2026-11-26

Change/review note — versioning alignment pass:

- Added `VERSION` (`0.1.0.0.0`, new build line; the repo had no prior version).
- Added project `CLAUDE.md` referencing the global 5-part standard.
- Added `scripts/build.py`: packages `profile/`, `scripts/install.ps1`, `VERSION` into `dist/SK-Browser-<VERSION>.zip`.
- `scripts/check_config.py` now validates `VERSION` (exactly 5 numeric parts).
- Added publisher/version to README and script headers. `policies.json` is deliberately untouched (Firefox validates its keys).
- Checked: `check_config.py` passes; build output verified.

Still to verify on real hardware:

- Config has not been loaded in a real Firefox (`about:policies`, `about:config`).
- `install.ps1` has not been run on Windows.
- The Windows install path is unchanged, so the zip must be unpacked and installed manually.

Publisher: SK Studios (Personal Use Only)
