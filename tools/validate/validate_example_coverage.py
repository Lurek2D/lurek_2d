#!/usr/bin/env python3
"""validate_example_coverage.py — Quality gate for example coverage.

Runs tools/audit/example_coverage.py --report to ensure all public API items
have at least a `--@api:` or `--@api-stub:` marker in content/examples/.

Exit code: 0 if all items are marker-covered, 1 if any MISSING items remain.

Usage:
```
Usage:
    python tools/validate/validate_example_coverage.py
```
"""

import sys
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

def main() -> int:
    cmd = [sys.executable, str(ROOT / "tools" / "audit" / "example_coverage.py"), "--report", "--no-stubs"]
    print("Running example_coverage.py --report --no-stubs...")
    print("Gate: every public API must have a matching --@api: or --@api-stub: marker.")
    result = subprocess.run(cmd, cwd=str(ROOT))
    return result.returncode

if __name__ == "__main__":
    sys.exit(main())
