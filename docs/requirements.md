# SK-Browser Requirements

## Vision

A fast, quiet, private browser configured around how I work. Built as a hardened Firefox configuration (see ADR-0001).

## Assumptions (unconfirmed, change if wrong)

- A1: Desktop Linux first; the config is portable to macOS/Windows with different install paths.
- A2: Google, banking and work sign-ins stay in a separate browser, so strict hardening is acceptable here.
- A3: Passwords are handled by a dedicated password manager, not the browser.
- A4: No Firefox Sync.

## Functional requirements

| ID | Requirement | Phase |
|---|---|---|
| F1 | Block trackers, fingerprinting scripts and ads by default (uBlock Origin enforced) | 1 |
| F2 | HTTPS-only mode | 1 |
| F3 | Isolate cookies per site (Total Cookie Protection) | 1 |
| F4 | Disable telemetry, studies, sponsored content and Pocket | 1 |
| F5 | Private search engine as default | 1 |
| F6 | Custom tab layout, shortcuts, theme, start page | 2 |
| F7 | Companion extension for workflow features config cannot deliver | 3 |

## Non-functional requirements

- **Security:** Never disable the sandbox, Safe Browsing or automatic updates. No secrets in the repo.
- **Privacy:** No data sent to third parties by the browser itself beyond what updates and Safe Browsing require.
- **Reproducibility:** The whole setup is installable from this repo by script.
- **Maintainability:** Every non-default pref has a comment saying why. Config is validated by `scripts/check_config.py`.
- **Compatibility:** Known breakages are logged in `docs/site-exceptions.md` (to be created when first needed).

## Known limits

- IP address remains visible to sites; use a VPN/Tor for that threat.
- Unusual configurations can make a fingerprint more unique. Prefer Firefox's built-in protections over many ad-hoc prefs.
- No setup prevents all tracking.
