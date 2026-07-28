"""Regression tests for the province/render ownership-boundary audit."""
from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "render_dependency_check", ROOT / "tools/audit/render_dependency_check.py"
)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class RenderDependencyCheckTests(unittest.TestCase):
    def test_real_boundary_is_clean(self) -> None:
        self.assertEqual([], MODULE.violations())

    def test_reports_province_wgpu_and_render_registry_dependencies(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            province = root / "src/province"
            render = root / "src/render"
            province.mkdir(parents=True)
            render.mkdir(parents=True)
            (province / "bad.rs").write_text("use wgpu::Device;\n", encoding="utf-8")
            (render / "bad.rs").write_text(
                "use crate::province::registry::ProvinceRegistry;\n", encoding="utf-8"
            )
            self.assertEqual(
                [
                    "src/province/bad.rs:1: forbidden boundary dependency `wgpu`",
                    "src/render/bad.rs:1: forbidden boundary dependency `crate::province::registry`",
                    "src/render/bad.rs:1: forbidden boundary dependency `ProvinceRegistry`",
                ],
                MODULE.violations(root),
            )


if __name__ == "__main__":
    unittest.main()
