"""Self-tests for example coverage structural linting."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path
from textwrap import dedent

REPO = Path(__file__).resolve().parents[2]


def _load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


example_coverage = _load(
    "test_example_coverage_module",
    REPO / "tools" / "audit" / "example_coverage.py",
)


class ExampleCoverageLintTests(unittest.TestCase):
    def lint_codes(self, file_name: str, body: str) -> list[str]:
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            (tmp_path / file_name).write_text(dedent(body).lstrip(), encoding="utf-8")
            example_coverage.EXTRA_LINT_ISSUES.clear()
            issues = example_coverage.lint_example_files(tmp_path)
        return [issue[2] for issue in issues]

    def test_accepts_exactly_one_marker_per_do_block(self) -> None:
        codes = self.lint_codes(
            "ok.lua",
            """
            --@api: lurek.render.print
            do
                lurek.render.print("hello", 0, 0)
                lurek.render.print("world", 0, 8)
            end
            """,
        )
        self.assertEqual(codes, [])

    def test_flags_top_level_do_without_marker(self) -> None:
        codes = self.lint_codes(
            "orphan.lua",
            """
            do
                lurek.render.print("orphan", 0, 0)
                lurek.render.print("block", 0, 8)
            end
            """,
        )
        self.assertIn("E7", codes)

    def test_flags_stacked_markers_before_single_block(self) -> None:
        codes = self.lint_codes(
            "stacked.lua",
            """
            --@api: lurek.render.print
            --@api: lurek.render.printf
            do
                lurek.render.printf("x", 0, 0, 10, "left")
                lurek.render.print("y", 0, 8)
            end
            """,
        )
        self.assertIn("E3", codes)

    def test_flags_second_top_level_block_for_same_marker(self) -> None:
        codes = self.lint_codes(
            "double.lua",
            """
            --@api: lurek.render.print
            do
                lurek.render.print("first", 0, 0)
                lurek.render.print("block", 0, 8)
            end

            do
                lurek.render.print("second", 0, 16)
                lurek.render.print("block", 0, 24)
            end
            """,
        )
        self.assertIn("E7", codes)


if __name__ == "__main__":
    unittest.main()
