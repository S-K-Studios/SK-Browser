#!/usr/bin/env python3
"""Validate profile/user.js and profile/distribution/policies.json.

Checks: syntax of each user_pref line, no duplicate prefs, every pref has a
preceding comment section, no forbidden (security-weakening) prefs, valid JSON.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PREF_RE = re.compile(r'^user_pref\("([A-Za-z0-9_.\-]+)",\s*(true|false|-?\d+|"[^"\n]*")\);$')
FORBIDDEN = {
    "security.sandbox.content.level",
    "app.update.auto",
    "app.update.enabled",
    "browser.safebrowsing.malware.enabled",
    "browser.safebrowsing.phishing.enabled",
    "network.cookie.cookieBehavior.optInPartitioning.disable",
}


def check_user_js(path: Path) -> list[str]:
    errors, seen = [], {}
    for n, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("//"):
            continue
        m = PREF_RE.match(line)
        if not m:
            errors.append(f"{path.name}:{n}: invalid pref syntax: {line}")
            continue
        name = m.group(1)
        if name in seen:
            errors.append(f"{path.name}:{n}: duplicate pref {name} (first at line {seen[name]})")
        seen[name] = n
        if name in FORBIDDEN:
            errors.append(f"{path.name}:{n}: forbidden pref {name} (weakens security)")
    return errors


def check_policies(path: Path) -> list[str]:
    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        return [f"{path.name}: invalid JSON: {e}"]
    if "policies" not in data:
        return [f"{path.name}: missing top-level 'policies' key"]
    errors = []
    policies = data["policies"]
    for name in ("DisableAppUpdate", "BlockAboutConfig"):
        if policies.get(name) is True:
            errors.append(f"{path.name}: {name} must not be enabled")
    for ext_id, cfg in policies.get("ExtensionSettings", {}).items():
        url = cfg.get("install_url", "")
        if url and not url.startswith("https://addons.mozilla.org/"):
            errors.append(f"{path.name}: extension {ext_id} installs from non-AMO URL")
    return errors


def main() -> int:
    errors = check_user_js(ROOT / "profile" / "user.js")
    errors += check_policies(ROOT / "profile" / "distribution" / "policies.json")
    for e in errors:
        print("ERROR:", e)
    print("OK" if not errors else f"{len(errors)} problem(s) found")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
