"""Regression tests for the docs quality audit helpers."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("docs_quality", ROOT / "tools" / "audit" / "docs_quality.py")
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class DocsQualityTests(unittest.TestCase):
    def test_relative_text_docs_accept_relative_links(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs" / "api").mkdir(parents=True)
            (root / "docs" / "guides").mkdir(parents=True)
            (root / "docs" / "contributing").mkdir(parents=True)
            (root / "docs" / "contributing" / "index.md").write_text(
                "# Contributing\n\nSee [API](../api/lurek.md) and [Guide](../guides/index.md).\n",
                encoding="utf-8",
            )
            (root / "docs" / "api" / "lurek.md").write_text("# API\n", encoding="utf-8")
            (root / "docs" / "guides" / "index.md").write_text(
                "# Guides\n\nSee [Contributing](../contributing/index.md).\n",
                encoding="utf-8",
            )

            errors: list[str] = []
            MODULE.check_relative_text_docs(root, errors)
            self.assertEqual([], errors)

    def test_relative_text_docs_flag_bad_encoding_and_links(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs" / "guides").mkdir(parents=True)
            (root / "docs" / "contributing").mkdir(parents=True)
            (root / "docs" / "contributing" / "index.md").write_text(
                "# Contributing\n\nBad [API](docs/api/lurek.md), [abs](C:/temp/foo.md), and [Site](https://example.com).\nMojibake: CafÃ©.\n",
                encoding="utf-8",
            )
            (root / "docs" / "guides" / "index.md").write_bytes(b"# Guides\n\xff\n")

            errors: list[str] = []
            MODULE.check_relative_text_docs(root, errors)

            self.assertIn("NON_UTF8_TEXT docs/guides/index.md", errors)
            self.assertIn("BROKEN_RELATIVE_LINK docs/contributing/index.md -> docs/api/lurek.md", errors)
            self.assertIn("ABSOLUTE_LINK docs/contributing/index.md -> C:/temp/foo.md", errors)
            self.assertNotIn("NON_RELATIVE_LINK docs/contributing/index.md -> https://example.com", errors)
            self.assertTrue(any(item.startswith("MOJIBAKE_TEXT docs/contributing/index.md") for item in errors))


if __name__ == "__main__":
    unittest.main()
