# SK-Browser
Hardened-Firefox config for Windows (PowerShell 5.1 scripts, policies.json, user.js). The cloud sandbox has no Firefox or PowerShell; only `python3 scripts/check_config.py` runs here. Windows results come from the owner.

## Active Project Skills & Token Rules
- `/security-review`: before merging changes to `scripts/*.ps1` or `policies.json` (SYSTEM task, extensions, deletions).
- `/code-review`: only on a PR or diff, when asked.
- `/simplify`: only when asked to trim config (project style: minimal).
- Invoke by name; do not preload other skills or read `SKILL.md` files speculatively.
- Read targeted (`grep`/`glob`/line ranges). Use a subagent for broad scans. Reply diff-first and brief.
- Prefix verbose git/build/test commands with `rtk` if installed (absent in the cloud sandbox).

## Compact Instructions
Keep: decisions (ADR-0001), modified file paths, open TODOs, `python3 scripts/check_config.py`, pending Windows test results. Drop: full `SKILL.md` bodies, raw file dumps, verbose command logs.
