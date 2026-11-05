# SK-Browser Requirements

## Vision

A fast, quiet, private browser configured around how I work. Built as a hardened Firefox configuration (see ADR-0001).

## Principles

- Minimal: only keep config that Firefox defaults or policies don't already provide.
- Fast: no setting that slows browsing without a clear privacy/security gain. uBlock Origin is the only extension.
- Everyday sites (Gmail, banking) must work. Never ship settings known to break sign-in.

## Assumptions (unconfirmed, change if wrong)

- A1: Windows is the primary platform.
- A2: Gmail, banking and other sign-ins are used in this browser (confirmed).
- A3: Passwords: not yet decided. Firefox's saved-password setting is left at default; see open questions.
- A4: No Firefox Sync.

## Open questions

- Password manager: use Firefox's built-in (set a Primary Password) or an external one?
- Banking in a separate Firefox profile for extra isolation? (Optional, adds a little friction.)

## Functional requirements

| ID | Requirement | Phase |
|---|---|---|
| F1 | Block trackers, fingerprinting scripts and ads by default (uBlock Origin enforced) | 1 |
| F2 | HTTPS-only mode | 1 |
| F3 | Isolate cookies per site (Total Cookie Protection) | 1 |
| F4 | Disable telemetry, studies, sponsored content and Pocket | 1 |
| F5 | Private search engine as default (manual setting) | 1 |
| F6 | Custom tab layout, shortcuts, theme, start page | 2 |
| F7 | Companion extension for workflow features config cannot deliver | 3 |

## Non-functional requirements

- **Security:** Never disable the sandbox, Safe Browsing or automatic updates. No secrets in the repo.
- **Privacy:** No data sent to third parties by the browser itself beyond what updates and Safe Browsing require.
- **Reproducibility:** The whole setup is installable from this repo by script.
- **Maintainability:** Every non-default pref has a comment saying why. Config is validated by `scripts/check_config.py`.
- **Compatibility:** Gmail and banking sign-in must keep working. Known breakages are logged in `docs/site-exceptions.md` (to be created when first needed).

## Known limits

- IP address remains visible to sites; use a VPN/Tor for that threat.
- Unusual configurations can make a fingerprint more unique. Prefer Firefox's built-in protections over many ad-hoc prefs.
- No setup prevents all tracking.
