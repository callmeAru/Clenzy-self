"""
Copy Flutter web build into backend/functions/web so it is deployed with the backend.
Run this before deployment so visiting the root domain shows the Flutter login page.
"""
import shutil
from pathlib import Path

_FUNCTIONS_DIR = Path(__file__).resolve().parent
_FLUTTER_BUILD = _FUNCTIONS_DIR.parent.parent / "frontend" / "build" / "web"
_TARGET = _FUNCTIONS_DIR / "web"

def main():
    if not _FLUTTER_BUILD.is_dir():
        print(f"ERROR: Flutter build not found at {_FLUTTER_BUILD}")
        print("Run: cd frontend && flutter build web")
        exit(1)
    if _TARGET.exists():
        shutil.rmtree(_TARGET)
    shutil.copytree(_FLUTTER_BUILD, _TARGET)
    print(f"Copied Flutter web build to {_TARGET}")

if __name__ == "__main__":
    main()
