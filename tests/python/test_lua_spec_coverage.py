"""Windows-console regression tests for the Lua spec coverage CLI."""

from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SCRIPT = REPO / "tools" / "audit" / "lua_spec_coverage.py"


class LuaSpecCoverageEncodingTests(unittest.TestCase):
    def test_output_path_is_safe_when_parent_console_is_cp1250(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "spec.md"
            env = os.environ.copy()
            env["PYTHONIOENCODING"] = "cp1250"
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--module", "timer", "--output", str(output)],
                cwd=REPO,
                env=env,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
            )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("spec.md", result.stdout)


if __name__ == "__main__":
    unittest.main()
