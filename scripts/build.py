#!/usr/bin/env python3
"""Build dist/SK-Browser-<VERSION>.zip. Publisher: SK Studios (Personal Use Only)."""
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_config import read_version  # noqa: E402

INCLUDE = ["profile", "scripts/install.ps1", "VERSION", "README.md", "CHANGELOG.md"]


def main() -> int:
    version = read_version(ROOT / "VERSION")
    out = ROOT / "dist" / f"SK-Browser-{version}.zip"
    out.parent.mkdir(exist_ok=True)
    files = []
    for item in INCLUDE:
        p = ROOT / item
        files += sorted(f for f in p.rglob("*") if f.is_file()) if p.is_dir() else [p]
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for f in files:
            z.write(f, f.relative_to(ROOT).as_posix())
    print(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
