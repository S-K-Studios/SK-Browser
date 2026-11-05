# ADR-0001: Build SK-Browser as a hardened Firefox configuration

- **Status:** Accepted
- **Date:** 2026-11-05

## Context

Goal: a personal browser that avoids tracking, is fast and simple, and fits my workflow. Security and privacy are primary objectives.

The main security risk of any custom browser is falling behind on engine patches, not the custom code itself.

## Options considered

| Option | Verdict |
|---|---|
| A. Electron/Tauri shell | Rejected for now. I would own engine updates and rebuild browser-level protections (permissions UI, site handling, updates). Large self-inflicted attack surface. |
| **B. Hardened Firefox (config-as-code)** | **Chosen.** Mozilla ships and auto-delivers engine security fixes. We version our hardening and workflow config in this repo. |
| C. Fork Brave/Ungoogled-Chromium | Rejected for now. Permanent upstream-merge burden and very heavy builds. |
| D. Engine from scratch | Not feasible. |

## Decision

SK-Browser is a **versioned, reproducible configuration layer on top of stock Firefox**:

- `policies.json` for enforced settings and extension installs.
- `user.js` for profile preferences.
- Later: `userChrome.css` and a small companion extension for workflow features.

## Consequences

- (+) Engine updates are handled by Mozilla; low risk of introducing vulnerabilities.
- (+) Fast to deliver, easy to review, easy to roll back with git.
- (−) UI customisation is limited to what Firefox permits.
- (−) Gecko process isolation is generally considered somewhat weaker than Chromium's.
- (−) Hardening can break some sites; a per-site exception process is needed.

## Revisit when

A required workflow cannot be delivered via config or an extension. Any move to a custom shell needs a new ADR.
