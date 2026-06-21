import unittest
from pathlib import Path

from tools.demos.audit_showcase import ROOT, classify_entry, render_text


class AuditShowcaseTests(unittest.TestCase):
    def test_known_placeholder_scaffold_is_flagged(self) -> None:
        entry = classify_entry(ROOT / "content" / "showcase" / "visual_fx_lab")
        self.assertEqual("candidate_delete_or_evidence", entry.classification)
        self.assertIn("placeholder-text", entry.reasons)
        self.assertIn("missing-conf", entry.reasons)

    def test_runnable_showcase_is_retained(self) -> None:
        entry = classify_entry(ROOT / "content" / "showcase" / "automation_demo")
        self.assertEqual("showcase", entry.classification)
        self.assertTrue(entry.has_conf)
        self.assertTrue(entry.has_readme)

    def test_text_report_mentions_flagged_entries(self) -> None:
        placeholder = classify_entry(ROOT / "content" / "showcase" / "visual_fx_lab")
        showcase = classify_entry(ROOT / "content" / "showcase" / "automation_demo")
        report = render_text([placeholder, showcase])
        self.assertIn("candidate_delete_or_evidence", report)
        self.assertIn("visual_fx_lab", report)


if __name__ == "__main__":
    unittest.main()
