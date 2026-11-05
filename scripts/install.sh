#!/usr/bin/env bash
# Install SK-Browser config into a Firefox profile.
# Usage: scripts/install.sh <path-to-firefox-profile-dir> [<path-to-firefox-install-dir>]
# The profile dir is shown at about:profiles. The install dir (e.g. /usr/lib/firefox)
# is optional and needs write access (usually sudo) for policies.json.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${1:?Usage: $0 <firefox-profile-dir> [firefox-install-dir]}"
INSTALL_DIR="${2:-}"

python3 "$ROOT/scripts/check_config.py"

[[ -d "$PROFILE" ]] || { echo "Profile dir not found: $PROFILE" >&2; exit 1; }
pgrep -x firefox >/dev/null && { echo "Close Firefox first." >&2; exit 1; }

cp -v "$ROOT/profile/user.js" "$PROFILE/user.js"

if [[ -n "$INSTALL_DIR" ]]; then
  [[ -d "$INSTALL_DIR" ]] || { echo "Install dir not found: $INSTALL_DIR" >&2; exit 1; }
  mkdir -p "$INSTALL_DIR/distribution"
  cp -v "$ROOT/profile/distribution/policies.json" "$INSTALL_DIR/distribution/policies.json"
else
  echo "Skipped policies.json (no install dir given). Extensions/policies not applied."
fi
echo "Done. Start Firefox and verify at about:policies and about:config."
