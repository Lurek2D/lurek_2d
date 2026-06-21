"""Self-tests for unit-test API coverage structure rules."""

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


unit_test_api_coverage = _load(
    "test_unit_test_api_coverage_module",
    REPO / "tools" / "audit" / "unit_test_api_coverage.py",
)


class UnitTestApiCoverageStructureTests(unittest.TestCase):
    def run_scan(self, files: dict[str, str]) -> tuple[list[object], dict]:
        api_entries = [
            unit_test_api_coverage.ApiEntry(
                module="timer",
                lua_name="lurek.timer.getDelta",
                name="getDelta",
                is_method=False,
                owner_type="",
                source_file="src/lua_api/timer_api.rs",
                source_line=1,
            ),
            unit_test_api_coverage.ApiEntry(
                module="timer",
                lua_name="lurek.timer.sleep",
                name="sleep",
                is_method=False,
                owner_type="",
                source_file="src/lua_api/timer_api.rs",
                source_line=2,
            ),
        ]
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            for name, body in files.items():
                (tmp_path / name).write_text(dedent(body).lstrip(), encoding="utf-8")
            return unit_test_api_coverage.scan_all_tests(tmp_path, api_entries)

    def test_counts_single_marker_block_as_explicit_coverage(self) -> None:
        results, structure = self.run_scan(
            {
                "ok.lua": """
                -- @covers lurek.timer.getDelta
                it("covers getDelta", function()
                    local dt = lurek.timer.getDelta()
                    expect_type("number", dt)
                end)
                """,
            }
        )
        result = next(item for item in results if item.api.lua_name == "lurek.timer.getDelta")
        self.assertTrue(result.explicit)
        self.assertEqual(structure["by_code"], {})

    def test_flags_missing_marker_block(self) -> None:
        _, structure = self.run_scan(
            {
                "missing.lua": """
                it("missing marker", function()
                    local dt = lurek.timer.getDelta()
                    expect_type("number", dt)
                end)
                """,
            }
        )
        self.assertEqual(structure["by_code"].get("missing-marker"), 1)

    def test_flags_multiple_markers_on_one_block(self) -> None:
        results, structure = self.run_scan(
            {
                "multi.lua": """
                -- @covers lurek.timer.getDelta
                -- @covers lurek.timer.sleep
                it("two markers", function()
                    local dt = lurek.timer.getDelta()
                    lurek.timer.sleep(1)
                    expect_type("number", dt)
                end)
                """,
            }
        )
        get_delta = next(item for item in results if item.api.lua_name == "lurek.timer.getDelta")
        sleep = next(item for item in results if item.api.lua_name == "lurek.timer.sleep")
        self.assertFalse(get_delta.explicit)
        self.assertFalse(sleep.explicit)
        self.assertEqual(structure["by_code"].get("multiple-markers"), 1)

    def test_flags_duplicate_marker_across_blocks(self) -> None:
        results, structure = self.run_scan(
            {
                "dup.lua": """
                -- @covers lurek.timer.getDelta
                it("first block", function()
                    local dt = lurek.timer.getDelta()
                    expect_type("number", dt)
                end)

                -- @covers lurek.timer.getDelta
                it("second block", function()
                    local dt = lurek.timer.getDelta()
                    expect_type("number", dt)
                end)
                """,
            }
        )
        result = next(item for item in results if item.api.lua_name == "lurek.timer.getDelta")
        self.assertTrue(result.explicit)
        self.assertEqual(structure["by_code"].get("duplicate-marker"), 1)


if __name__ == "__main__":
    unittest.main()
