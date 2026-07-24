"""Regression tests for the active Codex CAG validation surfaces."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


VALID_SKILL = """---
name: sample
description: \"Load this skill when testing CAG validation. Skip it for production work.\"
---
# sample

## Mission
- Test a narrow validator seam.

## Domain Knowledge
- Fixture knowledge.

## Workflow
- Run the fixture.

## References
- `contracts: AGENTS.md`
- `tools: tools/python.cmd tools/validate/cag_validate.py`
- `agent: content`
- RAG: `validator fixture`
"""


class CagToolsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.validator = load("cag_validate_test", REPO / "tools" / "validate" / "cag_validate.py")
        cls.coverage = load("cag_coverage_test", REPO / "tools" / "audit" / "cag_coverage.py")
        cls.links = load("cag_link_check_test", REPO / "tools" / "audit" / "cag_link_check.py")

    def test_active_workspace_validates(self) -> None:
        violations, counts = self.validator.run_validation()
        self.assertEqual([], violations)
        self.assertEqual(11, counts["role"])
        self.assertEqual(33, counts["skill"])

    def test_contract_character_cap(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "AGENTS.md"
            path.write_text("# x\n\n## Mission & Scope\n- x\n\n## Files\n- x\n\n## Rules\n- x\n\n## Workflow\n- x\n" + "x" * 3001, encoding="utf-8")
            rules = {item.rule for item in self.validator.check_contract(path)}
            self.assertIn("E401", rules)

    def test_skill_character_cap_and_reference_check(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "sample" / "SKILL.md"
            path.parent.mkdir()
            path.write_text(VALID_SKILL + "x" * 5001, encoding="utf-8")
            rules = {item.rule for item in self.validator.check_skill(path, {"content"})}
            self.assertIn("E201", rules)
            broken = VALID_SKILL.replace("AGENTS.md", "missing/AGENTS.md")
            path.write_text(broken, encoding="utf-8")
            rules = {item.rule for item in self.validator.check_skill(path, {"content"})}
            self.assertIn("E209", rules)

    def test_domain_coverage_is_complete(self) -> None:
        report = self.coverage.scan(require_workspace=True)
        self.assertEqual(15, report["domains"]["count"])
        self.assertTrue(all(row["status"] == "pass" for row in report["domains"]["rows"]))

    def test_structured_links_are_clean(self) -> None:
        self.assertEqual(0, self.links.scan(require_workspace=True)["broken_total"])


if __name__ == "__main__":
    unittest.main()
