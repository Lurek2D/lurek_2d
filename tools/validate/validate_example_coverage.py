#!/usr/bin/env python3
"""validate_example_coverage.py — Quality gate for example coverage.

Runs tools/audit/example_coverage.py --report to ensure all API items
have at least a generated stub in content/examples/.

Exit code: 0 if all items covered/stubbed, 1 if any MISSING items found.

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
    result = subprocess.run(cmd, cwd=str(ROOT))
    return result.returncode

if __name__ == "__main__":
    sys.exit(main())
