"""
Copy Flutter web build into backend/functions/web so it is deployed with the backend.
Use --base-href /app/ so assets load correctly when served from /app.
Run this before deployment so visiting the root domain shows the Flutter login page.
"""
import shutil
import subprocess
import sys
from pathlib import Path

_FUNCTIONS_DIR = Path(__file__).resolve().parent
_FRONTEND_DIR = _FUNCTIONS_DIR.parent.parent / "frontend"
_FLUTTER_BUILD = _FRONTEND_DIR / "build" / "web"
_TARGET = _FUNCTIONS_DIR / "web"


def main():
    # Build Flutter web with base-href /app/ so assets load when served from /app
    if not _FLUTTER_BUILD.is_dir() or "--force" in sys.argv:
        print("Building Flutter web with --base-href /app/ ...")
        r = subprocess.run(
            ["flutter", "build", "web", "--base-href", "/app/"],
            cwd=str(_FRONTEND_DIR),
            shell=True,
        )
        if r.returncode != 0:
            print("ERROR: Flutter build failed")
            sys.exit(1)
    if _TARGET.exists():
        shutil.rmtree(_TARGET)
    shutil.copytree(_FLUTTER_BUILD, _TARGET)
    print(f"Copied Flutter web build to {_TARGET}")


if __name__ == "__main__":
    main()
