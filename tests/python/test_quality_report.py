"""Self-tests for the aggregate quality gate."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "test_quality_report_module", REPO / "tools" / "audit" / "quality_report.py"
)
assert SPEC and SPEC.loader
quality_report = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = quality_report
SPEC.loader.exec_module(quality_report)


def _base_payloads() -> tuple[dict, dict, dict, dict]:
    return (
        {"rust": {"coverage_pct": 100}, "lua_api": {"coverage_pct": 100}},
        {"rust": {"coverage_pct": 100}, "lua": {"coverage_pct": 100}},
        {},
        {},
    )


def _focused(pass_value: bool) -> dict:
    return {
        name: {"label": label, "status": "pass" if pass_value else "fail"}
        for name, _, _, label in quality_report.FOCUSED_GATE_SPECS
    }


class QualityReportGateTests(unittest.TestCase):
    def test_focused_failure_changes_overall_verdict(self) -> None:
        payloads = _base_payloads()
        report = quality_report.generate_report(*payloads, _focused(False))
        self.assertIn("| Focused: Lua API validator | fail | FAIL |", report)
        self.assertIn("**FAIL**", report)

    def test_all_focused_gates_can_pass(self) -> None:
        payloads = _base_payloads()
        report = quality_report.generate_report(*payloads, _focused(True))
        self.assertIn("| Focused: Lua API validator | pass | PASS |", report)
        self.assertIn("**PASS**", report)


if __name__ == "__main__":
    unittest.main()
