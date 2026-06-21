import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from tools.demos.audit_showcase import classify_entry, render_text


class AuditShowcaseTests(unittest.TestCase):
    def make_entry(self, name: str, *, main: str, readme: str = "", conf: bool = False) -> Path:
        tmp = TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        path = Path(tmp.name) / name
        path.mkdir(parents=True)
        (path / "main.lua").write_text(main, encoding="utf-8")
        if readme:
            (path / "README.md").write_text(readme, encoding="utf-8")
        if conf:
            (path / "conf.toml").write_text("title = \"fixture\"\n", encoding="utf-8")
        return path

    def test_known_placeholder_scaffold_is_flagged(self) -> None:
        entry = classify_entry(self.make_entry(
            "visual_fx_lab",
            main="-- skeleton\n-- next step: hook up effects\n",
        ))
        self.assertEqual("candidate_delete_or_evidence", entry.classification)
        self.assertIn("placeholder-text", entry.reasons)
        self.assertIn("missing-conf", entry.reasons)

    def test_runnable_showcase_is_retained(self) -> None:
        entry = classify_entry(self.make_entry(
            "automation_demo",
            main="lurek = lurek or {}\nfunction lurek.init() end\n",
            readme="# Automation Demo\n",
            conf=True,
        ))
        self.assertEqual("showcase", entry.classification)
        self.assertTrue(entry.has_conf)
        self.assertTrue(entry.has_readme)

    def test_text_report_mentions_flagged_entries(self) -> None:
        placeholder = classify_entry(self.make_entry(
            "visual_fx_lab",
            main="-- skeleton\n-- next step: hook up effects\n",
        ))
        showcase = classify_entry(self.make_entry(
            "automation_demo",
            main="lurek = lurek or {}\nfunction lurek.init() end\n",
            readme="# Automation Demo\n",
            conf=True,
        ))
        report = render_text([placeholder, showcase])
        self.assertIn("candidate_delete_or_evidence", report)
        self.assertIn("visual_fx_lab", report)


if __name__ == "__main__":
    unittest.main()
