"""Render every pose script in poses/ — used for final verification."""
import glob
import os
import subprocess
import sys

here = os.path.dirname(os.path.abspath(__file__))
failed = []
for path in sorted(glob.glob(os.path.join(here, "poses", "*.py"))):
    r = subprocess.run([sys.executable, path], capture_output=True, text=True)
    if r.returncode != 0:
        failed.append((os.path.basename(path), r.stderr.strip().splitlines()[-1:]))
print(f"rendered {len(glob.glob(os.path.join(here, 'out', '*.png')))} pngs")
if failed:
    print("FAILED:")
    for name, err in failed:
        print(" ", name, err)
    sys.exit(1)
