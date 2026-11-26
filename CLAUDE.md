# SK-Browser — project rules

Global rules in `~/.claude/CLAUDE.md` apply. Project specifics:

## Versioning

- Single source of truth: the `VERSION` file, in the global 5-part format `MAJOR.MINOR.PATCH.BUILD.ISSUE`.
- `ISSUE` increments by 1 per tracked bug/issue fix and resets to `0` on any `MAJOR`, `MINOR`, `PATCH` or `BUILD` update.
- Keep the full 5-part string in docs, filenames and artifacts. This repo ships no Windows PE/Gradle/manifest header; if one is added, map to the four numeric integers `MAJOR.MINOR.PATCH.BUILD`.
- Do not introduce 3-part or 4-part version strings.

## Metadata

- Publisher: `SK Studios (Personal Use Only)` in README, scripts and artifacts.
- Record each change/review in `CHANGELOG.md`, including what still needs checking on real hardware.

## Checks and build

```
python3 scripts/check_config.py   # config lint + VERSION format check
python3 scripts/build.py          # writes dist/SK-Browser-<VERSION>.zip
```

Close Firefox before testing the installer (`install.ps1` refuses to run while it is open). No local port is used.
