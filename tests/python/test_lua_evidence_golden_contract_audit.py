import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]


def _load(name: str, path: Path):
    sys.path.insert(0, str(path.parent))
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


audit_tool = _load(
    "test_lua_evidence_golden_contract_audit_module",
    REPO / "tools" / "audit" / "lua_evidence_golden_contract_audit.py",
)


class LuaEvidenceGoldenContractAuditTests(unittest.TestCase):
    def test_strip_top_covers_removes_only_header_markers(self) -> None:
        lines = [
            "-- Canonical evidence file for lurek.demo artifacts.",
            "-- @covers lurek.demo.newThing",
            "-- @covers lurek.filesystem.write",
            "",
            "local OUT = evidence_output_dir(\"demo\")",
            "",
            "describe(\"Evidence: lurek.demo outputs\", function()",
            "    -- Does: Writes a trace.",
            "    -- Shows: The TXT records demo state.",
            "    -- Artifact: tests/artifacts/current/demo/demo_trace.txt",
            "    -- Why: The trace comes from live demo APIs.",
            "    it(\"writes demo_trace.txt\", function()",
            "        expect_true(true)",
            "    end)",
            "end)",
        ]

        changed = audit_tool.strip_top_covers(lines)

        self.assertTrue(changed)
        self.assertNotIn("-- @covers lurek.demo.newThing", lines)
        self.assertNotIn("-- @covers lurek.filesystem.write", lines)
        self.assertIn("-- Canonical evidence file for lurek.demo artifacts.", lines)
        self.assertIn("    -- Artifact: tests/artifacts/current/demo/demo_trace.txt", lines)

    def test_audit_reports_top_level_covers_before_first_it(self) -> None:
        lines = [
            "-- header",
            "-- @covers lurek.demo.newThing",
            "describe(\"Evidence\", function()",
            "    -- Does: Writes a trace.",
            "    -- Shows: The TXT records demo state.",
            "    -- Artifact: tests/artifacts/current/demo/demo_trace.txt",
            "    -- Why: The trace comes from live demo APIs.",
            "    it(\"writes demo_trace.txt\", function()",
            "        expect_true(true)",
            "    end)",
            "end)",
        ]
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "test_demo_evidence.lua"
            path.write_text("\n".join(lines) + "\n", encoding="utf-8")
            findings = audit_tool.audit_evidence_file(path, lines, require_descriptions=False)

        self.assertEqual([finding.code for finding in findings], ["evidence-top-covers"])


if __name__ == "__main__":
    unittest.main()
