"""Regression tests for the UI ownership-boundary audit."""
from __future__ import annotations
import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("ui_boundary_check", ROOT / "tools/audit/ui_boundary_check.py")
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

class UiBoundaryCheckTests(unittest.TestCase):
    def test_real_boundary_is_clean(self) -> None:
        self.assertEqual([], MODULE.violations())

    def test_reports_sorted_source_location_for_forbidden_dependency(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "src/ui"; target.mkdir(parents=True)
            (root / "src/render").mkdir(parents=True)
            (target / "bad.rs").write_text("use wgpu::Device;\n", encoding="utf-8")
            self.assertEqual(["src/ui/bad.rs:1: forbidden boundary dependency `wgpu`"], MODULE.violations(root))

if __name__ == "__main__":
    unittest.main()
