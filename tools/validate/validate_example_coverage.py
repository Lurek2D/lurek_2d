#!/usr/bin/env python3
"""validate_example_coverage.py - Quality gate for example coverage.

Runs tools/audit/example_coverage.py with strict gates so every public API has
one real example block in content/examples/.

Exit code: 0 if all items are fully example-covered, 1 if any gaps remain.

Usage:
    python tools/validate/validate_example_coverage.py
"""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    cmd = [
        sys.executable,
        str(ROOT / "tools" / "audit" / "example_coverage.py"),
        "--report",
        "--no-stubs",
        "--no-partials",
    ]
    print("Running example_coverage.py --report --no-stubs --no-partials...")
    print("Gate: every public API must have one real example block, not just a marker or thin placeholder.")
    result = subprocess.run(cmd, cwd=str(ROOT))
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
