"""Regression checks for the generated native primitive shape catalogue."""

from __future__ import annotations

from pathlib import Path
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / "tools" / "render" / "gen_builtin_shapes.py"


class NativeShapeCatalogTests(unittest.TestCase):
    def test_catalog_is_exact_and_generated_output_is_current(self) -> None:
        result = subprocess.run(
            [sys.executable, str(GENERATOR), "--check", "--root", str(ROOT)],
            cwd=ROOT,
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("96 entries", result.stdout)


if __name__ == "__main__":
    unittest.main()
